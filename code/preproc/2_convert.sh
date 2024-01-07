#!/bin/bash

#Run in Docker on Calcus:
#docker run -it -u 1023:1023 -v /home/grieg:/data --entrypoint bash dcm2bids

# Assuming the directories are named AM23b1012i, AM23b1013a, etc.
for dir in sourcedata/AM*; do
	subj_id=$(basename "$dir" | sed 's/AM23b//')
	dcm2bids -d "$dir" -p "$subj_id" -c code/am23b.json --auto_extract_entities
done

