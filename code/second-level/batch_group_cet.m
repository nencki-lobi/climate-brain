% List of open inputs
% Factorial design specification: Directory - cfg_files
% Factorial design specification: Scans - cfg_files
% Contrast Manager: Name - cfg_entry

workdir = pwd;
basedir = fullfile(pwd, 'neurogrieg'); % git repo location
datadir = fullfile(pwd, 'ds-ngr/bids/derivatives'); % fmriprep dataset location
resdir = fullfile(pwd, 'ds-ngr/bids/results'); % output location

D = dir(fullfile(datadir,'sub-*'));
D = D([D.isdir]);

subjects = {D.name};

nrun = 1; % enter the number of runs here

jobfile = {fullfile(basedir, 'code/second-level/batch_group_cet_job.m')};

jobs = repmat(jobfile, 1, nrun);
inputs = cell(2, nrun);

for crun = 1:nrun
    inputs{1, crun} = {fullfile(resdir, 'group-cet-model')}; % Factorial design specification: Directory - cfg_files
    inputs{2, crun} = strcat(resdir, '/', subjects, '/cet-model/con_0003.nii')'; % Factorial design specification: Scans - cfg_files
    inputs{3, crun} = 'CET > dummy'; % Contrast Manager: Name - cfg_entry

    % inputs{1, crun} = {fullfile(resdir, 'group-dummy-model')}; % Factorial design specification: Directory - cfg_files
    % inputs{2, crun} = strcat(resdir, '/', subjects, '/cet-model/con_0004.nii')'; % Factorial design specification: Scans - cfg_files
    % inputs{3, crun} = 'dummy > CET'; % Contrast Manager: Name - cfg_entry
end

spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});

cd(workdir)
clearvars -except workdir subjects inputs
