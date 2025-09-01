#!/usr/bin/env bash

#==============================================================================
#
#          FILE:  A999-custom
#         USAGE:  . A999-custom
#   DESCRIPTION:  Customizations
#
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Kevin Huntly <kmhuntly@gmail.com>
#       COMPANY:  ---
#       VERSION:  1.0
#       CREATED:  ---
#      REVISION:  ---
#
#==============================================================================

#
# completion
#
ssh_config_files=( "${HOME}/.ssh/config" "$(find ${HOME}/.ssh/config.d -type f)" )

for ssh_config_file in "${ssh_config_files[@]}"; do
    if [[ -f "${ssh_config_file}" ]] && [[ -r "${ssh_config_file}" ]] && [[ -s "${ssh_config_file}" ]]; then
        complete -o "default" -o "nospace" -W "$(grep -E "(^Host)" "${ssh_config_file}" | grep -Ev "([?*])" | cut -d " " -f 2- | tr ' ' '\n')" scp sftp ssh;
    fi

    [[ -n "${ssh_config_file}" ]] && unset -v ssh_config_file;
done
