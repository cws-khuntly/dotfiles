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

#======  FUNCTION  ============================================================
#          NAME:  runWatchdog
#   DESCRIPTION:  Watches a provided process for a given amount of time
#    PARAMETERS:  None
#       RETURNS:  0 if no errors, 1 otherwise
#==============================================================================
function runWatchdog()
{
    local cname="watchdog.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i return_code=0;
    local -i error_count=0;
    local -i start_epoch;
    local -i end_epoch;
    local -i runtime;

    if (( ${#} != 1 )); then usage; exit ${?}; fi

    watch_data="${1}";
    watch_type="$(cut -d ":" -f 1 <<< "${watch_data}")";

    case "${watch_type}" in
        "[Pp][Rr][Oo][Cc][Cc][Ee][Ss][Ss][Ii][Dd]|[Pp][Rr][Oo][Cc][Cc][Ee][Ss]|[Pp][Ii][Dd]")
            (( $(tr ":" "\n" <<< "${watch_data}" | wc -l) < 2 )) && return 3;

            watch_pid="$(cut -d ":" -f 2 <<< "${watch_data}")";

            (( $(tr ":" "\n" <<< "${watch_data}" | wc -l) >= 3 )) && wait_time="$(cut -d ":" -f 3 <<< "${watch_data}")" || wait_time="${DEFAULT_WAIT_TIME}";
            (( $(tr ":" "\n" <<< "${watch_data}" | wc -l) >= 4 )) && retry_count="$(cut -d ":" -f 4 <<< "${watch_data}")" || retry_count="${DEFAULT_RETRY_COUNT}";

            [[ -n "${function_name}" ]] && unset function_name;
            [[ -n "${cname}" ]] && unset cname;

            watchForProcessID "${watch_pid}" "${wait_time}" "${retry_count}";
            ret_code="${?}";

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                [[ -z "${ret_code}" ]] && return_code=1 || [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

                if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "watchForProcessID failed. Return code -> ${ret_code}";
                fi
            fi
            ;;
        "[Ff][Ii][Ll][Ee]")
            (( $(tr ":" "\n" <<< "${watch_data}" | wc -l) < 2 )) && return 3;

            watch_file="$(cut -d ":" -f 2 <<< "${watch_data}")";

            (( $(tr ":" "\n" <<< "${watch_data}" | wc -l) >= 3 )) && wait_time="$(cut -d ":" -f 3 <<< "${watch_data}")" || wait_time="${DEFAULT_WAIT_TIME}";
            (( $(tr ":" "\n" <<< "${watch_data}" | wc -l) >= 4 )) && retry_count="$(cut -d ":" -f 4 <<< "${watch_data}")" || retry_count="${DEFAULT_RETRY_COUNT}";

            [[ -n "${function_name}" ]] && unset function_name;
            [[ -n "${cname}" ]] && unset cname;

            watchForFile "${watch_file}" "${wait_time}" "${retry_count}";
            ret_code="${?}";

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                [[ -z "${ret_code}" ]] && return_code=1 || [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

                if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "watchForFile failed. Return code -> ${ret_code}";
                fi
            fi
            ;;
        "[Tt][Cc][Pp]|[Uu][Dd][Pp]")
            (( $(tr ":" "\n" <<< "${watch_data}" | wc -l) < 3 )) && return 3;

            watch_host="$(cut -d ":" -f 2 <<< "${watch_data}")";
            watch_port="$(cut -d ":" -f 3 <<< "${watch_data}")";

            (( $(tr ":" "\n" <<< "${watch_data}" | wc -l) >= 3 )) && wait_time="$(cut -d ":" -f 3 <<< "${watch_data}")" || wait_time="${DEFAULT_WAIT_TIME}";
            (( $(tr ":" "\n" <<< "${watch_data}" | wc -l) >= 4 )) && retry_count="$(cut -d ":" -f 4 <<< "${watch_data}")" || retry_count="${DEFAULT_RETRY_COUNT}";

            [[ -n "${function_name}" ]] && unset function_name;
            [[ -n "${cname}" ]] && unset cname;

            watchForNetworkPort "${watch_type}" "${watch_host}" "${watch_port}" "${wait_time}" "${retry_count}";
            ret_code="${?}";

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                [[ -z "${ret_code}" ]] && return_code=1 || [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

                if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "watchForNetworkPort failed. Return code -> ${ret_code}";
                fi
            fi
            ;;
    esac

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${watch_data}" ]] && unset watch_data;
    [[ -n "${watch_type}" ]] && unset watch_type;
    [[ -n "${watch_pid}" ]] && unset watch_pid;
    [[ -n "${watch_file}" ]] && unset watch_file;
    [[ -n "${watch_host}" ]] && unset watch_host;
    [[ -n "${watch_port}" ]] && unset watch_port;
    [[ -n "${error_count}" ]] && unset error_count;
    [[ -n "${process_id}" ]] && unset process_id;
    [[ -n "${process_time_wait}" ]] && unset process_time_wait;
    [[ -n "${process_end_count}" ]] && unset process_end_count;
    [[ -n "${pid_runtime}" ]] && unset pid_runtime;

    [[ -n "${start_epoch}" ]] && unset start_epoch;
    [[ -n "${end_epoch}" ]] && unset end_epoch;
    [[ -n "${runtime}" ]] && unset runtime;
    [[ -n "${function_name}" ]] && unset function_name;
    [[ -n "${cname}" ]] && unset cname;

    return "${return_code}";
}

#======  FUNCTION  ============================================================;
#          NAME:  watchProvidedProcess;
#   DESCRIPTION:  Watches a provided process for a given amount of time;
#    PARAMETERS:  None;
#       RETURNS:  0 if no errors, 1 otherwise;
#==============================================================================;
function watchForProcessID()
{
    local cname="watchdog.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i return_code=0;
    local -i error_count=0;
    local process_id;
    local process_time_wait;
    local process_end_count;
    local pid_runtime;
    local -i start_epoch;
    local -i end_epoch;
    local -i runtime;

    if (( ${#} != 1 )); then usage; exit ${?}; fi

    process_id="${1}";

    (( ${#} == 2 || ${#} == 3 )) && process_time_wait="${2}" || process_time_wait="${DEFAULT_WAIT_TIME}";
    (( ${#} == 3 )) && process_end_count="${3}" || process_end_count="${DEFAULT_RETRY_COUNT}";

    while (eval ps -p "${process_id}" > /dev/null); do
        if (( pid_runtime >= process_end_count )); then
            (( error_count += 1 ));

            pkill -9 "${process_id}";

            if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]]; then
                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Process did not exit after (( process_time_wait * process_end_count )). Killing process";
                writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Process did not exit after (( process_time_wait * process_end_count )). Killing process";
            fi

            break;
        fi

        (( pid_runtime += 1 ));

        sleep "${process_time_wait}";
    done

    if [[ -z "${error_count}" ]] || (( error_count == 0 )); then
        if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]]; then
            writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "Process ID ${process_id} has exited.";
        fi
    else
        return_code="${error_count}";

        if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Process ID ${process_id} has been killed as it exceeded the provided timeout value. Please review logs.";
        fi
    fi

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${error_count}" ]] && unset error_count;
    [[ -n "${process_id}" ]] && unset process_id;
    [[ -n "${process_time_wait}" ]] && unset process_time_wait;
    [[ -n "${process_end_count}" ]] && unset process_end_count;
    [[ -n "${pid_runtime}" ]] && unset pid_runtime;

    [[ -n "${start_epoch}" ]] && unset start_epoch;
    [[ -n "${end_epoch}" ]] && unset end_epoch;
    [[ -n "${runtime}" ]] && unset runtime;
    [[ -n "${function_name}" ]] && unset function_name;
    [[ -n "${cname}" ]] && unset cname;

    return "${return_code}";
}

#=====  FUNCTION  =============================================================
#          NAME:  watchForProcessFile
#   DESCRIPTION:  Pauses a process until an identified file exists
#    PARAMETERS:  File
#       RETURNS:  0 if success, 1 otherwise
#==============================================================================
function watchForFile()
{
    local cname="watchdog.sh";
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

    (( ${#} != 3 )) && return 3;

    watch_file="${1}";
    sleep_time="${2}";
    retry_count="${3}";

    while [[ ! -f "${watch_file}" ]] && (( retry_counter != retry_count )); do
        sleep "${sleep_time}"; (( retry_counter += 1 ));

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

    [[ -n "${start_epoch}" ]] && unset start_epoch;
    [[ -n "${end_epoch}" ]] && unset end_epoch;
    [[ -n "${runtime}" ]] && unset runtime;
    [[ -n "${function_name}" ]] && unset function_name;
    [[ -n "${cname}" ]] && unset cname;

    return "${return_code}";
}

#=====  FUNCTION  =============================================================
#          NAME:  watchForNetworkPort
#   DESCRIPTION:  Pauses a process until an identified port is available
#    PARAMETERS:  Target host, target port
#       RETURNS:  0 if success, 1 otherwise
#==============================================================================
function watchForNetworkPort()
{
    local cname="watchdog.sh";
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

    (( ${#} != 5 )) && return 3;

    target_transport="${1}";
    target_host="${2}";
    target_port="${3}";
    sleep_time="${4}";
    retry_count="${5}";

    while (( retry_counter != retry_count )); do
        [[ -n "${ret_code}" ]] && unset ret_code;
        [[ -n "${function_name}" ]] && unset function_name;
        [[ -n "${cname}" ]] && unset cname;

        validateHostAvailability "${target_transport}" "${target_host}" "${target_port}"
        ret_code="${?}";

        cname="watchdog.sh";
        function_name="${cname}#${FUNCNAME[0]}";

        case "${ret_code}" in
            0) return_code=0; break; ;;
            *) (( retry_counter += 1 )); continue; ;;
        esac
    done

    (( retry_counter >= retry_count )) && return_code=1;

    [[ -n "${ret_code}" ]] && unset ret_code;
    [[ -n "${error_count}" ]] && unset error_count;
    [[ -n "${retry_counter}" ]] && unset retry_counter;
    [[ -n "${target_host}" ]] && unset target_host;
    [[ -n "${target_port}" ]] && unset target_port;
    [[ -n "${sleep_time}" ]] && unset sleep_time;
    [[ -n "${retry_count}" ]] && unset retry_count;

    [[ -n "${start_epoch}" ]] && unset start_epoch;
    [[ -n "${end_epoch}" ]] && unset end_epoch;
    [[ -n "${runtime}" ]] && unset runtime;
    [[ -n "${function_name}" ]] && unset function_name;
    [[ -n "${cname}" ]] && unset cname;

    return "${return_code}";
}
