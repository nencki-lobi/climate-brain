ml load fmriprep/24.1.0

subj=${1##*-}
work=/home/repo/grieg/work
unset ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS
#export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=6 # specify the number of threads you want to use

fmriprep /home/repo/grieg/neurogrieg_defaced /home/repo/grieg/neurogrieg_defaced/derivatives/fmriprep participant \
--nthreads 4 \
--omp-nthreads 4 \
--mem_mb 12000 \
--fs-license-file /home/repo/license.txt \
--fs-no-reconall \
--participant-label $subj \
--skip_bids_validation \
-w $work

rm -rf $work/fmriprep*_wf/*${subj}_wf

#fmriprep /path/to/your/data \ # this is the top level of your data folder
#         /path/to/your/data/derivatives \ # where you want fmriprep output to be saved
#         participant \ # this tells fmriprep to analyse at the participant level
#         --fs-license-file /path/to/your/freesurfer.txt \ # where the freesurfer license file is
#         --output-spaces T1w MNI152NLin2009cAsym fsaverage fsnative \ 
#         --participant-label 01 \ # put what ever participant labels you want to analyse
#         --nprocs 6 --mem 10000 \ # fmriprep can be greedy on the hpc, make sure it is not
#         --skip_bids_validation \ # its normally fine to skip this but do make sure your data are BIDS enough
#         -v # be verbal fmriprep, tell me what you are doing