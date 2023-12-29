#create project's directory using dcm2bids_scaffold
#then use xnat-get to download data from XNAT with subjects' ids (-d)

xnat-get -p AM23b -t ./neurogrieg/sourcedata --scans \
'anat_t1w' \
'SpinEchoFieldMap_mid_AP' \
'SpinEchoFieldMap_mid_PA' \
'task-stories r1' \
'task-stories r2' \
'task-stories r3' \
'task-cet' \
-d -a 2023-11-27
