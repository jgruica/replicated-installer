
#######################################
#
# alias.sh
#
# require common.sh
#
#######################################

#######################################
# Writes the alias command to the /etc/replicated.alias file
# Globals:
#   None
# Arguments:
#   Alias to write
# Returns:
#   REPLICATED_CONF_VALUE
#######################################
installAliasFile() {
    # "replicated" is no longer an alias, and we need to remove it from the file.
    # And we still need to create this file so replicated can write app aliases here.
    requireAliasFile

    _match="alias replicated=\".*\""
    if grep -q -s "$_match" /etc/replicated.alias; then
        # Replace in case we switched tags
        sed -i "s#$_match##" /etc/replicated.alias
    fi

    installAliasBashrc
}

#######################################
# Creates the /etc/replicated.alias file if it does not exist
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
requireAliasFile() {
    # Old script might have mounted this file when it didn't exist, and now it's a folder.
    if [ -d /etc/replicated.alias ]; then
        rm -rf /etc/replicated.alias
    fi
    if [ ! -e /etc/replicated.alias ]; then
        echo "# THIS FILE IS GENERATED BY REPLICATED. DO NOT EDIT!" > /etc/replicated.alias
    fi
}

#######################################
# Sources the /etc/replicated.alias file in the .bashrc
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
installAliasBashrc() {
    bashrc_file=
    if [ -f /etc/bashrc ]; then
        bashrc_file="/etc/bashrc"
    elif [ -f /etc/bash.bashrc ]; then
        bashrc_file="/etc/bash.bashrc"
    else
        echo "${RED}No global bashrc file found. Replicated command aliasing will be disabled.${NC}"
    fi

    if [ -n "$bashrc_file" ]; then
        if ! grep -q "/etc/replicated.alias" "$bashrc_file"; then
            cat >> "$bashrc_file" <<-EOF

if [ -f /etc/replicated.alias ]; then
    . /etc/replicated.alias
fi
EOF
        fi
    fi
}