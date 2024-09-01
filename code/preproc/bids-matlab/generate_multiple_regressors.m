
workdir = pwd;
datadir = fullfile(pwd, 'ds-ngr/bids/derivatives'); % fmriprep dataset location
resdir = fullfile(pwd, 'ds-ngr/bids/results'); % output location

extract_confounds_fmriprep(datadir, resdir, 'stories')
extract_confounds_fmriprep(datadir, resdir, 'cet')

cd(workdir)
clearvars -except workdir