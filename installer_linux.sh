#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]
  then echo "Please enter your password:"
  sudo -k # make sure to ask for password on next sudo
  if sudo true; then
    echo "Correct password. Proceeding with installation."
  else
    echo "Incorrect password. Exiting."
    exit
  fi
fi

# Copy the script to /usr/local/bin and rename it to dkps
sudo cp dkps.sh /usr/local/bin/dkps

# Make the script executable
sudo chmod +x /usr/local/bin/dkps

echo "Installation completed. You can now use dkps from your command line."