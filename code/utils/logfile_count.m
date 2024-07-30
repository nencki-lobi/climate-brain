%% Initial setup

logdir = './data/logs/';

%% Load questionnaire data

qdata = readtable('./data/questionnaires/subjects.csv');
qdata.Properties.VariableNames = ["sid","code"];

subjects = erase(qdata.code,'ngr');

%% Check for any missing or unwanted logfiles

patterns = {'stories_R1', 'stories_R2', 'stories_R3', 'cet-', 'cet-'};
extensions = {'.log', '.log', '.log', '.log', 'custom.txt'};

for s = 1:numel(subjects)

    sub = subjects{s};
    files = dir([logdir, sub, '*']);

    if numel(files) ~= numel(patterns)
        fprintf('\n Warning: %s \n', sub)
    end
    
    for p = 1:numel(patterns)

        pattern = patterns{p};
        extension = extensions{p};

        ismatch = contains({files.name}, pattern) & endsWith({files.name}, extension);

        if sum(ismatch) < 1
            fprintf('Missing `%s*%s` \n', pattern, extension)
        elseif sum(ismatch) > 1
            fprintf('More than one `%s*%s` \n', pattern, extension)
        end
    end
end
