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
#          NAME:  validateAndCopyKeysForHost
#   DESCRIPTION:  Reads a provided property file into the shell
#    PARAMETERS:  File
#       RETURNS:  0 if success, 1 otherwise
#==============================================================================
function validateAndCopyKeysForHost()
{
    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set -v; fi

    local cname="basefunctions.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i ret_code=0;
    local -i return_code=0;
    local -i error_count=0;
    local target_host;
    local -i target_port;
    local target_transport;
    local target_user;
    local returned_host;
    local -i returned_port;
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

    (( ${#} != 4 )) && return 3;

    target_transport="${1}";
    target_host="${2}";
    target_port="${3}";
    target_user="${4}";

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_host -> ${target_host}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_port -> ${target_port}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_transport -> ${target_transport}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_user -> ${target_user}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: validateHostAvailability ${target_transport} ${target_host} ${target_port}";
    fi

    [[ -n "${cname}" ]] && unset cname;
    [[ -n "${function_name}" ]] && unset function_name;
    [[ -n "${ret_code}" ]] && unset ret_code;

    host_data="$(validateHostAvailability "${target_transport}" "${target_host}" "${target_port}")";

    cname="basefunctions.sh";
    function_name="${cname}#${FUNCNAME[0]}";

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "host_data -> ${host_data}";
    fi

    if [[ -z "${host_data}" ]]; then
        return_code="${ret_code}"

        if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Host ${target_host} does not appear to be available. Please review logs.";
        fi
    else
        returned_host="$(cut -d ":" -f 1 <<< "${host_data}")";
        returned_port="$(cut -d ":" -f 2 <<< "${host_data}")";

        if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "returned_host -> ${returned_host}";
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "returned_port -> ${returned_port}";
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: getHostKeys ${returned_host} ${returned_port}";
        fi

        [[ -n "${cname}" ]] && unset cname;
        [[ -n "${function_name}" ]] && unset function_name;
        [[ -n "${ret_code}" ]] && unset ret_code;

        getHostKeys "${returned_host}" "${returned_port}";
        ret_code="${?}";

        cname="basefunctions.sh";
        function_name="${cname}#${FUNCNAME[0]}";

        if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "getHostKeys -> ret_code -> ${ret_code}";
        fi

        if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
            [[ -z "${ret_code}" ]] && return_code=1 || [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

            if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred getting SSH host keys from host ${returned_host}. Please review logs.";
            fi
        else
            if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: copyKeysToTarget ${returned_host} ${returned_port} ${target_user}";
            fi

            [[ -n "${cname}" ]] && unset cname;
            [[ -n "${function_name}" ]] && unset function_name;
            [[ -n "${ret_code}" ]] && unset ret_code;

            copyKeysToTarget "${returned_host}" "${returned_port}" "${target_user}";
            ret_code="${?}";

            cname="basefunctions.sh";
            function_name="${cname}#${FUNCNAME[0]}";

            if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "copyKeysToTarget -> ret_code -> ${ret_code}";
            fi

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                [[ -z "${ret_code}" ]] && return_code=1 || [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

                if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                    [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to execute copyKeysToTarget. Please review logs.";
                fi
            fi
        fi
    fi

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${ret_code}" ]] && unset ret_code;
    [[ -n "${error_count}" ]] && unset error_count;
    [[ -n "${target_host}" ]] && unset target_host;
    [[ -n "${target_port}" ]] && unset target_port;
    [[ -n "${target_transport}" ]] && unset target_transport;
    [[ -n "${target_user}" ]] && unset target_user;
    [[ -n "${returned_host}" ]] && unset returned_host;
    [[ -n "${returned_port}" ]] && unset returned_port;

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
#          NAME:  getHostKeys
#   DESCRIPTION:  Obtains and stores the public key for a remote SSH node
#    PARAMETERS:  Target host or private key to transform
#       RETURNS:  0 if success, 1 otherwise
#==============================================================================
function getHostKeys()
(
    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set -v; fi

    local cname="sshutils.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i return_code=0;
    local -i error_count=0;
    local does_key_exist;
    local -i ret_code;
    local remote_ssh_version;
    local remote_ssh_key;
    local target_host;
    local -i target_port;
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

    (( ${#} != 2 )) && return 3;

    target_host="${1}";
    target_port="${2}";

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_host -> ${target_host}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_port -> ${target_port}";
    fi

    if [[ "${target_host}" == "$(hostname -s)" ]] || [[ "${target_host}" == "$(hostname -f)" ]] || \
        [[ "${target_host}" == "localhost" ]] || [[ "${target_host}" == "localhost.localdomain" ]] || \
        [[ "${target_host}" == "127.0.0.1" ]] || [[ "${target_host}" == "::1" ]] || [[ "${target_host}" == "0:0:0:0:0:0:0:1" ]]; then

        return_code=0;
    else
        for keytype in "${SSH_HOST_KEYS[@]}"; do
            if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "keytype -> ${keytype}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: ssh-keygen -F ${target_host} 2>/dev/null | grep ${keytype}";
            fi

            [[ -n "${does_key_exist}" ]] && unset does_key_exist;
            [[ -n "${ret_code}" ]] && unset ret_code;

            does_key_exist="$(ssh-keygen "${target_host}" 2>/dev/null | grep "${keytype}")";
            ret_code="${?}";

            if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "does_key_exist -> ${does_key_exist}";
            fi

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )) && [[ -z "${does_key_exist}" ]]; then
                if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "wARN" "${$}" "${cname}" "${LINENO}" "${function_name}" "Key for host ${target_host} does not currently exist in known_hosts";
                fi
            fi

            if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: printf \"%s\n\" \"~\" | nc \"${target_host}\" ${target_port}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: ssh-keyscan -t \"${keytype}\" -p ${target_port} -H \"${target_host}\"";
            fi

            [[ -n "${remote_ssh_version}" ]] && unset remote_ssh_version;
            [[ -n "${remote_ssh_key}" ]] && unset remote_ssh_key;
            [[ -n "${ret_code}" ]] && unset ret_code;

            remote_ssh_version="$(printf "%s" "~" | nc "${target_host}" "${target_port}" 2>/dev/null | head -1 | tr -d $'\r')";
            remote_ssh_key="$(ssh-keyscan -t "${keytype}" -p "${target_port}" "${target_host}")";
            ret_code="${?}";

            if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "remote_ssh_version -> ${remote_ssh_version}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "remote_ssh_key -> ${remote_ssh_key}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "nc/${target_host},${target_port} -> ret_code -> ${ret_code}";
            fi

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )) && [[ -z "${remote_ssh_key}" ]] || [[ -z "${remote_ssh_version}" ]]; then
                (( error_count += 1 ));

                if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "wARN" "${$}" "${cname}" "${LINENO}" "${function_name}" "Unable to obtain keys for ${target_host}";
                fi
            else
                if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Found key ${remote_ssh_key} of type ${keytype}";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: printf \"# %s:%d %s\n\" \"${target_host}\" \"${target_port}\" \"${remote_ssh_version}\" >> \"${SSH_KNOWN_HOSTS}\"";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: printf \"%s\n\" \"${remote_ssh_key}\" >> \"${SSH_KNOWN_HOSTS}\"";
                fi

                printf "# %s:%d %s %s\n" "${target_host}" "${target_port}" "${keytype}" "${remote_ssh_version}" >> "${SSH_KNOWN_HOSTS}";
                printf "%s\n" "${remote_ssh_key}" >> "${SSH_KNOWN_HOSTS}";
            fi

            [[ -n "${keytype}" ]] && unset keytype;
            [[ -n "${does_key_exist}" ]] && unset does_key_exist;
            [[ -n "${remote_ssh_key}" ]] && unset remote_ssh_key;
        done

        (( error_count >= ${#SSH_HOST_KEYS[*]} )) && return_code="${error_count}";
    fi

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${error_count}" ]] && unset error_count;
    [[ -n "${does_key_exist}" ]] && unset does_key_exist;
    [[ -n "${ret_code}" ]] && unset ret_code;
    [[ -n "${remote_ssh_version}" ]] && unset remote_ssh_version;
    [[ -n "${remote_ssh_key}" ]] && unset remote_ssh_key;
    [[ -n "${target_host}" ]] && unset target_host;
    [[ -n "${target_port}" ]] && unset target_port;

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")";
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
#          NAME:  generateSshKeys
#   DESCRIPTION:  ssh's to a target host and removes the existing dotfiles
#                 directory and copies the new one
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function generateSshKeys()
(
    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set -v; fi

    local cname="sshutils.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i ret_code=0;
    local -i return_code=0;
    local -i error_count=0;
    local cmd_output;
    local available_ssh_key_type;
    local ssh_key_type;
    local ssh_key_size;
    local ssh_key_filename;
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

    if [[ ! -d "${HOME}"/.ssh ]]; then
        if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "SSH user configuration directory does not exist. Creating.";
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: mkdir ${HOME}/.ssh";
        fi

        [[ -n "${ret_code}" ]] && unset ret_code;

        cmd_output="$(mkdir "${HOME}"/.ssh)";
        ret_code="${?}";

        if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cmd_output -> ${cmd_output}";
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "mkdir/${HOME}/.ssh -> ret_code -> ${ret_code}";
        fi

        if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
            [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

            if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Unable to create ${HOME}/.ssh. Please review logs.";
            fi
        else
            if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Directory created: ${HOME}/.ssh;";
            fi
        fi
    fi

    if [[ -z "${return_code}" ]] || (( return_code == 0 )); then
        for available_ssh_key_type in "${SSH_KEY_TYPES[@]}"; do
            if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "available_ssh_key_type -> ${available_ssh_key_type}";
            fi

            ssh_key_type="$(cut -d "," -f 1 <<< "${available_ssh_key_type}")";
            ssh_key_size="$(cut -d "," -f 2 <<< "${available_ssh_key_type}")";
            ssh_key_filename="id_${ssh_key_type}";

            if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ssh_key_type -> ${ssh_key_type}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ssh_key_size -> ${ssh_key_size}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ssh_key_filename -> ${ssh_key_filename}";
            fi

            ## if it doesnt exist then make it. if it does exist skip it;
            if [[ ! -f "${HOME}"/.ssh/"${ssh_key_filename}" ]]; then
                if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: ${SSH_KEYGEN_PROGRAM} -b ${ssh_key_size} -t ${ssh_key_type} -f ${WORK_DIR}/${ssh_key_filename}";
                fi

                [[ -n "${ret_code}" ]] && unset ret_code;

                [[ "${ssh_key_type}" =~ [Rr][Ss][Aa] ]] && cmd_output="$(ssh-keygen -b "${ssh_key_size}" -f "${WORK_DIR}/${ssh_key_filename}" -t "${ssh_key_type}")";
                [[ ! "${ssh_key_type}" =~ [Rr][Ss][Aa] ]] && cmd_output="$(ssh-keygen -f "${WORK_DIR}/${ssh_key_filename}" -t "${ssh_key_type}")";
                ret_code="${?}";

                if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cmd_output -> ${cmd_output}";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${SSH_KEYGEN_PROGRAM}/${ssh_key_filename} -> ret_code -> ${ret_code}";
                fi

                if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                    (( error_count += 1 ));

                    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "SSH keyfile generation for type ${ssh_key_type} failed with return code ${ret_code}";
                    fi
                else
                    if [[ ! -f "${WORK_DIR}/${ssh_key_filename}" ]]; then
                        (( error_count += 1 ));

                        if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "SSH keyfile generation for type ${ssh_key_type} failed with return code ${ret_code}";
                        fi
                    else
                        if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: mv ${WORK_DIR}/${ssh_key_filename} ${HOME}/.ssh/${ssh_key_filename}";
                            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: mv ${WORK_DIR}/${ssh_key_filename}.pub ${HOME}/.ssh/${ssh_key_filename}.pub";
                        fi

                        ## relocate the keyfiles to the user home directory;
                        mv "${WORK_DIR}/${ssh_key_filename}" "${HOME}/.ssh/${ssh_key_filename}";
                        mv "${WORK_DIR}/${ssh_key_filename}.pub" "${HOME}/.ssh/${ssh_key_filename}.pub";

                        ## make sure they exist;
                        if [[ ! -f "${HOME}/.ssh/${ssh_key_filename}" ]] || [[ ! -f "${HOME}/.ssh/${ssh_key_filename}.pub" ]]; then
                            (( error_count += 1 ));

                            if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "SSH keyfile generation for type ${ssh_key_type} failed with return code ${ret_code}";
                            fi
                        fi
                    fi
                fi
            fi

            [[ -n "${cmd_output}" ]] && unset cmd_output;
            [[ -n "${ssh_key_type}" ]] && unset ssh_key_type;
            [[ -n "${ssh_key_size}" ]] && unset ssh_key_size;
            [[ -n "${ssh_key_filename}" ]] && unset ssh_key_filename;
            [[ -n "${ret_code}" ]] && unset ret_code;
        done
    fi

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${cmd_output}" ]] && unset cmd_output;
    [[ -n "${ssh_key_type}" ]] && unset ssh_key_type;
    [[ -n "${ssh_key_size}" ]] && unset ssh_key_size;
    [[ -n "${ssh_key_filename}" ]] && unset ssh_key_filename;
    [[ -n "${available_ssh_key_type}" ]] && unset available_ssh_key_type;
    [[ -n "${ret_code}" ]] && unset ret_code;

    if [[ -n "${error_count}" ]] && (( error_count != 0 )) && (( error_count >= ${#SSH_KEY_TYPES[@]} )); then return_code="${error_count}"; fi

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")";
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
#          NAME:  deployFiles
#   DESCRIPTION:  ssh's to a target host and removes the existing dotfiles
#                 directory and copies the new one
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function copyKeysToTarget()
(
    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set -v; fi

    local cname="sshutils.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i ret_code=0;
    local -i return_code=0;
    local -i error_count=0;
    local continue_exec="${_TRUE}";
    local target_host;
    local -i target_port;
    local target_user;
    local keyfile;
    local sshpass;
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

    target_host="${1}";
    target_port="${2}";
    target_user="${3}";

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_host -> ${target_host}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_port -> ${target_port}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_user -> ${target_user}";
    fi

    if [[ -n "${SSH_KEY_LIST[*]}" ]] && (( ${#SSH_KEY_LIST[*]} != 0 )); then
        while [[ -z "${sshpass}" ]]; do
            if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Capture user input:";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: read -s -rp Password for ${target_user}@${target_host}: \" sshpass";
            fi

            read -s -rp "Password for ${target_user}@${target_host}: " sshpass;
        done

        for keyfile in "${SSH_KEY_LIST[@]}"; do
            if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "keyfile -> ${keyfile}";
            fi

            [[ -z "${keyfile}" ]] && continue;

            ## check if the file actually exists, if its not there just skip it;
            if [[ -f "${keyfile}" ]] && [[ -r "${keyfile}" ]]; then
                if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Copying public key ${keyfile}";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: ssh-copy-id -i ${keyfile} -oPort=${target_port:-${SSH_PORT_NUMBER}} ${target_user}@${target_host}";
                fi

                [[ -n "${ret_code}" ]] && unset ret_code;

                cmd_output="$(echo "${sshpass}" | ssh-copy-id "${keyfile}" -oPort="${target_port:-${SSH_PORT_NUMBER}}" "${target_user}@${target_host}")";
                ret_code="${?}";

                if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ssh-copy-id/${keyfile} -> ret_code -> ${ret_code}";
                fi

                if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                    (( error_count += 1 ));

                    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to copy SSH identity ${keyfile} to host ${target_host}";
                    fi
                else
                    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "SSH keyfile ${keyfile} applied to host ${target_host} as user ${target_user}";
                    fi
                fi
            else
                ## NOT incrementing an error counter here because im not sure we actually need it;
                if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "WARN" "${$}" "${cname}" "${LINENO}" "${function_name}" "Unable to open keyfile ${keyfile}. Please ensure the file exists and can be read by the current user.";
                fi
            fi

            [[ -n "${ret_code}" ]] && unset ret_code;
            [[ -n "${keyfile}" ]] && unset keyfile;
        done
    else
        return_code=1;

        if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "No SSH key list was provided.";
        fi
    fi

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${ret_code}" ]] && unset ret_code;
    [[ -n "${continue_exec}" ]] && unset continue_exec;
    [[ -n "${target_host}" ]] && unset target_host;
    [[ -n "${target_port}" ]] && unset target_port;
    [[ -n "${target_user}" ]] && unset target_user;
    [[ -n "${keyfile}" ]] && unset keyfile;
    [[ -n "${error_count}" ]] && unset error_count;

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")";
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
#          NAME:  fssh
#   DESCRIPTION:  Obtains and stores the public key for a remote SSH node
#    PARAMETERS:  Target host or private key to transform
#       RETURNS:  0 if success, 1 otherwise
#==============================================================================
function fssh()
(
    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set -v; fi

    local cname="sshutils.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i return_code=0;
    local -i error_count=0;
    local -i ret_code;
    local sshconfig;
    local target_host;
    local -i target_port;
    local target_user;
    local run_cmd;
    local cmd_output;
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

    (( ${#} != 6 )) && return 3;

    sshconfig="${1}";
    target_host="${2}";
    target_port="${3}";
    target_user="${4}";
    run_cmd="${5}";

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "sshconfig -> ${sshconfig}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_host -> ${target_host}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_port -> ${target_port}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_user -> ${target_user}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "run_cmd -> ${run_cmd}";
    fi

    if [[ ! -f "${sshconfig}" ]] && [[ ! -r "${sshconfig}" ]] && [[ ! -f "${sshkey}" ]] && [[ ! -r "${sshkey}" ]]; then
        return_code=1;

        if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided SSH configuration file could not be found or was not readable.";
        fi
    else
        cmd_output="$(ssh "${target_host}" "${run_cmd}")";
        ret_code="${?}";

        if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cmd_output -> ${cmd_output}";
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ssh / run_cmd -> ret_code -> ${ret_code}";
        fi

        if [[ -z "${ret_code}" ]] || (( ret_code != 0 )) && [[ -z "${verify_response}" ]] || (( verify_response != 0 )); then
            [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

            if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred running command ${run_cmd} on remote host ${target_host}.";
            fi
        fi
    fi

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${error_count}" ]] && unset error_count;
    [[ -n "${ret_code}" ]] && unset ret_code;
    [[ -n "${sshconfig}" ]] && unset sshconfig;
    [[ -n "${sshkey}" ]] && unset sshkey;
    [[ -n "${target_host}" ]] && unset target_host;
    [[ -n "${target_port}" ]] && unset target_port;
    [[ -n "${target_user}" ]] && unset target_user;
    [[ -n "${run_cmd}" ]] && unset run_cmd;
    [[ -n "${cmd_output}" ]] && unset cmd_output;

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")";
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
#          NAME:  fsftp
#   DESCRIPTION:  Obtains and stores the public key for a remote SSH node
#    PARAMETERS:  Target host or private key to transform
#       RETURNS:  0 if success, 1 otherwise
#==============================================================================
function fsftp()
(
    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set -v; fi

    local cname="sshutils.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i return_code=0;
    local -i error_count=0;
    local -i ret_code;
    local sshconfig;
    local target_host;
    local -i target_port;
    local target_user;
    local sftpfile;
    local cmd_output;
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

    (( ${#} != 5 )) && return 3;

    sshconfig="${1}";
    target_host="${2}";
    target_port="${3}";
    target_user="${4}";
    sftpfile="${5}";

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "sshconfig -> ${sshconfig}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_host -> ${target_host}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_port -> ${target_port}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_user -> ${target_user}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "sftpfile -> ${sftpfile}";
    fi

    if [[ ! -f "${sshconfig}" ]] && [[ ! -r "${sshconfig}" ]]; then
        return_code=1;

        if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided SSH configuration file could not be found or was not readable.";
        fi
    else
        cmd_output="$(sftp -b "${sftpfile}" "${target_user}@${target_host}")";
        ret_code="${?}";

        if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cmd_output -> ${cmd_output}";
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ssh / run_cmd -> ret_code -> ${ret_code}";
        fi

        if [[ -z "${ret_code}" ]] || (( ret_code != 0 )) && [[ -z "${verify_response}" ]] || (( verify_response != 0 )); then
            [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

            if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred running command ${run_cmd} on remote host ${target_host}.";
            fi
        fi
    fi

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${error_count}" ]] && unset error_count;
    [[ -n "${ret_code}" ]] && unset ret_code;
    [[ -n "${sshconfig}" ]] && unset sshconfig;
    [[ -n "${target_host}" ]] && unset target_host;
    [[ -n "${target_port}" ]] && unset target_port;
    [[ -n "${target_user}" ]] && unset target_user;
    [[ -n "${sftpfile}" ]] && unset sftpfile;
    [[ -n "${cmd_output}" ]] && unset cmd_output;

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")";
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
