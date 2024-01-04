%% Initial setup

logdir = './data/logs/';

%% Load questionnaire data

qdata = readtable('./data/questionnaires/demo-by-subject.csv');
qdata.Properties.VariableNames = ["sid","code","sex","age"];

subjects = erase(qdata.code,'ngr');

%% For stories part, generate multiple conditions MAT file just for one reference subject

subject = '2711a'; % choose subject
runs = {'R1','R2','R3'};

for r = 1:3
    run = runs{r};
    multiple_conditions_stories(logdir, subject, run)
end

%% For CET part, generate multiple conditions MAT file for each subject

for s = 1:numel(subjects)
    subject = subjects{s};
    multiple_conditions_cet(logdir, subject)
end

%% Clear workspace

clearvars -except logdir subjects