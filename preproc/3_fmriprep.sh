subj=${1##*-}
work=/home/grieg/work
export SINGULARITY_BINDPATH=/home/grieg/neurogrieg:/data:ro,/home/grieg/neurogrieg/derivatives:/out,$work:/work
unset ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS

/home/grieg/fmriprep_23_2.simg \
--nthreads 4 \
--omp-nthreads 4 \
--mem_mb 12000 \
--fs-license-file /data/code/license.txt \
--fs-no-reconall \
--participant-label $subj \
-w /work /data /out participant

rm -rf $work/fmriprep_wf/single_subject_${subj}_wf

