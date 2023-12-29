%% Initial setup

logdir = './data/logs/';

%% Load questionnaire data

qdata = readtable('./data/questionnaires/demo-by-subject.csv');
qdata.Properties.VariableNames = ["sid","code","sex","age"];

subjects = erase(qdata.code,'ngr');

%% Identify condition

nsubjects = numel(subjects);
nruns = 3;

ANG = {'ANG21','ANG8','ANG25'};
HOP = {'HOP22','HOP23','HOP17'};
NEU = {'NEU24','NEU14','NEU1'};

condition = cell(nsubjects,1);

for s = 1:nsubjects

    sub = subjects{s};
    cond = cell(nruns,1);

    for r = 1:3

        pat = [sub, '-stories_R', num2str(r), '*.log'];
        logfile = dir(fullfile(logdir, pat)).name;
        txt = readlines(fullfile(logdir, logfile));
        
        if any(contains(txt, ANG{r}))
            cond(r) = {'ANG'};
        elseif any(contains(txt, HOP{r}))
            cond(r) = {'HOP'};
        elseif any(contains(txt, NEU{r}))
            cond(r) = {'NEU'};
        else
            cond(r) = {'?'};
        end
    end
    
    cond = unique(cond(:));

    if numel(cond) == 1
        condition(s) = cond;
    else
        condition(s) = {'?'};
    end
end

%% Save output

T = [array2table(subjects), array2table(condition)];
writetable(T, './output/condition-by-subject.csv')
