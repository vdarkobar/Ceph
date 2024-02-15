#!/bin/bash

# Validate input arguments
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <POOL_NAME> <RBD_IMAGE> <INTERVAL>"
    exit 1
fi

POOL_NAME=$1
RBD_IMAGE=$2
INTERVAL=$3

# Determine snapshot prefix based on the interval
SNAPSHOT_PREFIX="${RBD_IMAGE}-snap-${INTERVAL}"

# Inline command to create a snapshot
snapshot_name="${SNAPSHOT_PREFIX}-$(date +%Y%m%d%H%M%S)"
rbd snap create ${POOL_NAME}/${RBD_IMAGE}@${snapshot_name}
echo "Snapshot created: ${snapshot_name}"

# Inline commands to rotate snapshots
case $INTERVAL in
    "15min") keep=4;;
    "hourly") keep=24;;
    "daily") keep=31;;
    "weekly") keep=8;;
    "monthly") keep=12;;
    *) echo "Invalid interval: $INTERVAL"; exit 1;;
esac

# List all snapshots for the RBD image, ensuring older snapshots are targeted for deletion
# The snapshots are listed and sorted in ascending order, which means older snapshots come first
all_snaps=$(rbd snap ls ${POOL_NAME}/${RBD_IMAGE} | grep "${SNAPSHOT_PREFIX}" | sort -n | awk '{print $2}')

# Calculate how many snapshots to delete
snap_count=$(echo "$all_snaps" | wc -l)
delete_count=$((snap_count - keep))

if [ $delete_count -gt 0 ]; then
    # Select the oldest snapshots based on the calculated count for deletion
    snaps_to_delete=$(echo "$all_snaps" | head -n $delete_count)
    for snap in $snaps_to_delete; do
        rbd snap rm "${POOL_NAME}/${RBD_IMAGE}@${snap}"
        echo "Snapshot deleted: ${snap}"
    done
else
    echo "No snapshots need to be deleted."
fi
