#!/bin/bash

set -e

setup.sh

echo "Pruning old snapshots"
while ! restic prune; do
	echo "Sleeping for 10 seconds before retry..."
	sleep 10
done

# Test repository and remove unwanted cache.
restic check --no-lock
rm -rf /tmp/restic-check-cache-*

echo 'Finished prune successfully'
