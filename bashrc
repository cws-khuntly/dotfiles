#!/usr/bin/env bash

#==============================================================================
#
#          FILE:  bash_profile
#         USAGE:  . bash_profile
#   DESCRIPTION:  Sets application-wide functions
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

CNAME="$(basename "${BASH_SOURCE[0]}")";
FUNCTION_NAME="${CNAME}#bashrc";

[[ "$-" != *i* ]] || [ -z "${PS1}" ] && return;

if [[ -f "/etc/bashrc" ]] && [[ -r "/etc/bashrc" ]] && [[ -s "/etc/bashrc" ]]; then source "/etc/bashrc"; fi
if [[ -d "${HOME}/.dotfiles/bashrc.d" ]]; then for rc in "${HOME}/.dotfiles/bashrc.d/"*; do if [[ -f "${rc}" ]] && [[ -r "${rc}" ]] && [[ -s "${rc}" ]]; then source "${rc}"; [[ -n "${rc}" ]] && unset -v rc; fi done fi

if [[ -z "${isReloadRequest}" ]] || [[ "${isReloadRequest}" == "${_FALSE}" ]]; then
    if [[ -f "/etc/motd" ]] && [[ -r "/etc/motd" ]] && [[ -s "/etc/motd" ]]; then
        printf "%s\n\n" "Message of the day:";

        cat /etc/motd;
    fi

    runLoginCommands;
fi

## make the umask sane
umask 022;

[[ -n "${FILE}" ]] && unset -v FILE;
[[ -n "${SUBDIR}" ]] && unset -v SUBDIR;
[[ -n "${FUNCTION_NAME}" ]] && unset -v FUNCTION_NAME;
[[ -n "${CNAME}" ]] && unset -v CNAME;
[[ -n "${START_EPOCH}" ]] && unset -v START_EPOCH;
[[ -n "${END_EPOCH}" ]] && unset -v END_EPOCH;
[[ -n "${RUNTIME}" ]] && unset -v RUNTIME;
