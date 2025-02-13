# Libraries

library(Rmisc)
library(broom)
library(jsonlite)
library(psych)
library(report)
library(tidyverse)
library(jmv)

# Set paths

workdir = Sys.getenv("HOME")
basedir = file.path(workdir, 'climate-brain')
bidsdir = file.path(workdir, 'ds005460')

setwd(file.path(basedir))

# Output directory

output_dir = "./output/behavioral/"
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}

# Load data

participants = read.table(file.path(bidsdir, "participants.tsv"), na.strings = "n/a", header = T, sep = "\t", quote = "", encoding = "UTF-8")
participants_json = fromJSON(file.path(bidsdir, "participants.json"))
texts = read.table(file.path(basedir, "data/stories-texts.tsv"), header = T, sep = "\t", quote = "", encoding = "UTF-8")
stories = read.table(file.path(basedir, "output/stories-events.tsv"), header = T, sep = "\t", quote = "", encoding = "UTF-8")
cet = read.table(file.path(basedir, "output/cet-events.tsv"), header = T, sep = "\t", quote = "", encoding = "UTF-8")

# Prepare data

participants = participants %>% 
  mutate(participant_id = str_replace(participant_id, "sub-", "")) %>%
  mutate(condition = factor(condition, levels = c("ANG", "HOP", "NEU")))

texts = texts %>%
  mutate(leng = nchar(story_PL))

stories = stories %>% 
  filter(trial_type != 'Q') %>% # drop `question` events
  mutate(trial_type = factor(trial_type, levels = c("ANG", "HOP", "NEU", "CON"))) %>%
  mutate(across(c(valence, arousal), ~ ifelse(. == "none", 5, as.numeric(.)))) # replace `none` by the middle of the scale, i.e. 5

cet = cet %>%
  filter(!grepl("d", trial_code)) %>% # remove `dummy` trials
  mutate(decision = case_when(
    startsWith(trial_code, 'c') & response == 'LEFT' ~ 1, # 0 - egoistic, 1 - climate-friendly
    startsWith(trial_code, 'c') & response == 'RIGHT' ~ 0, 
    startsWith(trial_code, 'm') & response == 'LEFT' ~ 0,
    startsWith(trial_code, 'm') & response == 'RIGHT' ~ 1,
    TRUE ~ NaN
  ))

# Helper variables

variables = setdiff(colnames(participants), c("participant_id", "condition"))
categorical_vars= c("sex", "education", "residence", "car", "driver", "politics1", "politics2", "SES")
numerical_vars = setdiff(variables, categorical_vars)

money_levels = c("0", "10", "50", "80", "100", "120")
carbon_levels = c("0", "2", "10", "25", "40", "50")

# Aesthetic themes and palettes

beauty = theme_linedraw() + theme(panel.grid = element_blank(),
                                  axis.title = element_text(size = 12),
                                  axis.text = element_text(size = 10),
                                  legend.title = element_text(size = 10),
                                  strip.background = element_rect(fill = "white", color = "white"),
                                  strip.text = element_text(colour = "black", size = 10, family = "Arial"),
                                  aspect.ratio = 1)

ice_palette = c("#a73647", "#84565b", "#d47f7a", "#febe2a", "#5fae86", "#6b8f66", "#005029", "#1b3350")
ice_labels = str_replace(str_subset(variables, "ICE"), "ICE_", "Climate ")

emo_palette = c("ANG" = "#B93C4F", "HOP" = "#436EB1", "NEU" = "#62666A", "CON" = "#D5D7D8")
emo_labels = c("Anger", "Hope", "Neutral", "Control")

# Helper functions

generate_legend = function(variable, legend_data, width = 80) {
  var_info = legend_data[[variable]]
  legend_text = var_info$Description
  if (!is.null(var_info$Levels)) {
    levels_text = paste(names(var_info$Levels), "=", var_info$Levels, collapse = ", ")
    legend_text = paste(legend_text, " - Levels: ", levels_text)
  }
  else if (!is.null(var_info$Units)) {
    units_text = var_info$Units
    legend_text = paste(legend_text, " - Units: ", units_text)
  }
  str_wrap(legend_text, width = width)
}

create_histogram = function(variable, description = NULL) {
  
  legend_text = generate_legend(variable, participants_json)
  
  if (is.null(description)) {
    description = variable
  }
  
  p = participants %>%
    ggplot(aes_string(x = variable, fill = "condition")) +
    geom_histogram(stat = "count", color = "black", size = 0.2) +
    scale_fill_manual(values = emo_palette, name = "Group of \nparticipants") +
    facet_wrap(~condition, ncol = 1) +
    labs(x = description, y = "Frequency", caption = legend_text) + 
    beauty + theme(aspect.ratio = 0.2,
                   plot.caption.position = "plot",
                   plot.caption = element_text(hjust = 0))
  ggsave(filename = paste0(output_dir, variable, "_histogram.png"), plot = p, width = 5, height = 4.5)
}

run_anova = function(variable) {
  aov(as.formula(paste(variable, "~ condition")), data = participants) %>%
    tidy() %>%
    mutate(variable = variable)
}

# Analyses

## Stimuli

text_len = texts %>%
  group_by(group) %>% 
  dplyr::summarise(mean_leng = mean(leng, na.rm = TRUE),
            sd_leng = sd(leng, na.rm = TRUE))
text_diff = aov(leng ~ group, data = texts)
summary(text_diff)

## Descriptives

descriptives_categorical = participants %>%
  select(condition, all_of(categorical_vars)) %>%
  pivot_longer(-condition, names_to = "variable", values_to = "value") %>%
  group_by(condition, variable, value) %>%
  dplyr::summarise(n = n(), .groups = 'drop') %>%
  arrange(variable, condition)
write.csv(descriptives_categorical, file = file.path(output_dir, "descriptives_categorical.csv"), row.names = FALSE)

descriptives_numerical = describeBy(participants[numerical_vars], participants$condition) %>%
  do.call(rbind, .) %>%
  rownames_to_column(var = "variable") %>%
  separate_wider_delim(variable, delim = ".", names = c("condition", "variable")) %>%
  arrange(variable, condition)
write.csv(descriptives_numerical, file = file.path(output_dir, "descriptives_numerical.csv"), row.names = FALSE)

anova_table = lapply(numerical_vars, run_anova) %>%
  bind_rows() %>%
  mutate(adjusted_p.value = p.adjust(p.value, method = "bonferroni", n = length(numerical_vars)))

write.table(anova_table, file = file.path(output_dir, "anova_by_group.csv"), sep = ",", row.names = FALSE)

## RRES

RRES = participants %>%
  select(participant_id, condition) %>%
  left_join(stories, by = "participant_id") %>%
  group_by(participant_id, condition, trial_type) %>%
  dplyr::summarise(n = n(), valence = mean(valence), arousal = mean(arousal),
                   .groups = 'drop')

RRES$participant_id = as.factor(RRES$participant_id)
RRES$story_type = recode(RRES$trial_type, ANG = "TAR", HOP = "TAR", NEU = "TAR", CON = "CON")

RRES.wide = RRES %>%
  pivot_wider(id_cols = c("participant_id", "condition"),
              names_from = c("story_type"),
              names_sep = ".",
              names_sort = T,
              values_from = c("valence", "arousal"))

RRES_by_valence = RRES %>% 
  summarySE(measurevar = "valence", groupvars = c("condition", "trial_type"))

RRES_by_arousal = RRES %>% 
  summarySE(measurevar = "arousal", groupvars = c("condition", "trial_type"))

### RRES: Valence ANOVA

valence_anova = jmv::anovaRM(
  data = RRES.wide,
  rm = list(
    list(
      label="story type",
      levels=c("target", "control"))),
  rmCells = list(
    list(
      measure="valence.TAR",
      cell="target"),
    list(
      measure="valence.CON",
      cell="control")),
  bs = condition,
  effectSize = c("eta", "partEta"),
  depLabel = "Valence",
  rmTerms = ~ `story type`,
  bsTerms = ~ condition,
  postHoc = list(
    c("story type", "condition")),
  postHocCorr = c("none", "tukey"),
  emMeans = ~ condition:`story type`,
  emmTables = TRUE,
  groupSumm = TRUE)

valence_posthocs = valence_anova$postHoc [[1]]$asDF
valence_posthocs = valence_posthocs[c(3,8,12,1,2,6),] # planned comparisons only
valence_posthocs$p.planned = p.adjust(valence_posthocs$pnone, method = "bonferroni")

## RRES: Arousal ANOVA

arousal_anova = jmv::anovaRM(
  data = RRES.wide,
  rm = list(
    list(
      label="story type",
      levels=c("target", "control"))),
  rmCells = list(
    list(
      measure="arousal.TAR",
      cell="target"),
    list(
      measure="arousal.CON",
      cell="control")),
  bs = condition,
  effectSize = c("eta", "partEta"),
  depLabel = "Arousal",
  rmTerms = ~ `story type`,
  bsTerms = ~ condition,
  postHoc = list(
    c("story type", "condition")),
  postHocCorr = c("none", "tukey"),
  emMeans = ~ condition:`story type`,
  emmTables = TRUE,
  groupSumm = TRUE)

arousal_posthocs = arousal_anova$postHoc [[1]]$asDF
arousal_posthocs = arousal_posthocs[c(3,8,12,1,2,6),] # planned comparisons only
arousal_posthocs$p.planned = p.adjust(arousal_posthocs$pnone, method = "bonferroni")

## CET

CET_by_money = cet %>%
  drop_na(decision) %>%
  group_by(participant_id, money) %>%
  dplyr::summarise(n = n(), proportion = mean(decision),
                   .groups = 'drop') %>%
  summarySE(measurevar="proportion", groupvars=c("money"))
  
CET_by_carbon = cet %>%
  drop_na(decision) %>%
  group_by(participant_id, carbon) %>%
  dplyr::summarise(n = n(), proportion = mean(decision), 
                   .groups = 'drop') %>%
  summarySE(measurevar="proportion", groupvars=c("carbon"))

# Plots 
  
## Descriptives histograms (Figure 3)

legends = lapply(variables, generate_legend, legend_data = participants_json) # just for inspection

lapply(variables, create_histogram)
create_histogram("CCC", "Climate change concern")

## ICE plot (Figure 4)

ice_labeller = ice_labels
names(ice_labeller) = str_subset(variables, "ICE")

plot_ice = participants %>%
  select(participant_id, condition, starts_with('ICE')) %>%
  gather(ICE, score, starts_with('ICE'), factor_key=TRUE) %>%
  ggplot(aes(x=condition, y=score, fill=condition)) + 
  geom_dotplot(color = NA, binwidth = 0.4, binaxis='y', stackdir='center') +
  scale_fill_manual(values = emo_palette, name = "Group of participants") +
  labs(x = "Group of participants", y = "Score") +
  facet_wrap(~ICE, labeller = as_labeller(ice_labeller), ncol = 4) +
  beauty + theme(legend.position="none")

ggsave(file = file.path(output_dir, "ICE_scores.png"), plot_ice, width = 8, height = 6)

## RRES valence and arousal plots (Figure 5)

plot_valence = ggplot(RRES_by_valence, aes(fill = trial_type, x = condition, y = valence)) +
  geom_bar(stat = "identity", position = "dodge", color="black", size = 0.2) +
  geom_errorbar(aes(ymin = valence - ci, ymax = valence + ci), 
                width = 0.2, position = position_dodge(width = 0.9)) +
  labs(x = "Group of participants", y = "Mean valence") +
  ylim(c(0, 10)) +
  scale_fill_manual(values = emo_palette, name = "Type of stories", labels = emo_labels) +
  beauty

ggsave(file = file.path(output_dir, "stories_valence_rating.png"), plot_valence, width = 5, height = 4)

plot_arousal = ggplot(RRES_by_arousal, aes(fill = trial_type, x = condition, y = arousal)) +
  geom_bar(stat = "identity", position = "dodge", color="black", size = 0.2) +
  geom_errorbar(aes(ymin = arousal - ci, ymax = arousal + ci), 
                width = 0.2, position = position_dodge(width = 0.9)) +
  labs(x = "Group of participants", y = "Mean arousal") +
  ylim(c(0, 10)) +
  scale_fill_manual(values = emo_palette, name = "Type of stories", labels = emo_labels) +
  beauty

ggsave(file = file.path(output_dir, "stories_arousal_rating.png"), plot_arousal, width = 5, height = 4)

## CET plots (Figure 7)

plot_CET_money = CET_by_money %>%
  ggplot(aes(x = money, y = proportion)) +
  geom_line() + geom_point() +
  geom_errorbar(aes(ymin = proportion - ci, ymax = proportion + ci), width = 2) +
  labs(x = "Money bonus level (PLN)", y = "Proportion of \n climate-friendly choices") +
  scale_x_continuous(breaks = as.numeric(money_levels), labels = money_levels) +
  beauty

ggsave(file = file.path(output_dir, "CET_money.png"), plot_CET_money, width = 3, height = 3)

plot_CET_carbon = CET_by_carbon %>%
  ggplot(aes(x = carbon, y = proportion)) +
  geom_line() + geom_point() +
  geom_errorbar(aes(ymin = proportion - ci, ymax = proportion + ci), width = 2) +
  labs(x = "Carbon emission level (kg)", y = "Proportion of \n climate-friendly choices") +
  scale_x_continuous(breaks = as.numeric(carbon_levels), labels = carbon_levels) +
  beauty

ggsave(file = file.path(output_dir, "CET_carbon.png"), plot_CET_carbon, width = 3, height = 3)
