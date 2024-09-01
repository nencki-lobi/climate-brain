%% Initial setup

workdir = getenv('HOME');
basedir = fullfile(workdir, 'neurogrieg'); % git repo location
bidsdir = fullfile(workdir, 'ds-ngr/bids'); % BIDS dataset location

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

close all
clearvars -except workdir basedir bidsdir