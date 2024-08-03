#!/bin/bash

if [ -f "autogit4unimoose.sh" ]; then
    read -p "Delete all for a new run? (y/n) " -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        tree
        rm -rf .git kigit.txt .gitignore index.html README.md install_ish.py dev_mode_flag_f.txt templates/ .vscode
        sleep 0
        echo
        echo
        gh repo delete $(basename "$PWD") --confirm
        sleep 0
        echo
        tree
        echo
        sleep 0
    fi
fi
