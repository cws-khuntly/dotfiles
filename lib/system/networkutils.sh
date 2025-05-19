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

#=====  FUNCTION  =============================================================;
#          NAME:  validateHostAvailability;
#   DESCRIPTION:  Validates that a given host exists in DNS and is alive;
#    PARAMETERS:  Target host, port number (optional);
#       RETURNS:  0 if success, 1 otherwise;
#==============================================================================;
function validateHostAvailability()
{
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    local cname="networkutils.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local ret_code=0;
    local return_code=0;
    local error_count=0;
    local target_transport;
    local target_host;
    local target_port;
    local validatedHostName;
    local validatedHostAddress;
    local validatedPortNumber;
    local returned_data;
    local start_epoch;
    local end_epoch;
    local runtime;

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

    (( ${#} != 3 )) && return 3;

    target_transport="${1}";
    target_host="${2}";
    target_port="${3}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_transport -> ${target_transport}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_host -> ${target_host}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_port -> ${target_port}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: checkForValidHost ${target_host}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: checkForValidAddress ${target_host}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: checkForValidPort ${target_port}";
    fi

    if [[ "${target_host}" == "$(hostname -s)" ]] || [[ "${target_host}" == "$(hostname -f)" ]] || \
        [[ "${target_host}" == "localhost" ]] || [[ "${target_host}" == "localhost.localdomain" ]] || \
        [[ "${target_host}" == "127.0.0.1" ]] || [[ "${target_host}" == "::1" ]] || [[ "${target_host}" == "0:0:0:0:0:0:0:1" ]]; then
        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided hostname is localhost, returning";
        fi

        return_code=0;
    else
        [[ -n "${cname}" ]] && unset -v cname;
        [[ -n "${function_name}" ]] && unset -v function_name;
        [[ -n "${ret_code}" ]] && unset -v ret_code;

        validatedHostName="$(checkForValidHost "${target_host}")";
        validatedHostAddress="$(checkForValidAddress "${target_host}")";
        validatedPortNumber="$(checkForValidPort "${target_port}")";

        cname="networkutils.sh";
        function_name="${cname}#${FUNCNAME[0]}";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "validatedHostName -> ${validatedHostName}";
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "validatedHostAddress -> ${validatedHostAddress}";
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "validatedPortNumber -> ${validatedPortNumber}";
        fi

        if [[ -n "${validatedHostName}" ]] || [[ -n "${validatedHostAddress}" ]] && [[ -n "${validatedPortNumber}" ]]; then
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: checkIfHostIsAlive ${validatedHostName} ${validatedPortNumber}";
            fi

            [[ -n "${validatedHostName}" ]] && returnValidatedHost="${validatedHostName}" || returnValidatedHost="${validatedHostAddress}";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "returnValidatedHost -> ${returnValidatedHost}";
            fi

            [[ -n "${cname}" ]] && unset -v cname;
            [[ -n "${function_name}" ]] && unset -v function_name;
            [[ -n "${ret_code}" ]] && unset -v ret_code;

            checkIfHostIsAlive "${returnValidatedHost}" "${validatedPortNumber}";
            ret_code="${?}";

            cname="networkutils.sh";
            function_name="${cname}#${FUNCNAME[0]}";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "checkIfHostIsAlive -> ret_code -> ${ret_code}";
            fi

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                (( error_count += 1 ));

                if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Attempt to validate ${returnValidatedHost} with port ${validatedPortNumber} has failed.";
                fi
            else
                returned_data="${returnValidatedHost}:${validatedPortNumber}";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "returned_data -> ${returned_data[*]}";
                fi
            fi
        else
            return_code=1;

            if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An invalid hostname was provided. Cannot continue.";
            fi
        fi
    fi

    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${target_host}" ]] && unset -v target_host;
    [[ -n "${target_port}" ]] && unset -v target_port;
    [[ -n "${validatedHostName}" ]] && unset -v validatedHostName;
    [[ -n "${validatedHostAddress}" ]] && unset -v validatedHostAddress;
    [[ -n "${validatedPortNumber}" ]] && unset -v validatedPortNumber;

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

    if [[ -n "${returned_data}" ]]; then printf "%s" "${returned_data}"; unset -v returned_data; fi
}

#=====  FUNCTION  =============================================================;
#          NAME:  isValidHost;
#   DESCRIPTION:  Validates that a given host exists in DNS and is alive;
#    PARAMETERS:  Target host, port number (optional);
#       RETURNS:  0 if success, 1 otherwise;
#==============================================================================;
function checkForValidHost()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    local cname="networkutils.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local return_code=0;
    local error_count=0;
    local ret_code=0;
    local checkForHostname;
    local isFQDN;
    local searchForNameInHosts;
    local returnedHostName;
    local resolver_entry;
    local search_domain;
    local start_epoch;
    local end_epoch;
    local runtime;

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

    (( ${#} != 1 )) && return 3;

    checkForHostname="${1}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "checkForHostname -> ${checkForHostname}";
    fi

    if [[ -n "${checkForHostname}" ]]; then
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: grep -qE \"^([a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]\.)+[a-zA-Z]{2,}$\" <<< ${checkForHostname}";
        fi

        isFQDN="$(grep -E "^([a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]\.)+[a-zA-Z]{2,}$" <<< "${checkForHostname}")";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "isFQDN -> ${isFQDN}";
        fi

        if [[ -n "${isFQDN}" ]]; then
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: host -N 0 ${checkForHostname} > /dev/null 2>&1";
            fi

            [[ -n "${ret_code}" ]] && unset -v ret_code;

            host -N 0 "${checkForHostname}" > /dev/null 2>&1;
            ret_code="${?}";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "host/${checkForHostname} -> ret_code -> ${ret_code}";
            fi

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                ## host not found in dns, lets see if its in the hosts table;
                ## NOTE: this assumes a properly formatted host entry in the form of <IP address> <FQDN> <alias(es)>;
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Entry ${checkForHostname} was not found in DNS. Checking for entries in /etc/hosts...";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: grep -m 1 ${checkForHostname} /etc/hosts | awk '{print $2}'";
                fi

                searchForNameInHosts="$(grep -m 1 "${checkForHostname}" "/etc/hosts" | awk '{print $2}')";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "searchForNameInHosts -> ${searchForNameInHosts}";
                fi

                ## entry found in /etc/hosts;
                if [[ -n "${searchForNameInHosts}" ]]; then
                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Setting returnedHostName to ${searchForNameInHosts}";
                    fi

                    returnedHostName="${searchForNameInHosts}";

                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "returnedHostName -> ${returnedHostName}";
                    fi
                fi
            else
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Setting returnedHostName to ${checkForHostname}";
                fi

                returnedHostName="${checkForHostname}";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "returnedHostName -> ${returnedHostName}";
                fi
            fi
        else
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Looping through found search suffixes in /etc/resolv.conf";
            fi

            ## loop through all the possible domain names in /etc/resolv.conf;
            ## change the IFS;
            IFS="${MODIFIED_IFS}";

            ## clean up home directory first;
            for resolver_entry in $(< "/etc/resolv.conf"); do
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "resolver_entry -> ${resolver_entry}";
                fi

                [[ -z "${resolver_entry}" ]] && continue;
                [[ "${resolver_entry}" =~ ^\# ]] && continue;
                [[ "${resolver_entry}" =~ ^nameserver ]] && continue;

                if [[ "${resolver_entry}" =~ ^search ]]; then
                    search_domain="$(awk '{print $NF}' <<< "${resolver_entry}")";

                    ## check if in DNS...;
                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "search_domain -> ${search_domain}";
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: host -N 0 ${checkForHostname}.${search_domain} > /dev/null 2>&1";
                    fi

                    [[ -n "${ret_code}" ]] && unset -v ret_code;

                    host -N 0 "${checkForHostname}.${search_domain}" > /dev/null 2>&1;
                    ret_code="${?}";

                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "host/${checkForHostname}.${search_domain} -> ret_code -> ${ret_code}";
                    fi

                    if [[ -n "${ret_code}" ]] && (( ret_code == 0 )); then
                        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Setting returnedHostName to ${checkForHostname}.${search_domain}";
                        fi

                        returnedHostName="${checkForHostname}.${search_domain}";

                        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "returnedHostName -> ${returnedHostName}";
                        fi

                        [[ -n "${ret_code}" ]] && unset -v ret_code;
                        [[ -n "${resolver_entry}" ]] && unset -v resolver_entry;

                        break;
                    fi
                fi

                [[ -n "${ret_code}" ]] && unset -v ret_code;
                [[ -n "${search_domain}" ]] && unset -v search_domain;
                [[ -n "${resolver_entry}" ]] && unset -v resolver_entry;
            done;

            ## restore the original ifs;
            IFS="${CURRENT_IFS}";
        fi
    fi

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${checkForHostname}" ]] && unset -v checkForHostname;
    [[ -n "${isFQDN}" ]] && unset -v isFQDN;
    [[ -n "${searchForNameInHosts}" ]] && unset -v searchForNameInHosts;
    [[ -n "${resolver_entry}" ]] && unset -v resolver_entry;
    [[ -n "${search_domain}" ]] && unset -v search_domain;

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_