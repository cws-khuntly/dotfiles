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

[[ "${-}" != *i* ]] || [ -z "${PS1}" ] && return;

declare -x PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin";

[[ -f "${HOME}/.etc/logging.properties" ]] && source "${HOME}/.etc/logging.properties";
[[ -f "${HOME}/.lib/logger.sh" ]] && source "${HOME}/.lib/logger.sh";

if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

CNAME="$(basename "${BASH_SOURCE[0]}")";
FUNCTION_NAME="${CNAME}#loadProfile";

if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
    writeLogEntry "PERFORMANCE" "${CNAME}" "${FUNCTION_NAME}" "${LINENO}" "${FUNCTION_NAME} START: $(printf "%($(printf "%s" "${TIMESTAMP_OPTS}"))T %s")" 2>/dev/null;

    start_epoch=$(printf "%(%s)T");
fi

## load profile
for file_entry in ${HOME}/.profile.d/*
do
    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${LINENO}" "file_entry -> ${file_entry}" 2>/dev/null; fi

    [[ -z "${file_entry}" ]] && continue;

    if [[ -d "${file_entry}" ]]; then
        for dir_entry in ${HOME}/.profile.d/${file_entry}/*
        do
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${LINENO}" "dir_entry -> ${dir_entry}" 2>/dev/null; fi

            if [[ -r "${dir_entry}" ]] && [[ -s "${dir_entry}" ]]; then source "${dir_entry}"; fi

            [[ -n "${dir_entry}" ]] && unset -v dir_entry;
        done

        [[ -n "${dir_entry}" ]] && unset -v dir_entry;
        [[ -n "${file_entry}" ]] && unset -v file_entry;
    fi

    if [[ -r "${file_entry}" ]] && [[ -s "${file_entry}" ]]; then source "${file_entry}"; fi

    [[ -n "${dir_entry}" ]] && unset -v dir_entry;
    [[ -n "${file_entry}" ]] && unset -v file_entry;
done

[[ -n "${dir_entry}" ]] && unset -v dir_entry;
[[ -n "${file_entry}" ]] && unset -v file_entry;

source ${HOME}/.alias;
source ${HOME}/.functions;

showHostInfo;

## trap logout
trap 'source ~/.dotfiles/functions.d/F01-userProfile; logoutUser; exit' 0;

## run tmux (we're going to finally learn it)
## support both tmux and screen, use the flag files appropriately
[[ -n "$(compgen -c | grep -E -w ^tmux)" ]] && [[ -z "$(tmux info 2>/dev/null)" ]] && [[ -f ${HOME}/.etc/run-tmux ]] && tmux attach;
[[ -n "$(compgen -c | grep -E -w ^screen)" ]] && [[ -z "${STY}" ]] && [[ -f ${HOME}/.etc/run-screen ]] && screen -RR;

## make the umask sane
umask 022;

if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi
