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
#          NAME:  waitForProcessFile
#   DESCRIPTION:  Pauses a process until an identified file exists
#    PARAMETERS:  File
#       RETURNS:  0 if success, 1 otherwise
#==============================================================================
function waitForProcessFile()
{
    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set -v; fi

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

    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -n "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

    (( ${#} != 3 )) && return 3;

    watch_file="${1}";
    sleep_time="${2}";
    retry_count="${3}";

    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
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

    [[ -f "${watch_file}" ]] && rm --force -- "${watch_file}";

    [[ -n "${ret_code}" ]] && unset ret_code;
    [[ -n "${error_count}" ]] && unset error_count;
    [[ -n "${retry_counter}" ]] && unset retry_counter;
    [[ -n "${watch_file}" ]] && unset watch_file;
    [[ -n "${sleep_time}" ]] && unset sleep_time;
    [[ -n "${retry_count}" ]] && unset retry_count;

    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
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

#=====  FUNCTION  =============================================================
#          NAME:  isNaN
#   DESCRIPTION:  Checks if the provided variable is a number
#    PARAMETERS:  Variable to check
#       RETURNS:  0 if true, 1 if false
#==============================================================================
function isNaN()
(
    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set -v; fi

    local cname="basefunctions.sh";
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

    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

    (( ${#} != 1 )) && return 3;

    [[ "${1}" =~ ^-?[0-9]+$ ]] || return_code=1;

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${error_count}" ]] && unset error_count;

    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
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
)

#=====  FUNCTION  =============================================================
#          NAME:  returnRandomCharacters
#   DESCRIPTION:  Returns a random string of alphanumeric characters
#    PARAMETERS:  Length of string, include special characters
#       RETURNS:  0 regardless of result.
#==============================================================================
function returnRandomCharacters()
{
    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set -v; fi

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

    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -n "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
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
        if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set -x; fi
        if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set -v; fi

        local cname="F02-misc";
        local function_name="${cname}#${FUNCNAME[1]}";
        local return_code=3;

        if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        fi

        printf "%s %s\n" "${FUNCNAME[1]}" "Return a string of random characters" >&2;
        printf "%s %s\n" "Usage: ${FUNCNAME[1]}" "[ options ]" >&2;
        printf "    %s: %s\n" "--count=value| -c <value>" "The number of strings to generate." >&2;
        printf "    %s: %s\n" "--length=value| -l <value>" "Determines the length of the string to generate." >&2;
        printf "    %s: %s\n" "--special | -s" "Include special characters. If not specified, special characters are not utilized." >&2;

        if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
        fi

        [[ -n "${function_name}" ]] && unset -v function_name;
        [[ -n "${cname}" ]] && unset -v cname;

        if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set +x; fi
        if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set +v; fi

        return "${return_code}";
    )

    if (( ${#} == 0 )); then usage; return ${?}; fi

    while (( ${#} > 0 )); do
        if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided Argument -> ${1}";
        fi

        argument="${1}";

        if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
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

        if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "argument_name -> ${argument_name}";
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "argument_value -> ${argument_value}";
        fi

        case "${argument_name}" in
            count|c)
                if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Setting string_count...";
                fi

                string_count="${argument_value}";

                if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "string_count -> ${string_count}";
                fi
                ;;
            length|l)
                if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Setting string_length...";
                fi

                string_length="${argument_value}";

                if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "string_length -> ${string_length}";
                fi
                ;;
            special|s)
                if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Setting use_special...";
                fi

                use_special="${_TRUE}";

                if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "use_special -> ${use_special}";
                fi
                ;;
            help|\?|h)
                [[ -n "${function_name}" ]] && unset -v function_name;
                [[ -n "${ret_code}" ]] && unset -v ret_code;

                usage;
                return_code="${?}";

                function_name="${cname}#${FUNCNAME[0]}";

                if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "usage -> ret_code -> ${ret_code}";
                fi

                if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set +x; fi
                if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set +v; fi
                ;;
            *)
                if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An invalid option has been provided and has been ignored. Option -> ${argument_name}, Value -> ${argument_value}";
                    writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An invalid option has been provided and has been ignored. Option -> ${argument_name}, Value -> ${argument_value}";
                fi
                ;;
        esac
    done

    while (( counter <= string_count )); do
        if [[ -n "${use_special}" ]] && [[ "${use_special}" == "${_TRUE}" ]]; then
            returned_characters="$(tr -cd '[:graph:]' < /dev/urandom | head -c "${string_length}")";
        else
            returned_characters="$(tr -cd '[:alnum:]' < /dev/urandom | head -c "${string_length}")";
        fi
    done

    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
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

    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -n "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" == "${_TRUE}" ]]; then
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

    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set +v; fi

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
    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set -v; fi

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

    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -n "${CONFIG_MAP["ENABLE_AUDIT"]}" ]] && [[ "${CONFIG_MAP["ENABLE_AUDIT"]}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        writeLogEntry "FILE" "AUDIT" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    [[ -n "${PS1}" ]] && unset -v PS1;

    #
    # history things
    # UNTESTED
    #
    history -n; history -a; history -r;

    git_status="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)";
    real_user="$(grep -w "${EUID}" /etc/passwd | cut -d ":" -f 1)";
    last_cmd="$(history 1 | cut -d " " -f 5-)";
    last_rc="${?}";

    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "git_status -> ${git_status}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "real_user -> ${real_user}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXECUTED: ${last_cmd}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "RETURN CODE: ${last_rc}";
    fi

    case "$(uname -s)" in
        [Cc][Yy][Gg][Ww][Ii][Nn]*)
            case "${git_status}" in
                "") PS1="${color_green}[\u:\H] : <${color_yellow}\w${color_green}>\n\n\$ ${color_off}"; ;;
                *) PS1="${color_green}[\u:\H] : <${color_yellow}\w (${color_blue}${git_status})${color_green}>\n\n\$ ${color_off}"; ;;
            esac
            ;;
        *)
            case "${real_user}" in
                "${LOGNAME}")
                    case "${git_status}" in
                        "") PS1="${color_green}[\u:\H] : <${color_yellow}\w${color_green}>\n\n\$ ${color_off}"; ;;
                        *) PS1="${color_green}[\u:\H] : <${color_yellow}\w ${color_blue}(${git_status})${color_green}>\n\n\$ ${color_off}"; ;;
                    esac
                    ;;
                *)
                    case "${git_status}" in
                        "") PS1="${color_red}NOTE: you are ${real_user}${color_off}\n${color_green}[\u as ${color_red}${real_user}${color_green}:\H] : <${color_yellow}\w${color_green}>\n\n\$ ${color_off}"; ;;
                        *) PS1="${color_red}NOTE: you are ${real_user}${color_off}\n${color_green}[\u as ${color_red}${real_user}${color_green}:\H] : <${color_yellow}\w ${color_blue}(${git_status})${color_green}>\n\n\$ ${color_off}";
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
    [[ -n "${last_cmd}" ]] && unset -v last_cmd;
    [[ -n "${last_rc}" ]] && unset -v last_rc;

    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -n "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" == "${_TRUE}" ]]; then
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

    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set +v; fi

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
    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set -v; fi

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

    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -n "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "primary_file -> ${primary_file}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "secondary_file -> ${secondary_file}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

    #
    # read the commands file and execute each
    #
    for file in ${primary_file} ${secondary_file}; do
        if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "file -> ${file}";
        fi

        if [[ -s "${file}" ]]; then
            for cmd_entry in $(< "${file}"); do
                [[ -z "${cmd_entry}" ]] && continue;
                [[ "${cmd_entry}" =~ ^\# ]] && continue;

                if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cmd_entry -> ${cmd_entry}";
                fi

                cmd_binary="$(cut -d "|" -f 1 <<< "${cmd_entry}")";
                cmd_args="$(cut -d "|" -f 2 <<< "${cmd_entry}")";

                if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cmd_binary -> ${cmd_binary}";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cmd_args -> ${cmd_args}";
                fi

                if [[ -n "$(command -v "${cmd_binary}")" ]]; then
                    [[ -n "${cmd_output}" ]] && unset -v cmd_output;
                    [[ -n "${ret_code}" ]] && unset -v ret_code;

                    cmd_output="$("${cmd_binary}" "${cmd_args}")"; local cmd_output;
                    ret_code="${?}";

                    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cmd_output -> ${cmd_output}";
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${cmd_binary} -> ret_code -> ${ret_code}";
                    fi

                    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                        (( error_count += 1 ));

                        if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]]; then
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

    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -n "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" == "${_TRUE}" ]]; then
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

    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set +v; fi

    return "${return_code}";
}

#=====  FUNCTION  =============================================================
#          NAME:  mkcd
#   DESCRIPTION:  Creates a directory and then changes into it
#    PARAMETERS:  Directory to create
#       RETURNS:  0 if success, 1 otherwise
#==============================================================================
function mkcd()
{
    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set -v; fi

    local cname="misc.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i return_code=0;
    local -i error_count=0;
    local -i ret_code=0;
    local directory_to_create;
    local cmd_output;
    local -i start_epoch;
    local -i end_epoch;
    local -i runtime;

    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -n "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
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
        if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set -x; fi
        if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set -v; fi

        local cname="misc.sh";
        local function_name="${cname}#${FUNCNAME[1]}";
        local return_code=3;

        if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        fi

        printf "%s %s\n" "${FUNCNAME[1]}" "Create a given directory and change into it." >&2;
        printf "%s %s\n" "Usage: ${FUNCNAME[1]}" "[ directory ]" >&2;
        printf "    %s: %s\n" "<directory name>" "The name of the directory to create and change into." >&2;

        if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
        fi

        [[ -n "${function_name}" ]] && unset -v function_name;
        [[ -n "${cname}" ]] && unset -v cname;

        if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set +x; fi
        if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set +v; fi

        return "${return_code}";
    )

    if (( ${#} == 0 )); then usage; return ${?}; fi

    directory_to_create="${1}";

    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "directory_to_create -> ${directory_to_create}";
    fi

    [[ -n "${cmd_output}" ]] && unset -v cmd_output;
    [[ -n "${ret_code}" ]] && unset -v ret_code;

    cmd_output="$(mkdir -pv "${directory_to_create}")";
    ret_code="${?}";

    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cmd_output -> ${cmd_output}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "mkdir/${directory_to_create} -> ret_code -> ${ret_code}";
    fi

    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
        [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

        if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]]; then
            writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to create directory ${directory_to_create}";
        fi

        cd "${directory_to_create}" || return_code=1;

        if [[ "${PWD}" != "${directory_to_create}" ]]; then
            return_code=1;

            if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]]; then
                writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Unable to traverse requested directory ${directory_to_create}";
            fi
        fi
    else
        return_code=1;

        if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]]; then
            writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to create requested directory ${directory_to_create}";
        fi
    fi

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${directory_to_create}" ]] && unset -v directory_to_create;
    [[ -n "${cmd_output}" ]] && unset -v cmd_output;

    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -n "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" == "${_TRUE}" ]]; then
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

    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]] && [[ -v "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set +v; fi

    return "${return_code}";
}
