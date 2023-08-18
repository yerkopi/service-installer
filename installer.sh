#!/bin/bash

USERNAME="yerkopi"
TARGET_FOLDER="/home/yerkopi"
ORGANIZATION="yerkopi"
INSTALL_SCRIPT="script/install.sh"
UPDATE_SCRIPT="script/install.sh"
SERVICES_JSON="$TARGET_FOLDER/services.json"
ENV_FILE=".env"

REPO_LIST=$(curl -s "https://api.github.com/orgs/$ORGANIZATION/repos" | grep '"name":' | awk -F'"' '{print $4}')

if [ ! -d "$TARGET_FOLDER" ]; then
    sudo mkdir "$TARGET_FOLDER"
fi

echo '{ "services": [] }' > "$SERVICES_JSON"

for REPO in $REPO_LIST; do
    if [[ $REPO == *"-service"* ]]; then
        sudo rm -r "$TARGET_FOLDER/$REPO"
        git clone "https://github.com/$ORGANIZATION/$REPO" "$TARGET_FOLDER/$REPO"
        
        read -rep $'Press ENTER for set $ENV_FILE: \n' env_content
        nano "$TARGET_FOLDER/$REPO/$ENV_FILE"

        if [ ! -s "$TARGET_FOLDER/$REPO/$ENV_FILE" ]; then
            echo "Env file ($ENV_FILE) is empty for $REPO."
            exit 1
        fi

        if ! grep -q -e '\n' "$TARGET_FOLDER/$REPO/$ENV_FILE"; then
            echo "Env file ($ENV_FILE) is not valid for $REPO."
            exit 1
        fi
            
        if [ -f "$TARGET_FOLDER/$REPO/$INSTALL_SCRIPT" ]; then
            sudo chmod +x "$TARGET_FOLDER/$REPO/$INSTALL_SCRIPT"
            "$TARGET_FOLDER/$REPO/$INSTALL_SCRIPT"
        else
            echo "Install script ($INSTALL_SCRIPT) not found for $REPO."
        fi
        if [ -f "$TARGET_FOLDER/$REPO/$UPDATE_SCRIPT" ]; then
            sudo chmod +x "$TARGET_FOLDER/$REPO/$UPDATE_SCRIPT"
            "$TARGET_FOLDER/$REPO/$UPDATE_SCRIPT"
        else
            echo "Update script ($UPDATE_SCRIPT) not found for $REPO."
        fi

    fi
done

echo "Services installed."
cat "$TARGET_FOLDER/services.json"
