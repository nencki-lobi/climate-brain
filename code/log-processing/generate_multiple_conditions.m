%% Initial setup

workdir = pwd;
basedir = fullfile(pwd, 'neurogrieg'); % git repo location
bidsdir = fullfile(pwd, 'ds-ngr/bids'); % BIDS dataset location

%% Load a list of subject identifiers

qdata = readtable(fullfile(basedir, 'data/questionnaires/subjects.csv'));
qdata.Properties.VariableNames = ["sid","code"];

subjects = erase(qdata.code,'ngr');

%% For stories part, generate multiple conditions MAT file just for one reference subject

outdir = fullfile(basedir, 'code/first-level/multiple-conditions-stories');

subject = '2711a'; % choose subject
subdir = ['sub-' subject];
runs = {'R1','R2','R3'};

for r = 1:3

    run = runs{r};

    events = readtable( ...
        fullfile(bidsdir, subdir, 'func', ['sub-' subject '_task-stories_run-0' num2str(r) '_events.tsv']), ...
        "FileType","text",'Delimiter', '\t');

    multiple_conditions_stories(events, run, outdir)
end

%% For CET part, generate multiple conditions MAT file for each subject

outdir = fullfile(basedir, 'code/first-level/multiple-conditions-cet');

for s = 1:numel(subjects)
    
    subject = subjects{s};
    subdir = ['sub-' subject];

    events = readtable( ...
        fullfile(bidsdir, subdir, 'func', ['sub-' subject '_task-cet_events.tsv']), ...
        "FileType","text",'Delimiter', '\t');

    multiple_conditions_cet(events, subject, outdir)
end

%% Clear workspace

clearvars -except subjects