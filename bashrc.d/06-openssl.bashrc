#!/usr/bin/env bash

#==============================================================================
#
#          FILE:  A05-openssl
#         USAGE:  . A05-openssl
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

[[ -z "$(compgen -c | grep -Ew "(^openssl)" | sort | uniq)" ]] && return;

alias sha512sum='openssl sha512';
alias checkCSR='openssl req -text -noout -verify -in';

#=====  FUNCTION  =============================================================
#          NAME:  returnRandomCharacters
#   DESCRIPTION:  Returns a random string of alphanumeric characters
#    PARAMETERS:  Length of string, include special characters
#       RETURNS:  0 regardless of result.
#==============================================================================
function createServerKeyAndCSR()
{
    local cname="06-openssl.bashrc";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i return_code=0;
    local -i error_count=0;
    local -i ret_code=0;
    local argument;
    local argument_name;
    local argument_value;
    local key_type;
    local key_curve;
    local msg_digest;
    local key_file;
    local csr_file;
    local addext;

    #======  FUNCTION  ============================================================;
    #          NAME:  usage
    #   DESCRIPTION:
    #    PARAMETERS:  None
    #       RETURNS:  3
    #==============================================================================
    function usage()
    (
        local cname="06-openssl.bashrc";
        local function_name="${cname}#${FUNCNAME[1]}";
        local return_code=3;

        printf "%s %s\n" "${FUNCNAME[1]}" "Generate an OpenSSL server key and CSR" >&2;
        printf "%s %s\n" "Usage: ${FUNCNAME[1]}" "[ options ]" >&2;
        printf "    %s: %s\n" "--type=<value> | -t <value>" "The type of key to generate." >&2;
        printf "      %s\n" "Valid options are:";
        printf "        %s\n" "ECC";
        printf "        %s\n" "RSA"
        printf "    %s: %s\n" "--size | -s" "The size of the key to generate. When 'type' is ECC, this value is fixed at 512."
        printf "    %s: %s\n" "--curve | -c" "The elliptic curve to use when key type == ECC";
        printf "    %s: %s\n" "--name | -n" "The name of the generated file." >&2;
        printf "    %s: %s\n" "--addext | -a" "Add extensions to the request. Setting this flag will open the OpenSSL configuration file in vi for editing." >&2;

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

                if [[ -z "${2}" ]]; then shift 1; else argument_value="${2}"; shift 2; fi
                ;;
        esac

        case "${argument_name}" in
            [Tt][Yy][Pp][Ee]|[Tt]) key_type="${argument_value}"; ;;
            [Ss][Ii][Zz][Ee]|[Ss]) key_size="${argument_value}"; ;;
            [Cc][Uu][Rr][Vv][Ee]|[Cc]) key_curve="${argument_value}"; ;;
            [Nn][Aa][Mm][Ee]|[Nn]) file_name="${argument_value}"; ;;
            [Aa][Dd][Ee][Xx][Tt]|[Aa]) addext="${_TRUE}"; ;;
            help|\?|h) usage; return_code="${?}"; ;;
            *)
                if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An invalid option has been provided and has been ignored. Option -> ${argument_name}, Value -> ${argument_value}";
                    writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An invalid option has been provided and has been ignored. Option -> ${argument_name}, Value -> ${argument_value}";
                fi
                ;;
        esac
    done

    if [[ ! -z "${addext}" ]] && [[ "${addext}" == "${_TRUE}" ]]; then vi "${HOME}/workspace/openssl/conf/openssl.cnf"; fi

    case "${key_type}" in
        [Rr][Ss][Aa])
            openssl req -config "${HOME}/workspace/openssl/conf/openssl.cnf" -extensions v3_req -newkey "rsa:${key_size}" -keyout "${HOME}/workspace/openssl/private/${file_name}.key" -out "${HOME}/workspace/openssl/csr/${file_name}.csr";
            ret_code="${?}";

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred generating the CSR.";
                    writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred generating the CSR.";
                fi

                return_code=1;
            fi
            ;;
        [Ee][Cc][Cc])
            if [[ -z "${key_curve}" ]]; then
                if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Key type ${key_type} was provided but no curve was provided.";
                    writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Key type ${key_type} was provided but no curve was provided.";
                fi

                return_code=1;
            else
                openssl ecparam -out "${HOME}/workspace/openssl/private/${file_name}.key" -name "${key_curve}" -genkey;
                ret_code="${?}";

                if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]]; then
                        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred generating the key file.";
                        writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred generating the key file.";
                    fi
    
                    return_code=1;
                else
                    openssl req -config "${HOME}/workspace/openssl/conf/openssl.cnf" -extensions v3_req -key "${HOME}/workspace/openssl/private/${file_name}.key" -out "${HOME}/workspace/openssl/csr/${file_name}.csr";
                    ret_code="${?}";
    
                    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                        if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]]; then
                            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred generating the CSR.";
                            writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred generating the CSR.";
                        fi
    
                        return_code=1;
                    fi
                fi
            fi
            ;;
        *)
            (( error_count += 1 ));

            if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]]; then
                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred generating the CSR.";
                    writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred generating the CSR.";
                fi
            ;;
    esac

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${argument}" ]] && unset -v argument;
    [[ -n "${argument_name}" ]] && unset -v argument_name;
    [[ -n "${argument_value}" ]] && unset -v argument_value;
    [[ -n "${key_type}" ]] && unset -v key_type;
    [[ -n "${key_curve}" ]] && unset -v key_curve;
    [[ -n "${msg_digest}" ]] && unset -v msg_digest;
    [[ -n "${key_type}" ]] && unset -v key_type;
    [[ -n "${key_file}" ]] && unset -v key_file;
    [[ -n "${csr_file}" ]] && unset -v csr_file;
    [[ -n "${addext}" ]] && unset -v addext;

    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${cname}" ]] && unset -v cname;

    return "${return_code}";
}

#=====  FUNCTION  =============================================================
#          NAME:  returnRandomCharacters
#   DESCRIPTION:  Returns a random string of alphanumeric characters
#    PARAMETERS:  Length of string, include special characters
#       RETURNS:  0 regardless of result.
#==============================================================================
function createKeystore()
{
    local cname="06-openssl.bashrc";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i return_code=0;
    local -i error_count=0;
    local -i ret_code=0;
    local argument;
    local argument_name;
    local argument_value;
    local key_file;
    local crt_file;
    local store_file;

    #======  FUNCTION  ============================================================;
    #          NAME:  usage
    #   DESCRIPTION:
    #    PARAMETERS:  None
    #       RETURNS:  3
    #==============================================================================
    function usage()
    (
        local cname="06-openssl.bashrc";
        local function_name="${cname}#${FUNCNAME[1]}";
        local return_code=3;

        printf "%s %s\n" "${FUNCNAME[1]}" "Generate a PKCS#12 keystore using OpenSSL" >&2;
        printf "%s %s\n" "Usage: ${FUNCNAME[1]}" "[ options ]" >&2;
        printf "    %s: %s\n" "--keyfile | -k" "The key file associated with the certificate." >&2;
        printf "    %s: %s\n" "--certfile | -c" "The certificate related to the key.";
        printf "    %s: %s" "--alias | -a" "The alias for the keypair within the keystore."
        printf "    %s: %s\n" "--file | -f" "The keystore filename.";

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

                if [[ -z "${2}" ]]; then shift 1; else argument_value="${2}"; shift 2; fi
                ;;
        esac

        case "${argument_name}" in
            [Kk][Ee][Yy][Ff][Ii][Ll][Ee]|[Kk]) key_file="${argument_value}"; ;;
            [Cc][Ee][Rr][Tt][Ff][Ii][Ll][Ee]|[Cc]) cert_file="${argument_value}"; ;;
            [Aa][Ll][Ii][Aa][Ss]|[Aa]) key_alias="${argument_value}"; ;;
            [Ff][Ii][Ll][Ee]|[Ff]) store_file="${argument_value}"; ;;
            help|\?|h) usage; return_code="${?}"; ;;
            *)
                if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An invalid option has been provided and has been ignored. Option -> ${argument_name}, Value -> ${argument_value}";
                    writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An invalid option has been provided and has been ignored. Option -> ${argument_name}, Value -> ${argument_value}";
                fi
                ;;
        esac
    done

    openssl pkcs12 -export -in "${cert_file}" -inkey "${key_file}" -out "${HOME}/workspace/openssl/keystore/${file}.p12" -name "${key_alias}";
    ret_code="${?}";

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${counter}" ]] && unset -v counter;
    [[ -n "${argument}" ]] && unset -v argument;
    [[ -n "${argument_name}" ]] && unset -v argument_name;
    [[ -n "${argument_value}" ]] && unset -v argument_value;
    [[ -n "${key_file}" ]] && unset -v key_file;
    [[ -n "${crt_file}" ]] && unset -v crt_file;
    [[ -n "${store_file}" ]] && unset -v store_file;

    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${cname}" ]] && unset -v cname;

    return "${return_code}";
}

#=====  FUNCTION  =============================================================
#          NAME:  returnRandomCharacters
#   DESCRIPTION:  Returns a random string of alphanumeric characters
#    PARAMETERS:  Length of string, include special characters
#       RETURNS:  0 regardless of result.
#==============================================================================
function signCSR() { sudo -u certadm openssl ca -config "/opt/tls/${1}/intermediate/conf/openssl.cnf" -in "/opt/tls/${1}/intermediate/csr/${2}.csr" -out "/opt/tls/${1}/intermediate/certs/${2}.crt" -extensions server_cert; }
