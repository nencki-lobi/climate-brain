%% Initial setup

dicomdir = './data/dicom/';

%% Load questionnaire data

qdata = readtable('./data/questionnaires/demo-by-subject.csv');
qdata.Properties.VariableNames = ["sid","code","sex","age"];

subjects = erase(qdata.code,'ngr');

%% Load DICOMs

% https://www.mathworks.com/company/newsletters/articles/accessing-data-in-dicom-files.html
%
% dicominfo()
% dicomCollection()

%% Check for any missing or unwanted DICOMs

patterns = {'anat_t1w', 'SpinEchoFieldMap_mid_AP', 'SpinEchoFieldMap_mid_PA', ...
    'task_stories_r1', 'task_stories_r2', 'task_stories_r3', 'task_cet'};

dirs = dir(dicomdir);
dirs = dirs(~ismember({dirs.name},{'.','..','.DS_Store'}));

prefix = [dicomdir 'AM23b'];

for s = 1:numel(subjects)

    sub = subjects{s};

    files = dir([prefix sub]);
    files = files(~ismember({files.name},{'.','..','.DS_Store','._.DS_Store'}));
    
    spath = unique({files.folder});
    suffix = erase(spath, prefix);

    if ~any(strcmp(sub, suffix)) || numel(files) ~= numel(patterns)
        fprintf('\n Warning: %s \n', sub)
    end

    if strcmp(sub, suffix)
        for p = 1:numel(patterns)
    
            pattern = patterns{p};
    
            ismatch = contains({files.name}, pattern);
    
            if sum(ismatch) < 1
                fprintf('Missing `%s` \n', pattern)
            elseif sum(ismatch) > 1
                fprintf('More than one `%s` \n', pattern)
            end
        end
    else
        fprintf('Missing DICOM data for %s \n', sub)
    end
end