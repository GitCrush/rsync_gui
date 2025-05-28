#!/bin/bash

# Check if zenity and rsync are installed
command -v zenity >/dev/null 2>&1 || { echo >&2 "Zenity is required but not installed. Please install zenity and try again."; exit 1; }
command -v rsync >/dev/null 2>&1 || { echo >&2 "Rsync is required but not installed. Please install rsync and try again."; exit 1; }

# Select origin folder
origin_folder=$(zenity --file-selection --directory --title="Select Origin Folder")
if [ $? -ne 0 ]; then
    zenity --error --text="No origin folder selected, operation cancelled."
    exit 1
fi

# Select target folder
target_folder=$(zenity --file-selection --directory --title="Select Target Folder")
if [ $? -ne 0 ]; then
    zenity --error --text="No target folder selected, operation cancelled."
    exit 1
fi

# Ask if user wants to delete files not in origin
zenity --question --title="Delete Option" --text="Delete files in target that are not in origin?" --ok-label="Yes" --cancel-label="No"
if [ $? -eq 0 ]; then
    delete_option="--delete"
else
    delete_option=""
fi

# Construct rsync command
rsync_command="rsync -avh --progress --update $delete_option \"$origin_folder/\" \"$target_folder/\""

# Display command to user before execution
zenity --question --title="Confirm Rsync Command" --text="The following command will be executed:\n$rsync_command\n\nProceed?" --ok-label="Proceed" --cancel-label="Cancel"
if [ $? -ne 0 ]; then
    zenity --info --text="Operation cancelled by user."
    exit 1
fi

# Execute rsync and log progress to console and GUI
(
    eval $rsync_command
) | tee /dev/tty | zenity --progress --pulsate --auto-close --no-cancel --title="Syncing..." --text="Syncing folders..."

# Notify completion
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    zenity --info --text="Sync completed successfully."
else
    zenity --error --text="There was an error during sync."
fi
