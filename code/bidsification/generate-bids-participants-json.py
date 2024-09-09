# Import dependencies

import json
import os

# Set paths

workdir = os.environ['HOME']
bidsdir = os.path.join(workdir, 'bids-wannabe') # location of a dataset we want to bidsify

# Define functions

def add_entry(data, key, description, levels_or_units):
    if isinstance(levels_or_units, dict):
        data[key] = {"Description": description, "Levels": levels_or_units}
    else:
        data[key] = {"Description": description, "Units": levels_or_units}


# Prepare entries

entries = [
    ("condition", "Experimental condition to which the participant belonged",
     {"ANG": "Anger",
      "HOP": "Hope",
      "NEU": "Neutral"}),
    ("sex", "Sex", {"0": "Female", "1": "Male"}),
    ("age", "Age", "Years"),
    ("residence", "Place of residence",
     {"0": "Big city",
      "1": "Suburbs of a big city",
      "2": "Small city",
      "3": "Country village",
      "4": "A farm or home in the countryside"}),
    ("education", "Education level",
     {"0": "Incomplete primary",
      "1": "Primary",
      "2": "Lower secondary",
      "3": "Vocational",
      "4": "Upper secondary",
      "5": "Bachelor's degree or engineering degree",
      "6": "Master's degree or medical degree",
      "7": "Doctorate (Ph.D.), habilitation, or professorship",
      "8": "Other"}),
    ("CCC", "How concerned are you about climate change?",
     {"0": "Not at all concerned",
      "1": "Not very concerned",
      "2": "Somewhat concerned",
      "3": "Very concerned",
      "4": "Extremely concerned"}),
    ("actions", "What actions do you consider most important in addressing climate change?",
     "Points on a scale, where: 1 - Collective actions (by states, institutions, corporations), 5 - Individual actions (by ordinary people)"),
    ("lifestyle", "Compared to other people, do you consider your lifestyle ...?",
     "Points on a scale, where: 1 - Definitely climate-unfriendly, 5 - Definitely climate-friendly"),
    ("driver", "Do you have a driver's license?", {"0": "Yes", "1": "No"}),
    ("car", "How often do you use a car (e.g. as a driver or a passenger)?",
     {"0": "Once a year or several times a year",
      "1": "Once a month or several times a month",
      "2": "Once a week or several times a week",
      "3": "Every day"}),
    ("politics1", "Do you have any political views?", {"0": "No", "1": "Yes"}),
    ("politics2",
     "In politics, the terms /left/ and /right/ are used. Can you describe your political views using these terms?",
     {"0": "No", "1": "Yes"}),
    ("politics3", "Please indicate your political views.",
     "Points on a scale, where: 0 - Left, 10 - Right"),
    ("SES", "Which of the descriptions below comes closest to how you feel about your household income nowadays?",
     {"0": "Living comfortably on present income",
      "1": "Coping on present income",
      "2": "Finding it difficult on present income",
      "3": "Finding it very difficult on present income"}),
    ("PCAE_i", "Personal and Collective Action Efficacy (Chu & Yang, 2020) - Individual efficacy", "Total score"),
    ("PCAE_c", "Personal and Collective Action Efficacy (Chu & Yang, 2020) - Collective efficacy", "Total score"),
    ("PCAE", "Personal and Collective Action Efficacy (Chu & Yang, 2020)", "Total score"),
    ("PD", "Psychological Distance to Climate Change (Valkengoed, Steg & Perlaviciute, 2021)", "Total score"),
    ("NR", "Nature Relatedness (Nisbet & Zelenski, 2013)", "Total score"),
    ("ICE_anger", "Inventory of Climate Emotions (Marczak et al. 2023) - Climate anger", "Total score"),
    ("ICE_discontent", "Inventory of Climate Emotions (Marczak et al. 2023) - Climate discontent", "Total score"),
    ("ICE_enthusiasm", "Inventory of Climate Emotions (Marczak et al. 2023) - Climate enthusiasm", "Total score"),
    ("ICE_powerlessness", "Inventory of Climate Emotions (Marczak et al. 2023) - Climate powerlessness", "Total score"),
    ("ICE_guilt", "Inventory of Climate Emotions (Marczak et al. 2023) - Climate guilt", "Total score"),
    ("ICE_isolation", "Inventory of Climate Emotions (Marczak et al. 2023) - Climate isolation", "Total score"),
    ("ICE_anxiety", "Inventory of Climate Emotions (Marczak et al. 2023) - Climate anxiety", "Total score"),
    ("ICE_sorrow", "Inventory of Climate Emotions (Marczak et al. 2023) - Climate sorrow", "Total score")
]

# Loop through the entries to generate the final output

final = {}

for key, description, levels_or_units in entries:
    add_entry(final, key, description, levels_or_units)

# Save output as a nicely formatted JSON file

with open(os.path.join(bidsdir, 'participants.json'), "w") as file:
    json.dump(final, file, indent=4)
