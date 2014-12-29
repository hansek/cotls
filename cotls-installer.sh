#!/bin/bash

COTLS_ALIAS="cotls"

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

        echo ""
        echo "COTLS installed successfully"
        echo "- You should reload .bashrc (execute \"source ~/.bashrc\") first"
        echo "- Voilà, use your new \"$COTLS_ALIAS\" command tool."
        echo ""

        exit
        ;;
esac