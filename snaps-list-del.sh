#!/bin/bash

clear

echo
echo "This script provides a utility for managing Ceph snapshots within a Proxmox VE environment." 
echo "Lists the current Ceph snapshot counts for each disk within a specified Ceph pool." 
echo "Offers the user the option to delete these snapshots." 
echo "Proxmox snapshots will be listed but NOT deleted."
echo 
echo "Please use this tool with caution, as deleting Ceph snapshots cannot be undone."
echo

# Prompt for pool name
read -p "Enter pool name to list CEPH snapshots: " POOL_NAME
echo

# Function to get and list snapshot count per disk
list_snapshots() {
    # Get a list of images and their snapshots
    rbd du --pool "${POOL_NAME}" --format=json > /tmp/snapshot_info.json

    echo "Snapshot counts per disk:"
    if jq -e '.images' /tmp/snapshot_info.json > /dev/null 2>&1; then
        # For each disk, count the number of unique snapshots
        jq -r '.images[] | "\(.name) \(.snapshot)"' /tmp/snapshot_info.json | \
        sort | uniq | cut -d' ' -f1 | uniq -c | \
        while read -r COUNT IMAGE; do
            echo "Disk: ${IMAGE}, Snapshot Count: ${COUNT}"
        done
    else
        echo "Error: Invalid or unexpected JSON output from 'rbd du'. Check the pool and the command output."
    fi

    # Remove temporary file
    rm /tmp/snapshot_info.json
}

# Function to delete snapshots for a given disk
delete_snapshots() {
    while true; do
        read -p "Enter the disk name to delete its snapshots: " DISK_NAME
        # Assuming 'rbd snap purge' command is used to delete all snapshots for a disk
        # Add error handling to check if the disk exists
        if rbd snap purge "${POOL_NAME}/${DISK_NAME}"; then
            echo "All snapshots for disk ${DISK_NAME} have been deleted."
            break
        else
            echo "Error: Could not delete snapshots for disk ${DISK_NAME}. Please check the disk name and try again."
        fi
    done
}

# Initial list of snapshot counts per disk
list_snapshots

while true; do
    echo
    read -p "Do you want to delete snapshots? (y/n): " DELETE_SNAPSHOTS
    case $DELETE_SNAPSHOTS in
        [Yy]* )
            delete_snapshots
            clear
            list_snapshots
            ;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes (y) or no (n).";;
    esac
done
