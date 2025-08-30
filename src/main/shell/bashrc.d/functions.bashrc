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

declare -Ax CONFIG_MAP=();

#=====  FUNCTION  =============================================================
#          NAME:  readPropertyFile
#   DESCRIPTION:  Reads a provided property file into the shell
#    PARAMETERS:  File
#       RETURNS:  0 if success, 1 otherwise
#==============================================================================
function readPropertyFile()
{
    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set -v; fi

    local cname="basefunctions.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i return_code=0;
    local -i error_count=0;
    local property_name;
    local property_value;
    local config_file;
    local -i start_epoch;
    local -i end_epoch;
    local -i runtime;

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

    (( ${#} != 1 )) && return 3;

    config_file="${1}";

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "config_file -> ${config_file}";
    fi

    mapfile -t config_entries < "${config_file}";

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "config_entries -> ${config_entries[*]}";
    fi

    if (( ${#config_entries[*]} == 0 )); then
        (( error_count += 1 ));

        if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "No entries found in property file ${config_file}";
        fi
    else
        for entry in "${config_entries[@]}"; do
            [[ -z "${entry}" ]] && continue;
            [[ "${entry}" =~ ^# ]] && continue;

            if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "entry -> ${entry}";
            fi

            if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "property_name -> ${property_name}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "property_value -> ${property_value}";
            fi

            property_name="$(cut -d "=" -f 1 <<< "${entry}" | xargs)";
            property_value="$(cut -d "=" -f 2- <<< "${entry}" | xargs)";

            CONFIG_MAP["${property_name}"]="${property_value}";

            if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then\
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "CONFIG_MAP -> ${CONFIG_MAP[*]}";
            fi

            [[ -n "${property_name}" ]] && unset property_name;
            [[ -n "${property_value}" ]] && unset property_value;
            [[ -n "${entry}" ]] && unset entry;
        done
    fi

    if [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${property_name}" ]] && unset property_name;
    [[ -n "${property_value}" ]] && unset property_value;
    [[ -n "${entry}" ]] && unset entry;
    [[ -n "${config_file}" ]] && unset config_file;
    [[ -n "${config_entries[*]}" ]] && unset config_entries;

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" == "${_TRUE}" ]]; then
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

    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set +v; fi

    return "${return_code}";
}

#=====  FUNCTION  =============================================================
#          NAME:  waitForProcessFile
#   DESCRIPTION:  Pauses a process until an identified file exists
#    PARAMETERS:  File
#       RETURNS:  0 if success, 1 otherwise
#==============================================================================
function waitForProcessFile()
{
    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set -v; fi

    local cname="basefunctions.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i ret_code=0;
    local -i return_code=0;
    local -i error_count=0;
    local -i retry_counter=0;
    local watch_file;
    local -i sleep_time;
    local -i retry_count;
    local -i start_epoch;
    local -i end_epoch;
    local -i runtime;

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

    (( ${#} != 3 )) && return 3;

    watch_file="${1}";
    sleep_time="${2}";
    retry_count="${3}";

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "watch_file -> ${watch_file}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "sleep_time -> ${sleep_time}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "retry_count -> ${retry_count}";
    fi

    while [[ ! -f "${watch_file}" ]]; do
        (( retry_counter != retry_count )) && sleep "${sleep_time}";

        (( retry_counter += 1 ));

        continue
    done

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -f "${watch_file}" ]] && rm -f "${watch_file}";

    [[ -n "${ret_code}" ]] && unset ret_code;
    [[ -n "${error_count}" ]] && unset error_count;
    [[ -n "${retry_counter}" ]] && unset retry_counter;
    [[ -n "${watch_file}" ]] && unset watch_file;
    [[ -n "${sleep_time}" ]] && unset sleep_time;
    [[ -n "${retry_count}" ]] && unset retry_count;

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" == "${_TRUE}" ]]; then
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

    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set +v; fi

    return "${return_code}";
}

#=====  FUNCTION  =============================================================
#          NAME:  isNaN
#   DESCRIPTION:  Checks if the provided variable is a number
#    PARAMETERS:  Variable to check
#       RETURNS:  0 if true, 1 if false
#==============================================================================
function isNaN()
(
    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set -v; fi

    local cname="basefunctions.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i return_code=0;
    local -i error_count=0;
    local -i start_epoch;
    local -i end_epoch;
    local -i runtime;

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

    (( ${#} != 1 )) && return 3;

    [[ "${1}" =~ ^-?[0-9]+$ ]] || return_code=1;

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${error_count}" ]] && unset error_count;

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" == "${_TRUE}" ]]; then
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

    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set +v; fi

    return "${return_code}";
)

#=====  FUNCTION  =============================================================
#          NAME:  postcleanup
#   DESCRIPTION:  Checks if the provided variable is a number
#    PARAMETERS:  Variable to check
#       RETURNS:  0 if true, 1 if false
#==============================================================================
function postcleanup()
{
    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set -v; fi

    local cname="basefunctions.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i return_code=0;
    local -i error_count=0;
    local -i start_epoch;
    local -i end_epoch;
    local -i runtime;

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

    #
    # TODO
    #

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( end_epoch - start_epoch ));

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    [[ -n "${start_epoch}" ]] && unset -v start_epoch;
    [[ -n "${end_epoch}" ]] && unset -v end_epoch;
    [[ -n "${runtime}" ]] && unset -v runtime;
    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${cname}" ]] && unset -v cname;

    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set +v; fi

    return "${return_code}";
}

#=====  FUNCTION  =============================================================
#          NAME:  returnRandomCharacters
#   DESCRIPTION:  Returns a random string of alphanumeric characters
#    PARAMETERS:  Length of string, include special characters
#       RETURNS:  0 regardless of result.
#==============================================================================
function returnRandomCharacters()
{
    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set -v; fi

    local cname="basefunctions.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i return_code=0;
    local -i error_count=0;
    local -i ret_code=0;
    local -i string_count=1;
    local -i counter=0;
    local argument;
    local argument_name;
    local argument_value;
    local string_length;
    local use_special;
    local returned_characters;
    local -i start_epoch;
    local -i end_epoch;
    local -i runtime;

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

    #======  FUNCTION  ============================================================;
    #          NAME:  usage
    #   DESCRIPTION:
    #    PARAMETERS:  None
    #       RETURNS:  3
    #==============================================================================
    function usage()
    (
        if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set -x; fi
        if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set -v; fi

        local cname="F02-misc";
        local function_name="${cname}#${FUNCNAME[1]}";
        local return_code=3;

        if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        fi

        printf "%s %s\n" "${FUNCNAME[1]}" "Return a string of random characters" >&2;
        printf "%s %s\n" "Usage: ${FUNCNAME[1]}" "[ options ]" >&2;
        printf "    %s: %s\n" "--count=value| -c <value>" "The number of strings to generate." >&2;
        printf "    %s: %s\n" "--length=value| -l <value>" "Determines the length of the string to generate." >&2;
        printf "    %s: %s\n" "--special | -s" "Include special characters. If not specified, special characters are not utilized." >&2;

        if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
        fi

        [[ -n "${function_name}" ]] && unset -v function_name;
        [[ -n "${cname}" ]] && unset -v cname;

        if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set +x; fi
        if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set +v; fi

        return "${return_code}";
    )

    if (( ${#} == 0 )); then usage; return ${?}; fi

    while (( ${#} > 0 )); do
        if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided Argument -> ${1}";
        fi

        argument="${1}";

        if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "argument -> ${argument}";
        fi

        case "${argument}" in
            *=*)
                argument_name="$(cut -d "=" -f 1 <<< "${argument// }" | sed -e "s/--//g" -e "s/-//g")";
                argument_value="$(cut -d "=" -f 2 <<< "${argument}")";

                shift 1;
                ;;
            *)
                argument_name="$(cut -d "-" -f 2 <<< "${argument}")";
                argument_value="${2}";

                shift 2;
                ;;
        esac

        if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "argument_name -> ${argument_name}";
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "argument_value -> ${argument_value}";
        fi

        case "${argument_name}" in
            count|c)
                if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Setting string_count...";
                fi

                string_count="${argument_value}";

                if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "string_count -> ${string_count}";
                fi
                ;;
            length|l)
                if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Setting string_length...";
                fi

                string_length="${argument_value}";

                if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "string_length -> ${string_length}";
                fi
                ;;
            special|s)
                if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Setting use_special...";
                fi

                use_special="${_TRUE}";

                if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "use_special -> ${use_special}";
                fi
                ;;
            help|\?|h)
                [[ -n "${function_name}" ]] && unset -v function_name;
                [[ -n "${ret_code}" ]] && unset -v ret_code;

                usage;
                return_code="${?}";

                function_name="${cname}#${FUNCNAME[0]}";

                if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "usage -> ret_code -> ${ret_code}";
                fi

                if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set +x; fi
                if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set +v; fi
                ;;
            *)
                if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An invalid option has been provided and has been ignored. Option -> ${argument_name}, Value -> ${argument_value}";
                    writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An invalid option has been provided and has been ignored. Option -> ${argument_name}, Value -> ${argument_value}";
                fi
                ;;
        esac
    done

    if [[ -z "$(compgen -c | grep -Ew "(^apg)" | sort | uniq)" ]]; then
        if [[ -n "${use_special}" ]] && [[ "${use_special}" == "${_TRUE}" ]]; then
            if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: apg -a 1 -m ${string_length} | tail -n 1";
            fi

            returned_characters="$(apg -a 1 -m "${string_length}" | tail -n 1)";
        else
            if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: apg -a 0 -m ${string_length} | tail -n 1";
            fi

            returned_characters="$(apg -a 0 -m "${string_length}" | tail -n 1)";
        fi
    else
        while (( counter <= string_count )); do
            if [[ -n "${use_special}" ]] && [[ "${use_special}" == "${_TRUE}" ]]; then
                returned_characters="$(tr -cd '[:graph:]' < /dev/urandom | head -c "${string_length}")";
        else
                returned_characters="$(tr -cd '[:alnum:]' < /dev/urandom | head -c "${string_length}")";
            fi
        done
    fi

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "returned_characters -> ${returned_characters}";
    fi

    if [[ -n "${returned_characters}" ]] && (( return_code != 0 )); then printf "%s\n" "${returned_characters}"; fi

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${string_count}" ]] && unset -v string_count;
    [[ -n "${counter}" ]] && unset -v counter;
    [[ -n "${argument}" ]] && unset -v argument;
    [[ -n "${argument_name}" ]] && unset -v argument_name;
    [[ -n "${argument_value}" ]] && unset -v argument_value;
    [[ -n "${string_length}" ]] && unset -v string_length;
    [[ -n "${use_special}" ]] && unset -v use_special;
    [[ -n "${returned_characters}" ]] && unset -v returned_characters;

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")";
        runtime=$(( end_epoch - start_epoch ))

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    [[ -n "${start_epoch}" ]] && unset -v start_epoch;
    [[ -n "${end_epoch}" ]] && unset -v end_epoch;
    [[ -n "${runtime}" ]] && unset -v runtime;
    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${cname}" ]] && unset -v cname;

    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set +v; fi

    return "${return_code}";
}

#=====  FUNCTION  =============================================================
#          NAME:  showHostInfo
#   DESCRIPTION:  Re-loads existing dotfiles for use
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function showHostInfo()
{
    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]} ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]} == "${_TRUE}" ]]; then set -v; fi

    local cname="userprofile.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i return_code=0;
    local -i error_count=0;
    local host_system_name;
    local host_ip_address;
    local host_kernel_version;
    local host_cpu_count;
    local host_cpu_info;
    local host_memory_size;
    local swap_memory_size;
    local system_process_count;
    local user_disk_usage;
    local user_process_count;
    local -i start_epoch;
    local -i end_epoch;
    local -i runtime;

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

    ## system information
    host_system_name="$(hostname -s | tr '[:upper:]' '[:lower:]')";
    host_ip_address=("$(ip addr show 2> /dev/null | grep "inet" | grep -E -v "(inet6|127.0.0.1)" | awk '{print $2}' | tr "\n" " ")");
    host_kernel_version="$(uname -r)";
    host_cpu_count=$(grep -c "model name" /proc/cpuinfo);
    host_cpu_info="$(grep -E "model name" /proc/cpuinfo | uniq | cut -d ":" -f 2 | sed -e 's/^ *//g;s/ *$//g' | tr -s " ")";
    host_memory_size="$(( $(grep -E MemTotal /proc/meminfo | awk '{print $2}') / 1024 ^ 2 ))";
    swap_memory_size="$(( $(grep -E SwapTotal /proc/meminfo | awk '{print $2}') / 1024 ^ 2 ))";
    system_process_count=$(ps -ef | tail -n +1 | wc -l | awk '{print $1}');

    ## user information
    user_disk_usage=$(du -sh "${HOME}" 2> /dev/null | awk '{print $1}');
    user_process_count=$(ps -ef | tail -n +1 | grep -v grep | grep -c "${LOGNAME}");

    clear;

    printf "%s\n" "+-------------------------------------------------------------------+" >&2;
    printf "%40s %s\n" "Welcome to" "${host_system_name}" >&2;
    printf "%s\n" "+-------------------------------------------------------------------+" >&2;
    printf "\n" >&2;
    printf "%s\n" "+---------------------- System Information -------------------------+" >&2;
    printf "%-16s : %-10s\n" "+ IP Address" "${host_ip_address[@]}" >&2;
    printf "%-16s : %-10s\n" "+ Kernel version" "${host_kernel_version}" >&2;
    printf "%-16s : %-10s\n" "+ CPU" "${host_cpu_count} / ${host_cpu_info}" >&2;
    printf "%-16s : %-10d\n" "+ Processes" "${system_process_count}" >&2;
    printf "%-16s : %-10d MB\n" "+ Memory" "${host_memory_size}" >&2;
    printf "%-16s : %-10d MB\n" "+ Swap" "${swap_memory_size}" >&2;
    printf "%s\n" "+-------------------------------------------------------------------+" >&2;
    printf "\n" >&2;
    printf "%s\n" "+----------------------- User Information --------------------------+" >&2;
    printf "%-16s : %-10s\n" "+ Username" "${LOGNAME}" >&2;
    printf "%-16s : %-10s %s in %s\n" "+ Disk Usage" "You're currently using" "${user_disk_usage}" "${HOME}" >&2;
    printf "%-16s : %-10d\n" "+ Processes" "${user_process_count}" >&2;
    printf "%s\n" "+-------------------------------------------------------------------+" >&2;

    if [[ -r /etc/motd ]] && [[ -s /etc/motd ]]; then
        printf "\n" >&2;
        printf "%s\n" "+------------------------------ MOTD -------------------------------+" >&2;
        cat /etc/motd >&2;
        printf "%s\n" "+-------------------------------------------------------------------+" >&2;
    fi

    printf "\n" >&2;

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${host_system_name}" ]] && unset -v host_system_name;
    [[ -n "${host_ip_address[*]}" ]] && unset -v host_ip_address;
    [[ -n "${host_kernel_version}" ]] && unset -v host_kernel_version;
    [[ -n "${host_cpu_count}" ]] && unset -v host_cpu_count;
    [[ -n "${host_cpu_info}" ]] && unset -v host_cpu_info;
    [[ -n "${host_memory_size}" ]] && unset -v host_memory_size;
    [[ -n "${swap_memory_size}" ]] && unset -v swap_memory_size;
    [[ -n "${system_process_count}" ]] && unset -v system_process_count;
    [[ -n "${user_disk_usage}" ]] && unset -v user_disk_usage;
    [[ -n "${user_process_count}" ]] && unset -v user_process_count;

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( end_epoch - start_epoch ));

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    [[ -n "${start_epoch}" ]] && unset -v start_epoch;
    [[ -n "${end_epoch}" ]] && unset -v end_epoch;
    [[ -n "${runtime}" ]] && unset -v runtime;
    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${cname}" ]] && unset -v cname;

    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]} ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]} == "${_TRUE}" ]]; then set +v; fi

    return "${return_code}";
}

#=====  FUNCTION  =============================================================
#          NAME:  setPromptCommand
#   DESCRIPTION:  Sets the PROMPT_COMMAND variable for bash shells
#    PARAMETERS:  None
#       RETURNS:  0 regardless of result
#==============================================================================
function setPromptCommand()
{
    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]} ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]} == "${_TRUE}" ]]; then set -v; fi

    local cname="userprofile.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i return_code=0;
    local color_off='\[\e[0m\]';
    local color_red='\[\e[91m\]';
    local color_green='\[\e[32m\]';
    local color_yellow='\[\e[93m\]';
    local color_blue='\[\e[94m\]';
    local PS2="continue -> ";
    local PS3="Enter selection: ";
    local PS4='[Time: \D{%F %T} ] [Thread: ${0}] [Log: -] [Level: TRACE] - [File: ${FUNCNAME[0]:-${SHELL}}] [Method: -] - ';
    local start_epoch
    local -i end_epoch;
    local -i runtime;

    git_status="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)";
    real_user="$(grep -w "${EUID}" /etc/passwd | cut -d ":" -f 1)";

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    [[ -n "${PS1}" ]] && unset -v PS1;

    #
    # history things
    # UNTESTED
    #
    history -n; history -a; history -r;

    case "$(uname -s)" in
        [Cc][Yy][Gg][Ww][Ii][Nn]*)
            case "${git_status}" in
                "") PS1='${color_green}[\u:\H] : <${color_yellow}\w${color_green}>\n\n \$ ${color_off}'; ;;
                *) PS1='${color_green}[\u:\H] : <${color_yellow}\w (${color_blue}${git_status})${color_green}>\n\n \$ ${color_off}'; ;;
            esac
            ;;
        *)
            case "${real_user}" in
                "${LOGNAME}")
                    case "${git_status}" in
                        "") PS1='${color_green}[\u:\H] : <${color_yellow}\w${color_green}>\n\n\$ ${color_off}'; ;;
                        *) PS1='${color_green}[\u:\H] : <${color_yellow}\w (${color_blue}${git_status})${color_green}>\n\n \$ ${color_off}'; ;;
                    esac
                    ;;
                *)
                    case "${git_status}" in
                        "") PS1='${color_red}NOTE: you are ${real_user}${color_off}\n${color_green}[\u as ${color_red}${real_user}${color_green}:\H] : <${color_yellow}\w${color_green}>\n\n \$ ${color_off}'; ;;
                        *) PS1='${color_red}NOTE: you are ${real_user}${color_off}\n${color_green}[\u as ${color_red}${real_user}${color_green}:\H] : <${color_yellow}\w (${color_blue}${git_status})${color_green}>\n\n \$ ${color_off}';
                    esac
                    ;;
            esac
    esac

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${color_off}" ]] && unset -v color_off;
    [[ -n "${color_red}" ]] && unset -v color_red;
    [[ -n "${color_green}" ]] && unset -v color_green;
    [[ -n "${color_yellow}" ]] && unset -v color_yellow;
    [[ -n "${color_blue}" ]] && unset -v color_blue;
    [[ -n "${git_status}" ]] && unset -v git_status;
    [[ -n "${real_user}" ]] && unset -v real_user;

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( end_epoch - start_epoch ));

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    [[ -n "${start_epoch}" ]] && unset -v start_epoch;
    [[ -n "${end_epoch}" ]] && unset -v end_epoch;
    [[ -n "${runtime}" ]] && unset -v runtime;
    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${cname}" ]] && unset -v cname;

    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]} ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]} == "${_TRUE}" ]]; then set +v; fi

    return "${return_code}";
}

#=====  FUNCTION  =============================================================
#          NAME:  runLoginCommands
#   DESCRIPTION:  Executes necessary commands during user logout
#    PARAMETERS:  None
#       RETURNS:  0 regardless of result
#==============================================================================
function runLoginCommands()
{
    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]} ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]} == "${_TRUE}" ]]; then set -v; fi

    local cname="userprofile.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local primary_file="${HOME}/etc/logincmds.properties";
    local secondary_file="${HOME}/workspace/etc/logincmds.properties";
    local -i return_code=0;
    local -i error_count=0;
    local -i ret_code=0;
    local cmd_entry;
    local cmd_binary;
    local cmd_args;
    local cmd_output;
    local -i start_epoch;
    local -i end_epoch;
    local -i runtime;

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "primary_file -> ${primary_file}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "secondary_file -> ${secondary_file}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

    #
    # read the commands file and execute each
    #
    for file in ${primary_file} ${secondary_file}; do
        if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "file -> ${file}";
        fi

        if [[ -s "${file}" ]]; then
            for cmd_entry in $(< "${file}"); do
                [[ -z "${cmd_entry}" ]] && continue;
                [[ "${cmd_entry}" =~ ^\# ]] && continue;

                if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cmd_entry -> ${cmd_entry}";
                fi

                cmd_binary="$(cut -d "|" -f 1 <<< "${cmd_entry}")";
                cmd_args="$(cut -d "|" -f 2 <<< "${cmd_entry}")";

                if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cmd_binary -> ${cmd_binary}";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cmd_args -> ${cmd_args}";
                fi

                if [[ -n "$(command -v "${cmd_binary}")" ]]; then
                    [[ -n "${cmd_output}" ]] && unset -v cmd_output;
                    [[ -n "${ret_code}" ]] && unset -v ret_code;

                    cmd_output="$("${cmd_binary}" "${cmd_args}")"; local cmd_output;
                    ret_code="${?}";

                    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cmd_output -> ${cmd_output}";
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${cmd_binary} -> ret_code -> ${ret_code}";
                    fi

                    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                        (( error_count += 1 ));

                        if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Execution of command ${cmd_binary} with arguments ${cmd_args} failed with return code ${ret_code}.";
                            writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Execution of command ${cmd_binary} with arguments ${cmd_args} failed with return code ${ret_code}.";
                        fi

                        continue;
                    fi
                fi

                [[ -n "${file}" ]] && unset -v file;
                [[ -n "${cmd_args}" ]] && unset -v cmd_args;
                [[ -n "${cmd_binary}" ]] && unset -v cmd_binary;
                [[ -n "${ret_code}" ]] && unset -v ret_code;
            done
        fi
    done

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${file}" ]] && unset -v file;
    [[ -n "${primary_file}" ]] && unset -v primary_file;
    [[ -n "${secondary_file}" ]] && unset -v secondary_file;
    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${cmd_entry}" ]] && unset -v cmd_entry;
    [[ -n "${cmd_binary}" ]] && unset -v cmd_binary;
    [[ -n "${cmd_args}" ]] && unset -v cmd_args;
    [[ -n "${cmd_output}" ]] && unset -v cmd_output;

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( end_epoch - start_epoch ));

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    [[ -n "${start_epoch}" ]] && unset -v start_epoch;
    [[ -n "${end_epoch}" ]] && unset -v end_epoch;
    [[ -n "${runtime}" ]] && unset -v runtime;
    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${cname}" ]] && unset -v cname;

    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]} ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]} == "${_TRUE}" ]]; then set +v; fi

    return "${return_code}";
}

#=====  FUNCTION  =============================================================
#          NAME:  logoutUser
#   DESCRIPTION:  Executes necessary commands during user logout
#    PARAMETERS:  None
#       RETURNS:  0 regardless of result
#==============================================================================
function logoutUser()
{
    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]} ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]} == "${_TRUE}" ]]; then set -v; fi

    local cname="userprofile.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i return_code=0;
    local -i error_count=0;
    local -i start_epoch;
    local -i end_epoch;
    local -i runtime;

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

    ## turn off ssh-agent and keychain
    [[ -n "$(pidof ssh-agent)" ]] && pkill ssh-agent;
    [[ -f "${HOME}/.ssh/ssh-agent.env" ]] && rm -f "${HOME}/.ssh/ssh-agent.env";

    ## write history
    history -n; history -a; history -r;

    ## clear terminal scrollback
    printf "\033c";

    (( error_count != 0 )) && return_code="${error_count}";

    [[ -n "${error_count}" ]] && unset -v error_count;

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( end_epoch - start_epoch ));

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${start_epoch}" ]] && unset -v start_epoch;
    [[ -n "${end_epoch}" ]] && unset -v end_epoch;
    [[ -n "${runtime}" ]] && unset -v runtime;
    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${cname}" ]] && unset -v cname;

    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]} ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]} == "${_TRUE}" ]]; then set +v; fi

    return "${return_code}";
}

#=====  FUNCTION  =============================================================
#          NAME:  mkcd
#   DESCRIPTION:  Creates a directory and then changes into it
#    PARAMETERS:  Directory to create
#       RETURNS:  0 if success, 1 otherwise
#==============================================================================
function addservice()
{
    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]} ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]} == "${_TRUE}" ]]; then set -v; fi

    local cname="userprofile.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i return_code=0;
    local -i error_count=0;
    local -i ret_code=0;
    local service_name;
    local cmd_output;
    local -i start_epoch;
    local -i end_epoch;
    local -i runtime;

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

    #======  FUNCTION  ============================================================
    #          NAME:  usage
    #   DESCRIPTION:
    #    PARAMETERS:  None
    #       RETURNS:  3
    #==============================================================================;
    function usage()
    (
        if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set -x; fi
        if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]} ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]} == "${_TRUE}" ]]; then set -v; fi

        local cname="userprofile.sh";
        local function_name="${cname}#${FUNCNAME[1]}";
        local return_code=3;

        if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        fi

        printf "%s %s\n" "${FUNCNAME[1]}" "Enable and start a user-level systemd service." >&2;
        printf "%s %s\n" "Usage: ${FUNCNAME[1]}" "[ service name ]" >&2;
        printf "    %s: %s\n" "<directory name>" "The name of the service to enable and start." >&2;

        if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
        fi

        [[ -n "${function_name}" ]] && unset -v function_name;
        [[ -n "${cname}" ]] && unset -v cname;

        if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set +x; fi
        if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]} ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]} == "${_TRUE}" ]]; then set +v; fi

        return "${return_code}";
    )

    if (( ${#} == 0 )); then usage; return ${?}; fi

    service_name="${1}";

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "service_name -> ${service_name}";
    fi

    [[ -n "${cmd_output}" ]] && unset -v cmd_output;
    [[ -n "${ret_code}" ]] && unset -v ret_code;

    cmd_output="$(systemctl --user enable --now "${service_name}")";
    ret_code="${?}";

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cmd_output -> ${cmd_output}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "systemctl / ${service_name} -> ret_code -> ${ret_code}";
    fi

    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
        [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

        if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
            writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to enable/start ${service_name}";
        fi
    else
        if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                writeLogEntry "CONSOLE" "STDOUT" "${$}" "${cname}" "${LINENO}" "${function_name}" "Service ${service_name} has been enabled and started.";
        fi
    fi

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${service_name}" ]] && unset -v service_name;
    [[ -n "${cmd_output}" ]] && unset -v cmd_output;

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")";
        runtime=$(( end_epoch - start_epoch ))

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    [[ -n "${start_epoch}" ]] && unset -v start_epoch;
    [[ -n "${end_epoch}" ]] && unset -v end_epoch;
    [[ -n "${runtime}" ]] && unset -v runtime;
    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${cname}" ]] && unset -v cname;

    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]} ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]} == "${_TRUE}" ]]; then set +v; fi

    return "${return_code}";
}
