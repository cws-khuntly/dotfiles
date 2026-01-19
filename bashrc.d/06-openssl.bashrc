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
    local cname="basefunctions.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i return_code=0;
    local -i error_count=0;
    local -i ret_code=0;
    local -i string_count=1;
    local -i counter=0;
    local argument;
    local argument_name;
    local argument_value;
    local key_type;
    local key_curve;
    local msg_digest;
    local key_file;
    local csr_file;
    local returned_characters;

    #======  FUNCTION  ============================================================;
    #          NAME:  usage
    #   DESCRIPTION:
    #    PARAMETERS:  None
    #       RETURNS:  3
    #==============================================================================
    function usage()
    (
        local cname="01-functions.bashrc";
        local function_name="${cname}#${FUNCNAME[1]}";
        local return_code=3;

        printf "%s %s\n" "${FUNCNAME[1]}" "Generate an OpenSSL server key and CSR" >&2;
        printf "%s %s\n" "Usage: ${FUNCNAME[1]}" "[ options ]" >&2;
        printf "    %s: %s\n" "--type=<value> | -t <value>" "The type of key to generate." >&2;
        printf "      %s\n" "Valid options are:";
        printf "        %s\n" "ECC";
        printf "        %s\n" "RSA"
        printf "    %s: %s\n" "--curve <value> | -c <value>" "The elliptic curve to use when key type == ECC";
        printf "    %s: %s\n" "--digest=<value> | -d <value>" "The message digest to utilize.";
        printf "    %s: %s\n" "--name=value| -n <value>" "The name of the generated file." >&2;
        printf "    %s: %s\n" "--alt=value| -a <value>" "The subjectAltNames to add." >&2;

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
            type|t) key_type="${argument_value}"; ;;
            curve|c) key_curve="${argument_value}"; ;;
            digest|d) msg_digest="${argument_value}"; ;;
            name|n) file_name="${argument_value}"; ;;
            alt|a) alt_names="${argument_value}"; ;;
            help|\?|h) usage; return_code="${?}"; ;;
            *)
                if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An invalid option has been provided and has been ignored. Option -> ${argument_name}, Value -> ${argument_value}";
                    writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An invalid option has been provided and has been ignored. Option -> ${argument_name}, Value -> ${argument_value}";
                fi
                ;;
        esac
    done

    case "${key_type}" in
        [Rr][Ss][Aa])
            openssl genrsa -aes256 -out "${file_name}.key" ${key_size};
            ret_code="${?}";

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred generating the key file.";
                    writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred generating the key file.";
                fi

                return_code=1;
            else
                openssl req -config openssl.cnf -key "${file_name}.key" -new -"${msg_digest}" -out "${file_name}.csr" -addext "subjectAltName = ${alt_names}"
                ret_code="${?}";

                if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]]; then
                        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred generating the CSR.";
                        writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred generating the CSR.";
                    fi

                    return_code=1;
                fi
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
                openssl ecparam -out "${file_name}.key" -name "${key_curve}" -genkey;
                ret_code="${?}";

                if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                    if [[ -n "$(compgen -A function | grep -Ew "(^writeLogEntry)")" ]]; then
                        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred generating the key file.";
                        writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred generating the key file.";
                    fi
    
                    return_code=1;
                else
                    openssl req -config openssl.cnf -key "${file_name}.key" -new -"${msg_digest}" -out "${file_name}.csr" -addext "subjectAltName = ${alt_names}"
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
    [[ -n "${string_count}" ]] && unset -v string_count;
    [[ -n "${counter}" ]] && unset -v counter;
    [[ -n "${argument}" ]] && unset -v argument;
    [[ -n "${argument_name}" ]] && unset -v argument_name;
    [[ -n "${argument_value}" ]] && unset -v argument_value;
    [[ -n "${string_length}" ]] && unset -v string_length;
    [[ -n "${use_special}" ]] && unset -v use_special;
    [[ -n "${returned_characters}" ]] && unset -v returned_characters;

    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${cname}" ]] && unset -v cname;

    return "${return_code}";
}
