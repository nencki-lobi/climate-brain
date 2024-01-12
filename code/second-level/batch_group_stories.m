% List of open inputs
% Factorial design specification: Directory - cfg_files
% Factorial design specification: Scans - cfg_files
% Factorial design specification: Scans - cfg_files
% Factorial design specification: Scans - cfg_files

workdir = pwd;
basedir = fullfile(pwd, 'neurogrieg'); % git repo location
datadir = fullfile(pwd, 'ds-ngr/bids/derivatives'); % fmriprep dataset location
resdir = fullfile(pwd, 'ds-ngr/bids/results'); % output location

% D = dir(fullfile(datadir,'sub-*'));
% D = D([D.isdir]);
% 
% subjects = {D.name};

conditions = readtable(fullfile(basedir, '/output/condition-by-subject.csv'));

ANG = strcat('sub-', conditions.code(matches(conditions.condition,'ANG')));
HOP = strcat('sub-', conditions.code(matches(conditions.condition,'HOP')));
NEU = strcat('sub-', conditions.code(matches(conditions.condition,'NEU')));

nrun = 1; % enter the number of runs here

jobfile = {fullfile(basedir, 'code/second-level/batch_group_stories_job.m')};

jobs = repmat(jobfile, 1, nrun);
inputs = cell(4, nrun);

for crun = 1:nrun
    inputs{1, crun} = {fullfile(resdir, 'group-stories-model')}; % Factorial design specification: Directory - cfg_files
    inputs{2, crun} = strcat(resdir, '/', ANG, '/stories-model/con_0004.nii'); % Factorial design specification: Scans - cfg_files
    inputs{3, crun} = strcat(resdir, '/', HOP, '/stories-model/con_0004.nii'); % Factorial design specification: Scans - cfg_files
    inputs{4, crun} = strcat(resdir, '/', NEU, '/stories-model/con_0004.nii'); % Factorial design specification: Scans - cfg_files
end

spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});

cd(workdir)
clearvars -except workdir subjects inputs
