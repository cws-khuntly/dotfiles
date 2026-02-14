#!/usr/bin/env bash

#==============================================================================
#
#          FILE:  A02-git
#         USAGE:  . A02-git
#   DESCRIPTION:  Useful git aliases
#
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Kevin Huntly <kmhuntly@gmail.com>
#       COMPANY:  ---
#       VERSION:  1.0
#       CREATED:  ---
#      REVISION:  ---
#
#==============================================================================

[[ -z "$(compgen -c | grep -Ew "(^docker)" | sort | uniq)" ]] && return;

function loginToOCI() { docker login -u kmhuntly@gmail.com container-registry.oracle.com; }

#=====  FUNCTION  =============================================================
#          NAME:  createDockerNetwork
#   DESCRIPTION:  Returns a random string of alphanumeric characters
#    PARAMETERS:  Length of string, include special characters
#       RETURNS:  0 regardless of result.
#==============================================================================
function createDockerNetwork()
{
    local cname="15-docker.bashrc";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i return_code=0;
    local -i error_count=0;
    local -i ret_code=0;
    local network_name;
    local network_addr;
    local network_mask;
    local network_gateway;

    if (( ${#} != 4 )); then usage; return 3; fi

    network_name="${1}";
    network_addr="${2}"
    network_mask="${3}";
    network_gateway="${4}";

    docker network create --driver=bridge --subnet="${network_addr}"/"${network_mask}" --gateway "${network_gateway}" "${network_name}";

    return "${?}";
}

#=====  FUNCTION  =============================================================
#          NAME:  startDockerContainer
#   DESCRIPTION:  Returns a random string of alphanumeric characters
#    PARAMETERS:  Length of string, include special characters
#       RETURNS:  0 regardless of result.
#==============================================================================
function startDockerContainer()
{
    local cname="15-docker.bashrc";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i return_code=0;
    local -i error_count=0;
    local -i ret_code=0;
    local argument;
    local argument_name;
    local argument_value;
    local container_name;
    local action;

    #======  FUNCTION  ============================================================;
    #          NAME:  usage
    #   DESCRIPTION:
    #    PARAMETERS:  None
    #       RETURNS:  3
    #==============================================================================
    function usage()
    (
        local cname="15-docker.bashrc";
        local function_name="${cname}#${FUNCNAME[1]}";
        local return_code=3;

        printf "%s %s\n" "${FUNCNAME[1]}" "Return a string of random characters" >&2;
        printf "%s %s\n" "Usage: ${FUNCNAME[1]}" "[ options ]" >&2;
        printf "    %s: %s\n" "--container=value| -c <value>" "The container to start." >&2;
        printf "      %s: %s\n" "This should be the full path to the docker compose file." >&2;
        printf "    %s: %s\n" "--action=value| -a <value>" "The action to perform - one of \"up\" or \"down\"" >&2;

        [[ -n "${function_name}" ]] && unset -v function_name;
        [[ -n "${cname}" ]] && unset -v cname;

        return "${return_code}";
    )

    if (( ${#} == 0 )); then usage; return ${?}; fi

    while (( ${#} > 0 )); do
        argument="${1}";

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

        case "${argument_name}" in
            container|c) container_name="${argument_value}"; ;;
            action|a) action="${argument_value}"; ;;
            help|\?|h) usage; return_code="${?}"; ;;
            *)
                if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An invalid option has been provided and has been ignored. Option -> ${argument_name}, Value -> ${argument_value}";
                    writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An invalid option has been provided and has been ignored. Option -> ${argument_name}, Value -> ${argument_value}";
                fi
                ;;
        esac
    done

    if [[ ! -f "${container_name}" ]]; then
        return_code=1;

        if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "The container file ${container_name} does not exist.";
            writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "The container file ${container_name} does not exist.";
        fi
    else
        docker compose -f "${container}" "${action}";
        ret_code="${?}";

        if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
            return_code="${ret_code}";

            if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]]; then
                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "The docker compose command failed for file ${container_name} with action ${action}.";
                writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "The docker compose command failed for file ${container_name} with action ${action}.";
            fi
        fi
    fi

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${container_name}" ]] && unset -v container_name;
    [[ -n "${action}" ]] && unset -v action;
    [[ -n "${argument}" ]] && unset -v argument;
    [[ -n "${argument_name}" ]] && unset -v argument_name;
    [[ -n "${argument_value}" ]] && unset -v argument_value;

    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${cname}" ]] && unset -v cname;

    return "${return_code}";
}
