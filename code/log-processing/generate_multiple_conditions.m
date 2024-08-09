%% Load a list of subject identifiers

qdata = readtable('./data/questionnaires/subjects.csv');
qdata.Properties.VariableNames = ["sid","code"];

subjects = erase(qdata.code,'ngr');

%% For stories part, generate multiple conditions MAT file just for one reference subject

eventsdir = './output/bids/stories-events/';

subject = '2711a'; % choose subject
runs = {'R1','R2','R3'};

for r = 1:3

    run = runs{r};

    events = readtable( ...
        [eventsdir 'sub-' subject '_task-stories_run-0' num2str(r) '_events.tsv'], ...
        "FileType","text",'Delimiter', '\t');

    multiple_conditions_stories(events, run)
end

%% For CET part, generate multiple conditions MAT file for each subject

eventsdir = './output/bids/cet-events/';

for s = 1:numel(subjects)
    
    subject = subjects{s};

    events = readtable( ...
        [eventsdir 'sub-' subject '_task-cet_events.tsv'], ...
        "FileType","text",'Delimiter', '\t');

    multiple_conditions_cet(events, subject)
end

%% Clear workspace

clearvars -except subjects