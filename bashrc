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

[[ -f ${HOME}/.profile ]] && source "${HOME}/.profile";

## load the logger
if [[ -r "${HOME}/lib/system/logger.sh" ]] && [[ -s "${HOME}/lib/system/logger.sh" ]]; then
    source "${HOME}/lib/system/logger.sh"; ## if its here, override the above and use it
elif [[ -r "/usr/local/bin/logger.sh" ]] && [[ -s "/usr/local/bin/logger.sh" ]]; then
    source "/usr/local/bin/logger.sh"; ## if its here, use it
else
    printf "\e[00;31m%s\e[00;32m\n" "Unable to load logger. No logging enabled!" >&2;
fi

if [[ -z "$(command -v "writeLogEntryToFile")" ]]; then
    printf "\e[00;31m%s\033[0m\n" "Failed to load logging configuration. No logging available!" >&2; declare LOGGING_LOADED="${_FALSE}";
fi

if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
    START_EPOCH="$(date +"%s")";

    if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "${FUNCTION_NAME} START: $(date -d @"${START_EPOCH}" +"${TIMESTAMP_OPTS}")";
    fi
fi

if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "EXEC: source ${HOME}/.profiles";
    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "EXEC: source ${HOME}/.alias";
    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "EXEC: source ${HOME}/.alias";
fi

source "${HOME}/.profiles";
source "${HOME}/.alias";
source "${HOME}/.alias";

if [[ -z "${isReloadRequest}" ]] || [[ "${isReloadRequest}" == "${_FALSE}" ]]; then
    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "EXEC: showHostInfo";
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "EXEC: runLoginCommands";
    fi

    showHostInfo;
    runLoginCommands;
fi

## trap logout
trap 'logoutUser; exit' EXIT;

## make the umask sane
umask 022;

if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
    END_EPOCH="$(date +"%s")"
    RUNTIME=$(( END_EPOCH - START_EPOCH ));

    writeLogEntry "FILE" "PERFORMANCE" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "${FUNCTION_NAME} END: $(date -d "@${END_EPOCH}" +"${TIMESTAMP_OPTS}")";
    writeLogEntry "FILE" "PERFORMANCE" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "${FUNCTION_NAME} TOTAL RUNTIME: $(( RUNTIME / 60)) MINUTES, TOTAL ELAPSED: $(( RUNTIME % 60)) SECONDS";
fi

if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

[[ -n "${FILE}" ]] && unset -v FILE;
[[ -n "${SUBDIR}" ]] && unset -v SUBDIR;
[[ -n "${FUNCTION_NAME}" ]] && unset -v FUNCTION_NAME;
[[ -n "${CNAME}" ]] && unset -v CNAME;
[[ -n "${START_EPOCH}" ]] && unset -v START_EPOCH;
[[ -n "${END_EPOCH}" ]] && unset -v END_EPOCH;
[[ -n "${RUNTIME}" ]] && unset -v RUNTIME;
