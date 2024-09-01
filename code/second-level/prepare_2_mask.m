% List of open inputs
% Image Calculator: Input Images - cfg_files
% Image Calculator: Output Directory - cfg_files

%% Run job

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

%% Clear workspace

cd(workdir)
clearvars -except workdir basedir bidsdir datadir resdir spmdir
