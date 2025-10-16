#!/usr/bin/env bash

#==============================================================================
#          FILE:  basefunctions.sh
#         USAGE:  Import file into script and call relevant functions
#   DESCRIPTION:  Base system functions that don't necessarily belong elsewhere
#
#       OPTIONS:  See usage section
#  REQUIREMENTS:  bash 4+
#          BUGS:  ---
#         NOTES:
#        AUTHOR:  Kevin Huntly <kmhuntly@gmail.com>
#       COMPANY:  ---
#       VERSION:  1.0
#       CREATED:  ---
#      REVISION:  ---
#==============================================================================

#=====  FUNCTION  =============================================================
#          NAME:  readPropertyFile
#   DESCRIPTION:  Reads a provided property file into the shell
#    PARAMETERS:  File
#       RETURNS:  0 if success, 1 otherwise
#==============================================================================
function post-install()
{
    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set -v; fi
    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set -v; fi

    local cname="post-install.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i return_code=0;
    local -i error_count=0;
    local -i start_epoch;
    local -i end_epoch;
    local -i runtime;

    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -n "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: source ${HOME}/.profile";
    fi

    source "${HOME}/.profile" 2>/dev/null || {
        if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to source ${HOME}/.profile";
        fi

        (( error_count += 1 ));
    }

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -n "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( end_epoch - start_epoch ));

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    [[ -n "${start_epoch}" ]] && unset start_epoch;
    [[ -n "${end_epoch}" ]] && unset end_epoch;
    [[ -n "${runtime}" ]] && unset runtime;
    [[ -n "${function_name}" ]] && unset function_name;
    [[ -n "${cname}" ]] && unset cname;

    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set +v; fi

    return "${return_code}";
}
