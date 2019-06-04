#!/bin/bash

for i in {1970..2018}; do
	echo "YEAR: $i"
	./scripts/get_data.sh ${i};
done

find processed_data/* -type f -name 'errors_bip.out' | \
	xargs awk '{print $0", "FILENAME}' | \
	sed s1processed_data/11g1 | \
	sed s1/errors_bip.out11g1 > \
	    processed_data/all_errors_bip.out

find processed_data/* -type f -name 'walks_pa.out' | \
	xargs awk '{print $0", "FILENAME}' | \
	sed s1processed_data/11g1 | \
	sed s1/walks_pa.out11g1 > \
	    processed_data/all_walks_pa.out

find processed_data/* -type f -name 'strikeouts_pa.out' | \
	xargs awk '{print $0", "FILENAME}' | \
	sed s1processed_data/11g1 | \
	sed s1/strikeouts_pa.out11g1 > \
	    processed_data/all_strikeouts_pa.out

find processed_data/* -type f -name 'hits_bip.out' | \
	xargs awk '{print $0", "FILENAME}' | \
	sed s1processed_data/11g1 | \
	sed s1/hits_bip.out11g1 > \
	processed_data/all_hits_bip.out

