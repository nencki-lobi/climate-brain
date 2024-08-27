% List of open inputs
% fMRI model specification: Directory - cfg_files
% fMRI model specification: Scans - cfg_files
% fMRI model specification: Multiple conditions - cfg_files
% fMRI model specification: Multiple regressors - cfg_files
% fMRI model specification: Explicit mask - cfg_files

workdir = pwd;
basedir = fullfile(pwd, 'neurogrieg'); % git repo location
datadir = fullfile(pwd, 'ds-ngr/bids/derivatives'); % fmriprep dataset location
resdir = fullfile(pwd, 'ds-ngr/bids/results'); % output location

D = dir(fullfile(datadir,'sub-*'));
D = D([D.isdir]);

subjects = {D.name};
nrun = numel(subjects); % enter the number of runs here

jobfile = {fullfile(basedir, 'code/first-level/batch_1_cet_job.m')};

jobs = repmat(jobfile, 1, nrun);
inputs = cell(5, nrun);

for crun = 1:nrun

    sub = subjects{crun};

    mkdir(fullfile(resdir, sub, 'cet-1-model'))

    bold = 'space-MNI152NLin2009cAsym_desc-preproc_bold';
    mask = 'space-MNI152NLin2009cAsym_desc-brain_mask';

    inputs{1, crun} = {fullfile(resdir, sub, 'cet-1-model')}; % fMRI model specification: Directory - cfg_files
    inputs{2, crun} = {fullfile(datadir, sub, 'func', ['s6', sub, '_task-cet_', bold, '.nii'])}; % fMRI model specification: Scans - cfg_files
    inputs{3, crun} = {fullfile(basedir, 'code/first-level/multiple-conditions-cet', [sub, '-multiple-conditions-cet.mat'])}; % fMRI model specification: Multiple conditions - cfg_files
    inputs{4, crun} = {fullfile(resdir, sub, 'stats', [sub, '_task-cet_confounds.mat'])}; % fMRI model specification: Multiple regressors - cfg_files
    inputs{5, crun} = {fullfile(datadir, sub, 'func', [sub, '_task-cet_', mask, '.nii'])}; % fMRI model specification: Explicit mask - cfg_files

end

spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});

cd(workdir)
clearvars -except workdir subjects inputs
