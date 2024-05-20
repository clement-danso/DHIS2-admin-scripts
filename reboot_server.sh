#!/bin/bash

# Check if the script is run with root/sudo privileges
if [ "$EUID" -ne 0 ]; then
  echo "This script needs to be run as root. Please use sudo or log in as root."
  exit 1
fi

# Display a message before rebooting
echo "Rebooting the server in 5 seconds..."
sleep 5

# Perform the reboot
reboot
