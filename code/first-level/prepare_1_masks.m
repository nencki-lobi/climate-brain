% List of open inputs
% Gunzip Files: File Set - cfg_files
% Gunzip Files: File Set - cfg_files
% Image Calculator: Output Filename - cfg_entry
% Image Calculator: Output Directory - cfg_files

workdir = pwd;
basedir = fullfile(pwd, 'neurogrieg'); % git repo location
datadir = fullfile(pwd, 'ds-ngr/bids/derivatives'); % fmriprep dataset location
resdir = fullfile(pwd, 'ds-ngr/bids/results'); % output location

D = dir(fullfile(datadir,'sub-*'));
D = D([D.isdir]);

subjects = {D.name};
nrun = numel(subjects); % enter the number of runs here

jobfile = {fullfile(basedir, 'code/first-level/prepare_1_masks_job.m')};

jobs = repmat(jobfile, 1, nrun);
inputs = cell(4, nrun);

for crun = 1:nrun

    sub = subjects{crun};
    subdir = fullfile(datadir, sub);

    mask = 'space-MNI152NLin2009cAsym_desc-brain_mask';

    inputs{1, crun} = {fullfile(subdir, 'func', [sub, '_task-cet_', mask, '.nii.gz'])}; % Gunzip Files: File Set - cfg_files
    inputs{2, crun} = {
        fullfile(subdir, 'func', [sub, '_task-stories_run-01_', mask, '.nii.gz'])
        fullfile(subdir, 'func', [sub, '_task-stories_run-02_', mask, '.nii.gz'])
        fullfile(subdir, 'func', [sub, '_task-stories_run-03_', mask, '.nii.gz'])
    }; % Gunzip Files: File Set - cfg_files
    inputs{3, crun} = [sub, '_task-stories_', mask, '.nii']; % Image Calculator: Output Filename - cfg_entry
    inputs{4, crun} = {fullfile(subdir, 'func')}; % Image Calculator: Output Directory - cfg_files
end

spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});

cd(workdir)
clearvars -except workdir subjects inputs
