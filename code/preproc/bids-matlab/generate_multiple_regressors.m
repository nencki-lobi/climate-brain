%% Generate multiple regressors MAT files for each subject

extract_confounds_fmriprep(datadir, resdir, 'stories')
extract_confounds_fmriprep(datadir, resdir, 'cet')

%% Clear workspace

cd(workdir)
clearvars -except workdir basedir bidsdir datadir resdir spmdir
