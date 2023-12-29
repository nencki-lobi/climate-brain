%% Initial setup

logdir = './data/logs/';

%% Load questionnaire data

qdata = readtable('./data/questionnaires/demo-by-subject.csv');
qdata.Properties.VariableNames = ["sid","code","sex","age"];

subjects = erase(qdata.code,'ngr');

%% Find proportion of egoistic, altruistic, correct dummy & correct rational trials for each subject

results = cell(numel(subjects), 5);

for s = 1:numel(subjects)
    
    sub = subjects{s};
    pat = [sub, '-cet-', '*custom.txt'];

    c = dir(fullfile(logdir, pat)).name;
    customfile = fullfile(logdir, c);
    results(s,:) = [{sub}, count_cet_trials(customfile)];
end

%% Save output

T = table(results);
T = splitvars(T);
T.Properties.VariableNames = {'code', 'egoistic', 'altruistic', ...
    'dummy correct', 'rational correct'};

writetable(T, './output/cet-trials-counts-by-subject.csv');