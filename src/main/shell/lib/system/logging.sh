#!/usr/bin/env bash

#==============================================================================
#          FILE:  installDotFiles
#         USAGE:  See usage section
#   DESCRIPTION:
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

## get the available log config and load it
if [[ -n "${LOGGING_PROPERTIES}" ]]; then
    readPropertyFile "${LOGGING_PROPERTIES}";
else
    if [[ -r "${HOME}/.dotfiles/config/system/logging.properties" ]] && [[ -s "${HOME}/.dotfiles/config/system/logging.properties" ]]; then
        readPropertyFile "${HOME}/.dotfiles/config/system/logging.properties";
    elif [[ -r "/usr/local/config/logging.properties" ]] && [[ -s "/usr/local/config/logging.properties" ]]; then
        readPropertyFile "/usr/local/config/logging.properties";
    else
        printf "\e[00;31m%s\e[00;32m\n" "Unable to load logging configuration. Shutting down." >&2;
    fi
fi

if [[ "${CONFIG_MAP["LOG_ROOT"]:0:1}" == "~" ]]; then
    CONFIG_MAP["LOG_ROOT"]="$(sed -e "s/~/$(grep "${LOGNAME}" /etc/passwd | cut -d ":" -f 6)/g" <<< "${CONFIG_MAP["LOG_ROOT"]}")";
fi

if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set +x; fi
if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set +v; fi
if [[ -n "${CONFIG_MAP["LOG_ROOT"]}" ]] && [[ ! -d "${CONFIG_MAP["LOG_ROOT"]}" ]]; then mkdir -p "${CONFIG_MAP["LOG_ROOT"]}"; fi

#======  FUNCTION  ============================================================
#          NAME:  usage
#   DESCRIPTION:  Rotates log files in logs directory
#    PARAMETERS:  None
#       RETURNS:  0 regardless of result.
#==============================================================================
function usage()
(
    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set +v; fi

    local cname="logging.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i return_code=3;

    printf "%s %s\n" "${function_name}" "Write a log message to a provided target." >&2;
    printf "%s %s\n" "Usage: ${function_name}" "[ <options> ]" >&2;
    printf "    %s: %s\n" "The type of log output." "Supported levels (not case-sensitive):" >&2; ## TODO: This should also be able to send email, write to a db, etc
    printf "        %s: %s\n" "FILE" "Write the provided data to the console (writeable level provided as an argument)." >&2;
    printf "        %s: %s\n" "CONSOLE" "Write the provided data to the console (either STDOUT or STDERR)." >&2;
    printf "    %s: %s\n" "The level to write for." "Supported levels (not case-sensitive):" >&2;
    printf "        %s: %s\n" "STDOUT" "Write the provided data to standard output - commonly a terminal screen." >&2;
    printf "        %s: %s\n" "STDERR" "Write the provided data to standard error - commonly a terminal screen." >&2;
    printf "        %s: %s\n" "PERFORMANCE" "Write performance metrics as provided by the scripting." >&2;
    printf "        %s: %s\n" "FATAL" "Errors that cannot be recovered from." >&2;
    printf "        %s: %s\n" "ERROR" "Errors that are handled within the application." >&2;
    printf "        %s: %s\n" "INFO" "Informational messages about runtime processing." >&2;
    printf "        %s: %s\n" "WARN" "Warning messages usually related to configuration." >&2;
    printf "        %s: %s\n" "AUDIT" "Performs an audit log write." >&2;
    printf "        %s: %s\n" "DEBUG" "Messaging related to immediate runtime actions or configurations." >&2;
    printf "    %s: %s\n" "Process IDentifier (PID)" "The process ID of the running instance." >&2;
    printf "    %s: %s\n" "Calling script" "The script calling the method to write the log entry." >&2;
    printf "    %s: %s\n" "Line number" "The line on which the message was produced." >&2;
    printf "    %s: %s\n" "Calling function" "The method within the script calling the method to write the log entry." >&2;
    printf "    %s: %s\n" "Message" "The data to write to the logfile." >&2;

    [[ -n "${function_name}" ]] && unset function_name;
    [[ -n "${cname}" ]] && unset cname;

    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set -v; fi

    return "${return_code}";
)

#======  FUNCTION  ============================================================
#          NAME:  main
#   DESCRIPTION:  Rotates log files in logs directory
#    PARAMETERS:  None
#       RETURNS:  0 regardless of result.
#==============================================================================
function writeLogEntry()
(
    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set +v; fi

    local cname="logging.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i return_code=0;
    local action="${1}";

    case "${action}" in
        [Ff][Ii][Ll][Ee])
            writeLogEntryToFile "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "$(date -d @"$(date +"%s")" +"${TIMESTAMP_OPTS}")";
            ;;
        [Cc][Oo][Nn][Ss][Oo][Ll][Ee])
            writeLogEntryToConsole "${2}" "${7}";
            ;;
        *)
            (( error_count += 1 ));
            ;;
    esac

    [[ -n "${action}" ]] && unset action;

    [[ -n "${function_name}" ]] && unset function_name;
    [[ -n "${cname}" ]] && unset cname;

    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set -v; fi

    return "${return_code}";
)

#=====  FUNCTION  =============================================================
#          NAME:  writeLogEntryToConsole
#   DESCRIPTION:  Cleans up the archived log directory
#    PARAMETERS:  Archive Directory, Logfile Name, Retention Time
#       RETURNS:  0 regardless of result.
#==============================================================================
function writeLogEntryToConsole()
(
    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set +v; fi

    local cname="logging.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i return_code=0;
    local log_level="${1}";
    local log_message="${2}";

    case "${log_level}" in
        [Ss][Tt][Dd][Oo][Uu][Tt]) printf "%s\n" "${log_message}" >&1; ;;
        [Ss][Tt][Dd][Ee][Rr][Rr]) printf "\e[00;31m%s\e[00;32m\n" "${log_message}" >&2; ;;
    esac

    [[ -n "${log_level}" ]] && unset log_level;
    [[ -n "${log_message}" ]] && unset log_message;

    [[ -n "${function_name}" ]] && unset function_name;
    [[ -n "${cname}" ]] && unset cname;

    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set -v; fi

    return 0;
)

#=====  FUNCTION  =============================================================
#          NAME:  writeLogEntryToFile
#   DESCRIPTION:  Cleans up the archived log directory
#    PARAMETERS:  Archive Directory, Logfile Name, Retention Time
#       RETURNS:  0 regardless of result.
#==============================================================================
function writeLogEntryToFile()
(
    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set +v; fi

    local cname="logging.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local log_level="${1}";
    local log_pid="${2}";
    local log_source="${3}";
    local log_line="${4}";
    local log_method="${5}";
    local log_message="${6}";
    local log_date="${7}";
    local log_file;

    current_clobber="$(set -o | grep noclobber | awk '{print $NF}')";

    case "${log_level}" in
        [Pp][Ee][Rr][Ff][Oo][Rr][Mm][Aa][Nn][Cc][Ee]) log_file="${CONFIG_MAP["PERF_LOG_FILE"]}"; ;;
        [Ff][Aa][Tt][Aa][Ll]) log_file="${CONFIG_MAP["FATAL_LOG_FILE"]}"; ;;
        [Ee][Rr][Rr][Oo][Rr]) log_file="${CONFIG_MAP["ERROR_LOG_FILE"]}"; ;;
        [Ww][Aa][Rr][Nn]) log_file="${CONFIG_MAP["WARN_LOG_FILE"]}"; ;;
        [Ii][Nn][Ff][Oo]) log_file="${CONFIG_MAP["INFO_LOG_FILE"]}"; ;;
        [Aa][Uu][Dd][Ii][Tt]) log_file="${CONFIG_MAP["AUDIT_LOG_FILE"]}"; ;;
        [Dd][Ee][Bb][Uu][Gg]) log_file="${CONFIG_MAP["DEBUG_LOG_FILE"]}"; ;;
        [Mm][Oo][Nn][Ii][Tt][Oo][Rr]) log_file="${CONFIG_MAP["MONITOR_LOG_FILE"]}"; ;;
        *) log_file="${CONFIG_MAP["DEFAULT_LOG_FILE"]}"; ;;
    esac

    ## TODO
    printf "${CONFIG_MAP["CONVERSION_PATTERN"]}\n" "${log_date}" "${log_file}" "${log_level}" "${log_pid}" "${log_source}" "${log_line}" "${log_method}" "${log_message}" >> "${CONFIG_MAP["LOG_ROOT"]}/${log_file}";

    if [[ -n "${current_clobber}" ]] && [[ "${current_clobber}" == "off" ]]; then set +o noclobber; fi

    [[ -n "${log_level}" ]] && unset log_level;
    [[ -n "${log_pid}" ]] && unset log_pid;
    [[ -n "${log_source}" ]] && unset log_source;
    [[ -n "${log_line}" ]] && unset log_line;
    [[ -n "${log_method}" ]] && unset log_method;
    [[ -n "${log_message}" ]] && unset log_message;
    [[ -n "${log_date}" ]] && unset log_date;
    [[ -n "${log_file}" ]] && unset log_file;
    [[ -n "${current_clobber}" ]] && unset current_clobber;

    [[ -n "${function_name}" ]] && unset function_name;
    [[ -n "${cname}" ]] && unset cname;

    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set -v; fi

    return 0;
)
