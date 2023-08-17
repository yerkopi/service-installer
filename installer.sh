#!/bin/bash

USERNAME="yerkopi"
TARGET_FOLDER="/home/yerkopi"
ORGANIZATION="yerkopi"
INSTALL_SCRIPT="script/install.sh"

REPO_LIST=$(curl -s "https://api.github.com/orgs/$ORGANIZATION/repos" | grep '"name":' | awk -F'"' '{print $4}')

for REPO in $REPO_LIST; do
    if [[ $REPO == *"-service"* ]]; then
        git clone "https://github.com/$ORGANIZATION/$REPO" "$TARGET_FOLDER/$REPO"
        
        if [ -f "$TARGET_FOLDER/$REPO/$INSTALL_SCRIPT" ]; then
            sudo chmod +x "$TARGET_FOLDER/$REPO/$INSTALL_SCRIPT"
            "$TARGET_FOLDER/$REPO/$INSTALL_SCRIPT"
        else
            echo "Install script ($INSTALL_SCRIPT) not found for $REPO."
        fi
    fi
done

echo "Script completed."