%% Initial setup

logdir = './data/logs/';

%% Load questionnaire data

qdata = readtable('./data/questionnaires/subjects.csv');
qdata.Properties.VariableNames = ["sid","code"];

subjects = erase(qdata.code,'ngr');

%% Identify condition

nsubjects = numel(subjects);
nruns = 3;

ANG = {'ANG8', 'ANG20', 'ANG17', 'ANG30', 'ANG25', 'ANG6', 'ANG9', 'ANG1', 'ANG12', 'ANG3', 'ANG21', 'ANG7'};
HOP = {'HOP23', 'HOP15', 'HOP27', 'HOP13', 'HOP17', 'HOP26', 'HOP5', 'HOP11', 'HOP19', 'HOP7', 'HOP22', 'HOP16'};
NEU = {'NEU14', 'NEU30', 'NEU9', 'NEU15', 'NEU1', 'NEU21', 'NEU29', 'NEU23', 'NEU6', 'NEU12', 'NEU24', 'NEU11'};
CON = {'NEU26', 'NEU16', 'NEU4', 'NEU25', 'NEU3', 'NEU18', 'NEU10', 'NEU22', 'NEU17', 'NEU27', 'NEU2', 'NEU5'};

condition = cell(nsubjects,1);

for s = 1:nsubjects

    sub = subjects{s};
    cond = cell(nruns,1);

    for r = 1:3

        pat = [sub, '-stories_R', num2str(r), '*.log'];
        logfile = dir(fullfile(logdir, pat)).name;
        txt = readlines(fullfile(logdir, logfile));
        
        if any(contains(txt, ANG))
            cond(r) = {'ANG'};
        elseif any(contains(txt, HOP))
            cond(r) = {'HOP'};
        elseif any(contains(txt, NEU))
            cond(r) = {'NEU'};
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
T.Properties.VariableNames = {'code', 'condition'};
writetable(T, './output/condition-by-subject.csv')
