%% Initial setup

% The script assumes that your HOME directory is the root directory for the
% analysis. You can adjust this, as long as your setup follows the assumed
% directory structure (see below).

workdir = getenv('HOME');

%% Set paths

% Adjust `basedir` and `bidsdir` paths as needed. The remaining paths are
% defined as relative paths and must not change.
%
% The script assumes that `basedir` and `bidsdir` directories are in the
% same parent directory `workdir`. If your local setup is different, you
% can create symlinks to mimic the required setup.

basedir = fullfile(workdir, 'climate-brain'); % git repo location
bidsdir = fullfile(workdir, 'ds005460'); % BIDS dataset location
datadir = fullfile(bidsdir, 'derivatives/fmriprep'); % fmriprep derivatives location
resdir = fullfile(bidsdir, 'results'); % output location

[spmdir, ~, ~] = fileparts(which('spm')); % SPM location

%% Temporarily add all analysis code to MATLAB search path

addpath(genpath(fullfile(basedir, 'code')));

%% Run the analysis

cd(workdir)

batch_preproc
generate_multiple_conditions
generate_multiple_regressors
prepare_1_masks
batch_1_stories
batch_1_cet
prepare_2_mask
batch_2_stories_ttest
batch_2_stories_anova
batch_2_cet

clearvars -except workdir basedir bidsdir datadir resdir spmdir
