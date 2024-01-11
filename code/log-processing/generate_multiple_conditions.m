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

%% For CET part, visualise RTs for different event types

indir = './code/first-level/multiple-conditions-cet';
RT = nan(numel(subjects), 4);

for s = 1:numel(subjects)
    subject = subjects{s};
    load(fullfile(indir, ['sub-' subject '-multiple-conditions-cet.mat']))

    for i = 1:4
        RT(s, i) = mean(durations{i});
    end
end

histogram(RT(:,1))
hold on
histogram(RT(:,2))
hold on
histogram(RT(:,3))
hold on
histogram(RT(:,4))
legend('CET', 'dummy', 'CET leftovers', 'dummy leftovers')

saveas(gcf,'./output/cet-RTs-comparison.png')
close all

%% Clear workspace

clearvars -except logdir subjects