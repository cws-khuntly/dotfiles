#!/usr/bin/env bash

#==============================================================================
#
#          FILE:  22-ldap.bashrc
#         USAGE:  . 22-ldap.bashrc
#   DESCRIPTION:  Useful ldap things
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

[[ -z "$(compgen -c | grep -Ew "(^ldapsearch)" | sort | uniq)" ]] && return;

declare -x LDAPRC="${HOME}/.dotfiles/config/ldaprc";

[[ ! -d "${HOME}/workspace/ldap" ]] && mkdir -pv "${HOME}/workspace/ldap/{ldif,certs}";

#=====  FUNCTION  =============================================================
#          NAME:  fldapsearch
#   DESCRIPTION:  Returns a random string of alphanumeric characters
#    PARAMETERS:  Length of string, include special characters
#       RETURNS:  0 regardless of result.
#==============================================================================
function fldapsearch()
{
    local cname="01-functions.bashrc";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i return_code=0;
    local argument;
    local argument_name;
    local argument_value;
    local host;
    local -i port=389;
    local userdn;
    local basedn;
    local search_string;
    local usetls="${_FALSE}";
    local usessl="${_FALSE}";

    #======  FUNCTION  ============================================================;
    #          NAME:  usage
    #   DESCRIPTION:
    #    PARAMETERS:  None
    #       RETURNS:  3
    #==============================================================================
    function usage()
    (
        local cname="22-ldap.bashrc";
        local function_name="${cname}#${FUNCNAME[1]}";
        local return_code=3;

        printf "%s %s\n" "${FUNCNAME[1]}" "Return a string of random characters" >&2;
        printf "%s %s\n" "Usage: ${FUNCNAME[1]}" "[ options ]" >&2;
        printf "    %s: %s\n" "--host | -h" "The LDAP host to connect to." >&2;
        printf "    %s: %s\n" "--port | -p" "The LDAP port to connect to." >&2;
        printf "      %s: %s\n" "NOTE" "If not specified, defaults of 389/636 are used." >&2;
        printf "    %s: %s\n" "--usetls | -t" "Use a secure (StartTLS) connection." >&2;
        printf "    %s: %s\n" "--usessl | -s" "Use a secure (SSL) connection." >&2;
        printf "    %s: %s\n" "--auth | -a" "The user DN to authenticate as." >&2;
        printf "    %s: %s\n" "--basedn | -b" "The base DN to search in." >&2;
        printf "    %s: %s\n" "--search | -y" "The data to search." >&2;

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

                if [[ ! -z "${2}" ]]; then
                    shift 1;
                else
                    argument_value="${2}";

                    shift 2;
                fi
                ;;
        esac

        case "${argument_name}" in
            [Hh][Oo][Ss][Tt]|[Hh]) host="${argument_value}"; ;;
            [Pp][Oo][Rr][Tt]|[Pp]) port="${argument_value}"; ;;
            [Uu][Ss][Ee][Tt][Ll][Ss]|[Tt]) usetls="${_TRUE}"; ;;
            [Uu][Ss][Ee][Ss][Ss][Ss]|[Ss]) usessl="${_TRUE}"; ;;
            [Aa][Uu][Tt][Hh]|[Aa]) userdn="${argument_value}"; ;;
            [Bb][Aa][Ss][Ee]|[Bb]) basedn="${argument_value}"; ;:
            [Ss][Ee][Aa][Rr][Cc][Hh]|[Yy]) search_string="${argument_value}"; ;;
            help|\?|h) usage; return_code="${?}"; ;;
            *)
                if (( $(checkLoggingStatus "ERROR") == 0 )); then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An invalid option has been provided and has been ignored. Option -> ${argument_name}, Value -> ${argument_value}";
                    writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An invalid option has been provided and has been ignored. Option -> ${argument_name}, Value -> ${argument_value}";
                fi
                ;;
        esac
    done

    if [[ "${usetls}" == "${usessl}" ]] && [[ "${usetls}" == "${_TRUE}" ]]; then
        if (( $(checkLoggingStatus "ERROR") == O )); then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "StartTLS cannot be used with SSL.";
            writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "StartTLS cannot be used with SSL.";
        fi
    fi

    [[ "${usetls}" == "${_TRUE}" ]] && host="-ZZ ldap://${host}:${port:-636}";
    [[ "${usessl}" == "${_TRUE}" ]] && host="ldaps://${host}:${port:-636}";

    ldapsearch -x -H "${host}" -D "${userdn}" -W -b "${basedn}" -s sub "${search_string}";

    return_code="${?}";

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${search_string}" ]] && unset -v search_string;
    [[ -n "${usetls}" ]] && unset -v usetls;
    [[ -n "${usessl}" ]] && unset -v usessl;
    [[ -n "${port}" ]] && unset -v port;
    [[ -n "${argument}" ]] && unset -v argument;
    [[ -n "${argument_name}" ]] && unset -v argument_name;
    [[ -n "${argument_value}" ]] && unset -v argument_value;
    [[ -n "${host}" ]] && unset -v host;
    [[ -n "${userdn}" ]] && unset -v userdn;
    [[ -n "${basedn}" ]] && unset -v basedn;

    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${cname}" ]] && unset -v cname;

    return "${return_code}";
}

