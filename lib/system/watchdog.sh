#!/usr/bin/env bash

#======  FUNCTION  ============================================================
#          NAME:  watchProvidedProcess
#   DESCRIPTION:  Watches a provided process for a given amount of time
#    PARAMETERS:  None
#       RETURNS:  0 if no errors, 1 otherwise
#==============================================================================
function watchProvidedProcess()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    function_name="${CNAME}#${FUNCNAME[0]}";
    return_code=0;
    error_count=0;

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "PERFORMANCE" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
        fi
    fi
	#======  FUNCTION  ============================================================
	#          NAME:  usage
	#   DESCRIPTION:  Provides usage parameters.
	#    PARAMETERS:  None
	#       RETURNS:  3.
	#==============================================================================
	function usage()
	(
		if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
		if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

		function_name="${CNAME}#${FUNCNAME[0]}";
		return_code=3;

		if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
			writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "${function_name} -> enter";
		fi

		printf "%s %s\n" "${function_name}" "Watch a provided process" >&2;
		printf "%s %s\n" "Usage: ${function_name}" "[ options ]" >&2;
		printf "    %s: %s\n" "Required" "--processid | -p <process id>: The process identifier to watch." >&2;
		printf "    %s: %s\n" "Optional" "--wait | -w <wait time>: The length of time to wait for the process to end, multiplied by the number of passes to watch." >&2;
		printf "    %s: %s\n" "Optional" "--count | -c <counter>: The counter of times to pass before the watchdog terminates." >&2;
		printf "    %s: %s\n" "--help | -h | -?" "Show this help menu." >&2;

		if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
			writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "${function_name} -> exit";
		fi

		if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
		if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

		return ${return_code};
	)

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

	(( ${#} != 0 )) && usage;

	(( ${#} == 1 )) && process_id="${1}";
	(( ${#} == 2 || ${#} == 3 )) && process_time_wait="${2}" || process_time_wait="${DEFAULT_TIMEOUT_SLEEP}";
	(( ${#} == 3 )) && process_end_count="${3}" || process_end_count="${DEFAULT_TIMEOUT_COUNT}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "process_id -> ${process_id}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "process_time_wait -> ${process_time_wait}";
		writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "process_end_count -> ${process_end_count}";
    fi

	while $(ps -p ${process_id} > /dev/null); do
		if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
			writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Entering watchdog loop for process ${process_id}";
		fi

		if (( pid_runtime >= process_end_count )); then
			(( error_count += 1 ));

			if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
				writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "EXEC: pkill -9 ${process_id}";
			fi

			pkill -9 ${process_id};

			if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
				writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Process did not exit after (( process_time_wait * process_end_count )). Killing process";
				writeLogEntry "CONSOLE" "STDERR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Process did not exit after (( process_time_wait * process_end_count )). Killing process";
			fi

			break;
		fi

		(( pid_runtime += 1 ));

		sleep ${process_time_wait};
	done

    if [[ -z "${error_count}" ]] || (( error_count == 0 )); then
        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "INFO" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Process ID ${process_id} has exited.";
        fi
    else
        return_code="${error_count}";

        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Process ID ${process_id} has been killed as it exceeded the provided timeout value. Please review logs.";
        fi
    fi

	[[ -n "${pid_runtime}" ]] && unset -v pid_runtime;
    [[ -n "${process_time_wait}" ]] && unset -v process_time_wait;
    [[ -n "${process_time_end}" ]] && unset -v process_time_end;
	[[ -n "${pid_runtime}" ]] && unset -v pid_runtime;

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( end_epoch - start_epoch ));

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${function_name}" ]] && unset -v function_name;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return ${return_code};
)
