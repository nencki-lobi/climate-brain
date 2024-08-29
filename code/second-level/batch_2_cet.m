% List of open inputs
% Factorial design specification: Directory - cfg_files
% Factorial design specification: Scans - cfg_files
% Factorial design specification: Vector - cfg_entry
% Contrast Manager: Name - cfg_entry
% Factorial design specification: Explicit Mask - cfg_files

workdir = pwd;
basedir = fullfile(pwd, 'neurogrieg'); % git repo location
datadir = fullfile(pwd, 'ds-ngr/bids/derivatives'); % fmriprep dataset location
resdir = fullfile(pwd, 'ds-ngr/bids/results'); % output location

%% Define subjects
D = dir(fullfile(datadir,'sub-*'));
D = D([D.isdir]);

subjects = {D.name};
exclude = {'sub-2112b', 'sub-2911e', 'sub-0712c','sub-0712b'}; % exclude subjects with excessive movement
included_subjects = setdiff(subjects, exclude);

%% Extract framewise displacement values
task = 'stories'; % Adjust here!

mriqc = fullfile(datadir, 'mriqc/group_bold.tsv');

T = readtable(mriqc, 'FileType', 'text', 'Delimiter', '\t');
T = T(contains(T.bids_name, task), ["bids_name", "fd_mean"]);

T.subject = extractBefore(T.bids_name, "_task");
T.subject = categorical(T.subject);

G = groupsummary(T, 'subject', 'mean', 'fd_mean');
G.Properties.VariableNames = {'subject', 'count', 'fd'};

fd = dictionary(G.subject, G.fd);

%% Run job
nrun = 1; % enter the number of runs here

jobfile = {fullfile(basedir, 'code/second-level/batch_2_cet_job.m')};

jobs = repmat(jobfile, 1, nrun);
inputs = cell(5, nrun);


for crun = 1:nrun
    inputs{1, crun} = {fullfile(resdir, 'cet-2-model')}; % Factorial design specification: Directory - cfg_files
    inputs{2, crun} = strcat(resdir, '/', included_subjects, '/cet-1-model/con_0003.nii')'; % Factorial design specification: Scans - cfg_files
    inputs{3, crun} = fd(included_subjects);% Factorial design specification: Vector - cfg_entry
    inputs{4, crun} =  {fullfile(basedir, 'code/second-level/tpm_grey_0.20.nii')}; % Factorial design specification: Explicit Mask - cfg_files'
    inputs{5, crun} = CET > dummy'; % Contrast Manager: Name - cfg_entry
end

spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});

cd(workdir)
clearvars -except workdir subjects inputs