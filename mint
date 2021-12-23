#!/usr/bin/env bash

source argparse

##  Main installation script ##

# Example Usage #

# main --username "jared" --password "password" --noconfirm --all --configuration

arg_parse "$@"

echo "User: $USER_PLAIN"
echo "Password: $PASSWORD_PLAIN"
echo "Configuration file: $CONFIGURATION"

set -- "${POSITIONAL[@]}" # restore positional arguments

# Before setting alias #

[[ ! -z "${CP+x}" ]] && echo "[ERROR] CP should not be an export"

[[ ! -z "${CONFIGURATION+x}" ]] && source "$CONFIGURATION"

# After setting alias #

echo "$CP"
hello_world
