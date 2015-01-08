#!/bin/bash

COTLS_ALIAS="cotls"

SYSTEM_COMPLETION_DIR="/etc/bash_completion.d/"

if [ -z "$INSTALL_PREFIX" ] ; then
    INSTALL_PREFIX=~/
fi

if [ -z "$REPO_NAME" ] ; then
    REPO_NAME=$COTLS_ALIAS
fi

if [ -z "$REPO_HOME" ] ; then
    REPO_HOME="http://github.com/hansek/cotls.git"
fi

EXEC_FILES="cotls.sh"


echo "### COTLS installer ###"
echo ""

case "$1" in
    help)
        echo "Usage: [environment] install.sh [install|uninstall]"
        echo "Environment:"
        echo "   INSTALL_PREFIX=$INSTALL_PREFIX"
        echo "   REPO_HOME=$REPO_HOME"
        echo "   REPO_NAME=$REPO_NAME"
        exit
        ;;

    *)
        # echo "Installing COTLS to $INSTALL_PREFIX$REPO_NAME"

        if [ -d "$INSTALL_PREFIX$REPO_NAME" -a -d "$INSTALL_PREFIX$REPO_NAME/.git" ] ; then
            echo "Using existing repo: $INSTALL_PREFIX$REPO_NAME"
        else
            echo "Cloning repo from GitHub to $INSTALL_PREFIX$REPO_NAME"
            git clone "$REPO_HOME" "$INSTALL_PREFIX$REPO_NAME"
        fi

        # for exec_file in $EXEC_FILES ; do
            chmod +x "$INSTALL_PREFIX$REPO_NAME/$EXEC_FILES"
        # done

        if ! grep --quiet "$COTLS_ALIAS=" ~/.bashrc
        then
            echo -e "\nalias $COTLS_ALIAS='$INSTALL_PREFIX$REPO_NAME/$EXEC_FILES'" >> ~/.bashrc
        fi

        OLD_COMPLETION_FILE="$SYSTEM_COMPLETION_DIR$COTLS_ALIAS"
        NEW_COMPLETION_FILE="$INSTALL_PREFIX$REPO_NAME/cotls_completion.sh"

        $(cmp --silent "$OLD_COMPLETION_FILE" "$NEW_COMPLETION_FILE")
        FILES_THE_SAME=$?

        if [ -d "$SYSTEM_COMPLETION_DIR" ] && [ ! -f "$OLD_COMPLETION_FILE" -o "$FILES_THE_SAME" -ne 0 ]
        then
            echo "Installing BASH completion file to: $OLD_COMPLETION_FILE"
            cp "$NEW_COMPLETION_FILE" "$OLD_COMPLETION_FILE"
        fi

        echo ""
        echo "COTLS installed successfully"
        echo "- You should reload .bashrc (execute \"source ~/.bashrc\") to alias will be active"
        echo "- You should reload BASH completion file (execute \"source $OLD_COMPLETION_FILE\") to autocompletion work"
        echo "- Voilà, use your new \"$COTLS_ALIAS\" command tool."
        echo ""

        exit
        ;;
esac