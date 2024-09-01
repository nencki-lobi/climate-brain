% List of open inputs
% Factorial design specification: Directory - cfg_files
% Factorial design specification: Scans - cfg_files
% Factorial design specification: Scans - cfg_files
% Factorial design specification: Scans - cfg_files
% Factorial design specification: Vector - cfg_entry
% Factorial design specification: Explicit Mask - cfg_files

%% Define subjects

D = dir(fullfile(datadir,'sub-*'));
D = D([D.isdir]);

subjects = {D.name};
exclude = {'sub-2112b', 'sub-2911e', 'sub-0712c', 'sub-0712b'}; % exclude subjects with excessive movement
included_subjects = setdiff(subjects, exclude);

%% Define groups

conditions = readtable(fullfile(basedir, '/output/condition-by-subject.csv'));

ANG = strcat('sub-', conditions.code(matches(conditions.condition,'ANG')));
HOP = strcat('sub-', conditions.code(matches(conditions.condition,'HOP')));
NEU = strcat('sub-', conditions.code(matches(conditions.condition,'NEU')));

ANG = intersect(ANG, included_subjects);
HOP = intersect(HOP, included_subjects);
NEU = intersect(NEU, included_subjects);

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

jobfile = {fullfile(basedir, 'code/second-level/batch_2_stories_anova_job.m')};

jobs = repmat(jobfile, 1, nrun);
inputs = cell(6, nrun);

for crun = 1:nrun
    inputs{1, crun} = {fullfile(resdir, 'stories-2-model-anova')}; % Factorial design specification: Directory - cfg_files
    inputs{2, crun} = strcat(resdir, '/', ANG, '/stories-1-model/con_0004.nii'); % Factorial design specification: Scans - cfg_files
    inputs{3, crun} = strcat(resdir, '/', HOP, '/stories-1-model/con_0004.nii'); % Factorial design specification: Scans - cfg_files
    inputs{4, crun} = strcat(resdir, '/', NEU, '/stories-1-model/con_0004.nii'); % Factorial design specification: Scans - cfg_files
    inputs{5, crun} = [fd(ANG); fd(HOP); fd(NEU)]'; % Factorial design specification: Vector - cfg_entry
    inputs{6, crun} = {fullfile(datadir, 'TPM_mask.nii')}; % Factorial design specification: Explicit Mask - cfg_files
end

spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});

%% Clear workspace

cd(workdir)
clearvars -except workdir basedir bidsdir datadir resdir spmdir
