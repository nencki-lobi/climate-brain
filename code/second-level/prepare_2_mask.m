% List of open inputs
% Image Calculator: Input Images - cfg_files
% Image Calculator: Output Directory - cfg_files

workdir = pwd;
basedir = fullfile(pwd, 'neurogrieg'); % git repo location
datadir = fullfile(pwd, 'ds-ngr/bids/derivatives'); % fmriprep dataset location
resdir = fullfile(pwd, 'ds-ngr/bids/results'); % output location

[spmdir, ~, ~] = fileparts(which('spm')); % SPM location

nrun = 1; % enter the number of runs here

jobfile = {fullfile(basedir, 'code/second-level/prepare_2_mask_job.m')};

jobs = repmat(jobfile, 1, nrun);
inputs = cell(2, nrun);

for crun = 1:nrun
    inputs{1, crun} = {fullfile(spmdir, 'tpm/TPM.nii,1')}; % Image Calculator: Input Images - cfg_files
    inputs{2, crun} = {datadir}; % Image Calculator: Output Directory - cfg_files
end

spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});

cd(workdir)
clearvars -except workdir inputs
