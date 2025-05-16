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

#======  FUNCTION  ============================================================;
#          NAME:  watchProvidedProcess;
#   DESCRIPTION:  Watches a provided process for a given amount of time;
#    PARAMETERS:  None;
#       RETURNS:  0 if no errors, 1 otherwise;
#==============================================================================;
function watchProvidedProcess()
{
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    local cname="watchdog.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local return_code=0;
    local error_count=0;
    local process_id;
    local process_time_wait;
    local process_end_count;
    local pid_runtime;
    local start_epoch;
    local end_epoch;
    local runtime;

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
        fi
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

	if (( ${#} != 1 )); then usage; exit ${?}; fi

	process_id="${1}";

	(( ${#} == 2 || ${#} == 3 )) && process_time_wait="${2}" || process_time_wait="${DEFAULT_TIMEOUT_SLEEP}";
	(( ${#} == 3 )) && process_end_count="${3}" || process_end_count="${DEFAULT_TIMEOUT_COUNT}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "process_id -> ${process_id}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "process_time_wait -> ${process_time_wait}";
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "process_end_count -> ${process_end_count}";
    fi

	while (eval ps -p "${process_id}" > /dev/null); do
		if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
			writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Entering watchdog loop for process ${process_id}";
		fi

		if (( pid_runtime >= process_end_count )); then
			(( error_count += 1 ));

			if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
				writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: pkill -9 ${process_id}";
			fi

			pkill -9 "${process_id}";

			if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
				writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Process did not exit after (( process_time_wait * process_end_count )). Killing process";
				writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Process did not exit after (( process_time_wait * process_end_count )). Killing process";
			fi

			break;
		fi

		(( pid_runtime += 1 ));

		sleep "${process_time_wait}";
	done

    if [[ -z "${error_count}" ]] || (( error_count == 0 )); then
        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "Process ID ${process_id} has exited.";
        fi
    else
        return_code="${error_count}";

        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Process ID ${process_id} has been killed as it exceeded the provided timeout value. Please review logs.";
        fi
    fi

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

	[[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${process_id}" ]] && unset -v process_id;
    [[ -n "${process_time_wait}" ]] && unset -v process_time_wait;
	[[ -n "${process_end_count}" ]] && unset -v process_end_count;
    [[ -n "${pid_runtime}" ]] && unset -v pid_runtime;

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")";
        runtime=$(( end_epoch - start_epoch ));

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    [[ -n "${start_epoch}" ]] && unset -v start_epoch;
    [[ -n "${end_epoch}" ]] && unset -v end_epoch;
    [[ -n "${runtime}" ]] && unset -v runtime;
    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${cname}" ]] && unset -v cname;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return "${return_code}";
}
