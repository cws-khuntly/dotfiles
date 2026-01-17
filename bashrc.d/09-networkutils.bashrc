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
    local cname="networkutils.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i ret_code=0;
    local -i return_code=0;
    local -i error_count=0;
    local target_transport;
    local target_host;
    local -i target_port;
    local validatedHostName;
    local validatedHostAddress;
    local -i validatedPortNumber;
    local returned_data;
    local -i start_epoch;
    local -i end_epoch;
    local -i runtime;

    (( ${#} != 3 )) && return 3;

    target_transport="${1}";
    target_host="${2}";
    target_port="${3}";

    if [[ "${target_host}" == "$(hostname -s)" ]] || [[ "${target_host}" == "$(hostname -f)" ]] || \
        [[ "${target_host}" == "localhost" ]] || [[ "${target_host}" == "localhost.localdomain" ]] || \
        [[ "${target_host}" == "127.0.0.1" ]] || [[ "${target_host}" == "::1" ]] || [[ "${target_host}" == "0:0:0:0:0:0:0:1" ]]; then
        if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]]; then
            writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided hostname is localhost, returning";
        fi

        return_code=0;
    else
        [[ -n "${cname}" ]] && unset cname;
        [[ -n "${function_name}" ]] && unset function_name;
        [[ -n "${ret_code}" ]] && unset ret_code;

        validatedHostName="$(checkForValidHost "${target_host}")";
        validatedHostAddress="$(checkForValidAddress "${target_host}")";
        validatedPortNumber="$(checkForValidPort "${target_port}")";

        cname="networkutils.sh";
        function_name="${cname}#${FUNCNAME[0]}";

        if [[ -n "${validatedHostName}" ]] || [[ -n "${validatedHostAddress}" ]] && [[ -n "${validatedPortNumber}" ]]; then
            [[ -n "${validatedHostName}" ]] && returnValidatedHost="${validatedHostName}" || returnValidatedHost="${validatedHostAddress}";

            [[ -n "${cname}" ]] && unset cname;
            [[ -n "${function_name}" ]] && unset function_name;
            [[ -n "${ret_code}" ]] && unset ret_code;

            checkIfHostIsAlive "${target_transport}" "${returnValidatedHost}" "${validatedPortNumber}";
            ret_code="${?}";

            cname="networkutils.sh";
            function_name="${cname}#${FUNCNAME[0]}";

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                (( error_count += 1 ));

                if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Attempt to validate ${returnValidatedHost} with port ${validatedPortNumber} has failed.";
                fi
            else
                returned_data="${returnValidatedHost}:${validatedPortNumber}";
            fi
        else
            return_code=1;

            if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]]; then
                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An invalid hostname was provided. Cannot continue.";
            fi
        fi
    fi

    [[ -n "${ret_code}" ]] && unset ret_code;
    [[ -n "${error_count}" ]] && unset error_count;
    [[ -n "${target_host}" ]] && unset target_host;
    [[ -n "${target_port}" ]] && unset target_port;
    [[ -n "${target_transport}" ]] && unset target_transport;
    [[ -n "${validatedHostName}" ]] && unset validatedHostName;
    [[ -n "${validatedHostAddress}" ]] && unset validatedHostAddress;
    [[ -n "${validatedPortNumber}" ]] && unset validatedPortNumber;

    [[ -n "${start_epoch}" ]] && unset start_epoch;
    [[ -n "${end_epoch}" ]] && unset end_epoch;
    [[ -n "${runtime}" ]] && unset runtime;
    [[ -n "${function_name}" ]] && unset function_name;
    [[ -n "${cname}" ]] && unset cname;

    if [[ -n "${returned_data}" ]]; then printf "%s" "${returned_data}"; unset returned_data; fi
}

#=====  FUNCTION  =============================================================;
#          NAME:  isValidHost;
#   DESCRIPTION:  Validates that a given host exists in DNS and is alive;
#    PARAMETERS:  Target host, port number (optional);
#       RETURNS:  0 if success, 1 otherwise;
#==============================================================================;
function checkForValidHost()
(
    local cname="networkutils.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i return_code=0;
    local -i error_count=0;
    local -i ret_code=0;
    local checkForHostname;
    local isFQDN;
    local searchForNameInHosts;
    local returnedHostName;
    local resolver_entry;
    local search_domain;
    local -i start_epoch;
    local -i end_epoch;
    local -i runtime;

    (( ${#} != 1 )) && return 3;

    checkForHostname="${1}";

    if [[ -n "${checkForHostname}" ]]; then
        isFQDN="$(grep -E "^([a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]\.)+[a-zA-Z]{2,}$" <<< "${checkForHostname}")";

        if [[ -n "${isFQDN}" ]]; then
            [[ -n "${ret_code}" ]] && unset ret_code;

            host "${checkForHostname}" > /dev/null 2>&1;
            ret_code="${?}";

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                ## host not found in dns, lets see if its in the hosts table;
                ## NOTE: this assumes a properly formatted host entry in the form of <IP address> <FQDN> <alias(es)>;
                searchForNameInHosts="$(grep -m 1 "${checkForHostname}" "/etc/hosts" | awk '{print $2}')";
                ## entry found in /etc/hosts;
                if [[ -n "${searchForNameInHosts}" ]]; then
                    returnedHostName="${searchForNameInHosts}";
                fi
            else
                returnedHostName="${checkForHostname}";
            fi
        else
            ## loop through all the possible domain names in /etc/resolv.conf;
            ## change the IFS;
            IFS="${MODIFIED_IFS}";

            ## clean up home directory first;
            for resolver_entry in $(< "/etc/resolv.conf"); do
                [[ -z "${resolver_entry}" ]] && continue;
                [[ "${resolver_entry}" =~ ^\# ]] && continue;
                [[ "${resolver_entry}" =~ ^nameserver ]] && continue;

                if [[ "${resolver_entry}" =~ ^search ]]; then
                    search_domain="$(awk '{print $NF}' <<< "${resolver_entry}")";

                    ## check if in DNS...;
                    [[ -n "${ret_code}" ]] && unset ret_code;

                    host "${checkForHostname}.${search_domain}" > /dev/null 2>&1;
                    ret_code="${?}";

                    if [[ -n "${ret_code}" ]] && (( ret_code == 0 )); then
                        returnedHostName="${checkForHostname}.${search_domain}";

                        [[ -n "${ret_code}" ]] && unset ret_code;
                        [[ -n "${resolver_entry}" ]] && unset resolver_entry;

                        break;
                    fi
                fi

                [[ -n "${ret_code}" ]] && unset ret_code;
                [[ -n "${search_domain}" ]] && unset search_domain;
                [[ -n "${resolver_entry}" ]] && unset resolver_entry;
            done

            ## restore the original ifs;
            IFS="${CURRENT_IFS}";
        fi
    fi

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${error_count}" ]] && unset error_count;
    [[ -n "${ret_code}" ]] && unset ret_code;
    [[ -n "${checkForHostname}" ]] && unset checkForHostname;
    [[ -n "${isFQDN}" ]] && unset isFQDN;
    [[ -n "${searchForNameInHosts}" ]] && unset searchForNameInHosts;
    [[ -n "${resolver_entry}" ]] && unset resolver_entry;
    [[ -n "${search_domain}" ]] && unset search_domain;

    [[ -n "${start_epoch}" ]] && unset start_epoch;
    [[ -n "${end_epoch}" ]] && unset end_epoch;
    [[ -n "${runtime}" ]] && unset runtime;
    [[ -n "${function_name}" ]] && unset function_name;
    [[ -n "${cname}" ]] && unset cname;

    if [[ -n "${returnedHostName}" ]]; then printf "%s" "${returnedHostName}"; unset returnedHostName; else return_code=1; fi

    return "${return_code}";
)

#=====  FUNCTION  =============================================================;
#          NAME:  isValidHost;
#   DESCRIPTION:  Validates that a given host exists in DNS and is alive;
#    PARAMETERS:  Target host, port number (optional);
#       RETURNS:  0 if success, 1 otherwise;
#==============================================================================;
function checkForValidAddress()
(
    local cname="networkutils.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i return_code=0;
    local -i error_count=0;
    local -i ret_code=0;
    local -i counter=0;
    local checkForAddress;
    local split_up;
    local entry;
    local returnedHostAddress;
    local -i start_epoch;
    local -i end_epoch;
    local -i runtime;

    (( ${#} != 1 )) && return 3;

    checkForAddress="${1}";

    if [[ -n "${checkForAddress}" ]]; then
        [[ -n "${ret_code}" ]] && unset ret_code;

        # TODO: add isNaN here?
        grep -qE "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$" <<< "${checkForAddress}";
        ret_code="${?}";

        if [[ -n "${ret_code}" ]] && (( ret_code == 0 )); then
            mapfile -d "." -t split_up <<< "${checkForAddress}";

            for entry in "${split_up[@]}"; do
                [[ -z "${entry}" ]] && continue;

                # TODO: add isNaN here?
                if [[ ${entry} =~ ^([0-9]){1,3}$ ]] && (( entry <= 254 )); then
                    continue;
                else
                    (( counter += 1 ));

                    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]]; then
                        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Entry ${entry} is not numeric.";
                    fi
                fi

                [[ -n "${entry}" ]] && unset entry;
            done

            if [[ -z "${counter}" ]] || (( counter == 0 )); then returnedHostAddress="${checkForAddress}"; else return_code=1; fi
        else
            return_code=1;

            if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]]; then
                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "The provided information failed validation.";
            fi
        fi
    fi

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${error_count}" ]] && unset error_count;
    [[ -n "${ret_code}" ]] && unset ret_code;
    [[ -n "${counter}" ]] && unset counter;
    [[ -n "${checkForAddress}" ]] && unset checkForAddress;
    [[ -n "${split_up[*]}" ]] && unset split_up;
    [[ -n "${entry}" ]] && unset entry;

    [[ -n "${start_epoch}" ]] && unset start_epoch;
    [[ -n "${end_epoch}" ]] && unset end_epoch;
    [[ -n "${runtime}" ]] && unset runtime;
    [[ -n "${function_name}" ]] && unset function_name;
    [[ -n "${cname}" ]] && unset cname;

    if [[ -n "${returnedHostAddress}" ]]; then printf "%s" "${returnedHostAddress}"; unset returnedHostAddress; fi

    return "${return_code}";
)

#=====  FUNCTION  =============================================================;
#          NAME:  isValidHost;
#   DESCRIPTION:  Validates that a given host exists in DNS and is alive;
#    PARAMETERS:  Target host, port number (optional);
#       RETURNS:  0 if success, 1 otherwise;
#==============================================================================;
function checkForValidPort()
(
    local cname="networkutils.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i return_code=0;
    local -i error_count=0;
    local -i ret_code=0;
    local -i checkPortNumber;
    local -i returnedPortNumber;
    local -i start_epoch;
    local -i end_epoch;
    local -i runtime;

    (( ${#} != 1 )) && return 3;

    checkPortNumber="${1}";

    if [[ -n "${checkPortNumber}" ]]; then
        [[ -n "${ret_code}" ]] && unset ret_code;

        # TODO: add isNaN here?
        grep -qE "^[0-9]{1,5}$" <<< "${checkPortNumber}";
        ret_code="${?}";

        if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
            [[ -z "${ret_code}" ]] && return_code=1 || [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";
        else
            if (( checkPortNumber > 0 )) && (( checkPortNumber <= 65535 )); then
                returnedPortNumber="${checkPortNumber}";
            else
                return_code=1;
            fi
        fi
    fi

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${error_count}" ]] && unset error_count;
    [[ -n "${ret_code}" ]] && unset ret_code;
    [[ -n "${checkPortNumber}" ]] && unset checkPortNumber;

    [[ -n "${start_epoch}" ]] && unset start_epoch;
    [[ -n "${end_epoch}" ]] && unset end_epoch;
    [[ -n "${runtime}" ]] && unset runtime;
    [[ -n "${function_name}" ]] && unset function_name;
    [[ -n "${cname}" ]] && unset cname;

    if [[ -n "${returnedPortNumber}" ]]; then printf "%s" "${returnedPortNumber}"; unset returnedPortNumber; fi

    return "${return_code}";
);

#=====  FUNCTION  =============================================================;
#          NAME:  isValidHost;
#   DESCRIPTION:  Validates that a given host exists in DNS and is alive;
#    PARAMETERS:  Target host, port number (optional);
#       RETURNS:  0 if success, 1 otherwise;
#==============================================================================;
function checkIfHostIsAlive()
(
    local cname="networkutils.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i return_code=0;
    local -i error_count=0;
    local -i ret_code=0;
    local checkNetworkType;
    local checkNetworkName;
    local -i checkNetworkPort;
    local isHostAvailable;
    local -i start_epoch;
    local -i end_epoch;
    local -i runtime;

    (( ${#} != 3 )) && return 3;

    checkNetworkType="${1}";
    checkNetworkName="${2}";
    checkNetworkPort="${3}";

    if [[ -n "${checkNetworkType}" ]] && [[ -n "${checkNetworkName}" ]] && [[ -n "${checkNetworkPort}" ]]; then
        if [[ -n "$(shopt -u expand_aliases; command -v nc; shopt -s expand_aliases)" ]]; then
            [[ -n "${ret_code}" ]] && unset ret_code;

            case "${checkNetworkType}" in
                "[Tt][Cc][Pp]")
                    nc "${checkNetworkName}" "${checkNetworkPort}" > /dev/null 2>&1;
                    ;;
                "[Uu][Dd][Pp]")
                    nc -u "${checkNetworkName}" "${checkNetworkPort}" > /dev/null 2>&1;
                    ;;
            esac

            ret_code="${?}";

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                [[ -z "${ret_code}" ]] && return_code=1 || [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

                if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred while checking host availability via nc - no return code/a non-zero return code was received.";
                fi
            else
                if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]]; then
                    writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "Host ${checkNetworkName} is available and listening on ${checkNetworkPort}";
                fi
            fi
        elif [[ -n "$(shopt -u expand_aliases; command -v nmap; shopt -s expand_aliases)" ]]; then
            [[ -n "${isHostAvailable}" ]] && unset isHostAvailable;
            [[ -n "${ret_code}" ]] && unset ret_code;

            case "${checkNetworkType}" in
                "[Tt][Cc][Pp]")
                    isHostAvailable="$(nmap -T "${checkNetworkPort}" "${checkNetworkHost}" 2>/dev/null)";
                    ;;
                "[Uu][Dd][Pp]")
                    isHostAvailable="$(nmap -U "${checkNetworkPort}" "${checkNetworkHost}" 2>/dev/null)";
                    ;;
            esac

            ret_code="${?}";

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )) && [[ -z "${isHostAvailable}" ]] || [[ "${isHostAvailable}" != "open" ]]; then
                [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

                if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred while checking host availability via nmap - no return code/a non-zero return code was received.";
                fi
            else
                if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]]; then
                    writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "Host ${checkNetworkName} is available and listening on ${checkNetworkPort}";
                fi
            fi
        else
            case "${checkNetworkType}" in
                "[Tt][Cc][Pp]")
                    timeout "${REQUEST_TIMEOUT:-10}" bash -c "cat < /dev/null > /dev/tcp/${checkNetworkName}/${checkNetworkPort}";
                    ;;
                "[Uu][Dd][Pp]")
                    timeout "${REQUEST_TIMEOUT:-10}" bash -c "cat < /dev/null > /dev/udp/${checkNetworkName}/${checkNetworkPort}";
                    ;;
            esac

            ret_code="${?}";

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                [[ -z "${ret_code}" ]] && return_code=1 || [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

                if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred while checking host availability via bash - no return code/a non-zero return code was received.";
                fi
            else
                if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]]; then
                    writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "Host ${checkNetworkName} is available and listening on ${checkNetworkPort}";
                fi
            fi
        fi
    else
        return_code=1;

        if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "A hostname / port was not provided to perform validation against.";
        fi
    fi

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${error_count}" ]] && unset error_count;
    [[ -n "${ret_code}" ]] && unset ret_code;
    [[ -n "${checkNetworkName}" ]] && unset checkNetworkName;
    [[ -n "${checkNetworkPort}" ]] && unset checkNetworkPort;
    [[ -n "${isHostAvailable}" ]] && unset isHostAvailable;

    [[ -n "${start_epoch}" ]] && unset start_epoch;
    [[ -n "${end_epoch}" ]] && unset end_epoch;
    [[ -n "${runtime}" ]] && unset runtime;
    [[ -n "${function_name}" ]] && unset function_name;
    [[ -n "${cname}" ]] && unset cname;

    return "${return_code}";
)
