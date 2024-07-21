#!/bin/bash

set -e

setup.sh

for i in {1..5}; do
	export RESTIC_TAGS_VAR="RESTIC_TAGS_$i"
	export RESTIC_TAGS="${!RESTIC_TAGS_VAR}"
	
	for var in RESTIC_TAGS; do
		[[ -z "${!var}" ]] && {
			echo "Finished forget successfully"
			exit 0
		}
	done

	echo "Forgetting old snapshots for database cluster $i"
	echo "Including all of the tags $RESTIC_TAGS"
	
	while ! restic forget \
			--compact \
			--tag="${RESTIC_TAGS}" \
			--keep-hourly="${RESTIC_KEEP_HOURLY:-24}" \
			--keep-daily="${RESTIC_KEEP_DAILY:-7}" \
			--keep-weekly="${RESTIC_KEEP_WEEKLY:-4}" \
			--keep-monthly="${RESTIC_KEEP_MONTHLY:-12}"; do
		echo "Sleeping for 10 seconds before retry..."
		sleep 10
	done

	echo "Finished forget for database cluster $i successfully"
done

echo "Finished forget successfully"