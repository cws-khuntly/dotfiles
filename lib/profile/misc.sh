#!/usr/bin/env bash

#==============================================================================
#          FILE:  misc.sh
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
#          NAME:  mkcd
#   DESCRIPTION:  Creates a directory and then changes into it
#    PARAMETERS:  Directory to create
#       RETURNS:  0 if success, 1 otherwise
#==============================================================================
function mkcd()
{
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    local cname="misc.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local return_code=0;
    local error_count=0;
    local ret_code=0;
    local directory_to_create;
    local cmd_output;
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

    #======  FUNCTION  ============================================================
    #          NAME:  usage
    #   DESCRIPTION:
    #    PARAMETERS:  None
    #       RETURNS:  3
    #==============================================================================;
    function usage()
    (
        if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
        if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

        local cname="misc.sh";
        local function_name="${cname}#${FUNCNAME[1]}";
        local return_code=3;

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        fi

        printf "%s %s\n" "${FUNCNAME[1]}" "Create a given directory and change into it." >&2;
        printf "%s %s\n" "Usage: ${FUNCNAME[1]}" "[ directory ]" >&2;
        printf "    %s: %s\n" "<directory name>" "The name of the directory to create and change into." >&2;

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
        fi

        [[ -n "${function_name}" ]] && unset -v function_name;
        [[ -n "${cname}" ]] && unset -v cname;

        if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
        if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

        return "${return_code}";
    )

    if (( ${#} == 0 )) then usage; return "${?}"; fi

    directory_to_create="${1}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "directory_to_create -> ${directory_to_create}";
    fi

    [[ -n "${cmd_output}" ]] && unset -v cmd_output;
    [[ -n "${ret_code}" ]] && unset -v ret_code;

    cmd_output="$(mkdir -pv "${directory_to_create}")";
    ret_code="${?}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cmd_output -> ${cmd_output}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "mkdir/${directory_to_create} -> ret_code -> ${ret_code}";
    fi

    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )) then
        return_code="${ret_code}";

        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to create directory ${directory_to_create}";
        fi

        cd "${directory_to_create}" || return_code=1;

        if [[ "${PWD}" != "${directory_to_create}" ]]; then
            return_code=1;

            if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Unable to traverse requested directory ${directory_to_create}";
            fi
        fi
    else
        return_code=1;

        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to create requested directory ${directory_to_create}";
        fi
    fi

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${directory_to_create}" ]] && unset -v directory_to_create;
    [[ -n "${cmd_output}" ]] && unset -v cmd_output;

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")";
        runtime=$(( end_epoch - start_epoch ))

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

#=====  FUNCTION  =============================================================
#          NAME:  lsz
#   DESCRIPTION:  Lists the content of a provided archive
#    PARAMETERS:  Archive to list
#       RETURNS:  0 if success, 1 otherwise
#==============================================================================
function lsz()
{
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    local cname="misc.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local return_code=0;
    local error_count=0;
    local ret_code=0;
    local file_to_view;
    local file_of_type;
    local extract_to_dir;
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

    #======  FUNCTION  ============================================================
    #          NAME:  usage
    #   DESCRIPTION:
    #    PARAMETERS:  None
    #       RETURNS:  3
    #==============================================================================
    function usage()
    (
        if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
        if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

        local cname="misc.sh";
        local function_name="${cname}#${FUNCNAME[1]}";
        local return_code=3;

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        fi

        printf "%s %s\n" "${FUNCNAME[1]}" "Create a given directory and change into it." >&2;
        printf "%s %s\n" "Usage: ${FUNCNAME[1]}" "[ archive ]" >&2;
        printf "    %s: %s\n" "<archive>" "The path/name of the archive to inspect." >&2;

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
        fi

        [[ -n "${function_name}" ]] && unset -v function_name;
        [[ -n "${cname}" ]] && unset -v cname;

        if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
        if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

        return "${return_code}";
    )

    if (( ${#} == 0 )) then usage; return "${?}"; fi

    file_to_view="${1}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "file_to_view -> ${file_to_view}";
    fi

    if [[ -s "${file_to_view}" ]]; then
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: mktemp --tmpdir=${TMPDIR:-${USABLE_TMP_DIR}}";
        fi

        file_of_type="${file_to_view##*.}";
        extract_to_dir="$(mktemp --tmpdir="${TMPDIR:-${USABLE_TMP_DIR}}")";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "file_of_type -> ${file_of_type}";
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "extract_to_dir -> ${extract_to_dir}";
        fi

        case "${file_of_type}" in
            tar|Z) tar tvf "${file_to_view}"; ;;
            tar.bz2|bz|bz2|tbz2) bunzip2 < "${file_to_view}" | tar tvf -; ;;
            tar.gz|gz|tgz) gunzip < "${file_to_view}" | tar tvf -; ;;
            jar|zip) unzip -l "${file_to_view}"; ;;
            7z) 7z -l -o "${file_to_view}"; ;;
            *)
                return_code=1;

                if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Archive file type not recognized. File extension obtained: ${file_of_type}";
                fi
                ;;
        esac;
    else
        return_code=1;

        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided file ${file_to_view} does not exist or cannot be read.";
            writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided file ${file_to_view} does not exist or cannot be read.";
        fi
    fi

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${file_to_view}" ]] && unset -v file_to_view;
    [[ -n "${file_of_type}" ]] && unset -v file_of_type;
    [[ -n "${extract_to_dir}" ]] && unset -v extract_to_dir;

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")";
        runtime=$(( end_epoch - start_epoch ))

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

#=====  FUNCTION  =============================================================
#          NAME:  extract
#   DESCRIPTION:  Extracts the provided archive
#    PARAMETERS:  Archive to extract
#       RETURNS:  0 if success, 1 otherwise
#==============================================================================
function extract()
{
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    local cname="misc.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local return_code=0;
    local error_count=0;
    local ret_code=0;
    local file_to_extract;
    local file_of_type;
    local extract_to_dir;
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

    #======  FUNCTION  ============================================================
    #          NAME:  usage
    #   DESCRIPTION:
    #    PARAMETERS:  None
    #       RETURNS:  3
    #==============================================================================
    function usage()
    (
        if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
        if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

        local cname="F02-misc";
        local function_name="${cname}#${FUNCNAME[1]}";
        local return_code=3;

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        fi

        printf "%s %s\n" "${FUNCNAME[1]}" "Create a given directory and change into it." >&2;
        printf "%s %s\n" "Usage: ${FUNCNAME[1]}" "[ archive ]" >&2;
        printf "    %s: %s\n" "<archive>" "The path/name of the archive to extract." >&2;

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
        fi

        [[ -n "${function_name}" ]] && unset -v function_name;
        [[ -n "${cname}" ]] && unset -v cname;

        if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
        if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

        return "${return_code}";
    )

    if (( ${#} == 0 )) then usage; return "${?}"; fi

    file_to_extract="${1}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "file_to_view -> ${file_to_view}";
    fi

    if [[ -s "${file_to_view}" ]]; then
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: mktemp --tmpdir=${TMPDIR:-${USABLE_TMP_DIR}}";
        fi

        file_of_type="${file_to_view##*.}";
        extract_to_dir="$(mktemp --tmpdir="${TMPDIR:-${USABLE_TMP_DIR}}")";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "file_of_type -> ${file_of_type}";
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "extract_to_dir -> ${extract_to_dir}";
        fi

        case "${file_of_type}" in
            tar|Z) tar xf "${file_to_extract}" -C "${extract_to_dir}"; ;;
            tar.bz2|bz|bz2|tbz2) bunzip2 < "${file_to_extract}" | tar xf - -C "${extract_to_dir}"; ;;
            tar.gz|gz|tgz) gunzip < "${file_to_extract}" | tar xf - -C "${extract_to_dir}"; ;;
            jar|zip) unzip "${file_to_extract}" -d "${extract_to_dir}"; ;;
            7z) 7z e -o "${extract_to_dir}" "${file_to_extract}"; ;;
            *)
                return_code=1;

                if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Archive file type not recognized. File extension obtained: ${file_of_type}";
                    writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Archive file type not recognized. File extension obtained: ${file_of_type}";
                fi
                ;;
        esac
    else
        return_code=1;

        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided file ${file_to_view} does not exist or cannot be read.";
            writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided file ${file_to_view} does not exist or cannot be read.";
        fi
    fi

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${file_to_extract}" ]] && unset -v file_to_extract;
    [[ -n "${file_of_type}" ]] && unset -v file_of_type;
    [[ -n "${extract_to_dir}" ]] && unset -v extract_to_dir;

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")";
        runtime=$(( end_epoch - start_epoch ))

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

#=====  FUNCTION  =============================================================
#          NAME:  returnRandomCharacters
#   DESCRIPTION:  Returns a random string of alphanumeric characters
#    PARAMETERS:  Length of string, include special characters
#       RETURNS:  0 regardless of result.
#==============================================================================
function returnRandomCharacters()
{
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    local cname="misc.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local return_code=0;
    local error_count=0;
    local ret_code=0;
    local string_count=1;
    local counter=0;
    local argument;
    local argument_name;
    local argument_value;
    local string_length;
    local use_special;
    local returned_characters;
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

    #======  FUNCTION  ============================================================;
    #          NAME:  usage
    #   DESCRIPTION:
    #    PARAMETERS:  None
    #       RETURNS:  3
    #==============================================================================
    function usage()
    (
        if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
        if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

        local cname="F02-misc";
        local function_name="${cname}#${FUNCNAME[1]}";
        local return_code=3;

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        fi

        printf "%s %s\n" "${FUNCNAME[1]}" "Return a string of random characters" >&2;
        printf "%s %s\n" "Usage: ${FUNCNAME[1]}" "[ options ]" >&2;
        printf "    %s: %s\n" "--count=value| -c <value>" "The number of strings to generate." >&2;
        printf "    %s: %s\n" "--length=value| -l <value>" "Determines the length of the string to generate." >&2;
        printf "    %s: %s\n" "--special | -s" "Include special characters. If not specified, special characters are not utilized." >&2;

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
        fi

        [[ -n "${function_name}" ]] && unset -v function_name;
        [[ -n "${cname}" ]] && unset -v cname;

        if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
        if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

        return "${return_code}";
    )

    if (( ${#} == 0 )) then usage; return "${?}"; fi

    while (( ${#} > 0 )) do
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided Argument -> ${1}";
        fi

        argument="${1}";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "argument -> ${argument}";
        fi

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

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "argument_name -> ${argument_name}";
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "argument_value -> ${argument_value}";
        fi

        case "${argument_name}" in
            count|c)
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Setting string_count...";
                fi

                string_count="${argument_value}";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "string_count -> ${string_count}";
                fi
                ;;
            length|l)
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Setting string_length...";
                fi

                string_length="${argument_value}";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "string_length -> ${string_length}";
                fi
                ;;
            special|s)
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Setting use_special...";
                fi

                use_special="${_TRUE}";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "use_special -> ${use_special}";
                fi
                ;;
            help|\?|h)
                [[ -n "${function_name}" ]] && unset -v function_name;
                [[ -n "${ret_code}" ]] && unset -v ret_code;

                usage;
                return_code="${?}";

                function_name="${cname}#${FUNCNAME[0]}";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "usage -> ret_code -> ${ret_code}";
                fi

                if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
                if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi
                ;;
            *)
                if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An invalid option has been provided and has been ignored. Option -> ${argument_name}, Value -> ${argument_value}";
                    writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An invalid option has been provided and has been ignored. Option -> ${argument_name}, Value -> ${argument_value}";
                fi
                ;;
        esac
    done

    while (( counter <= string_count )) do
        if [[ -n "${use_special}" ]] && [[ "${use_special}" == "${_TRUE}" ]]; then
            returned_characters="$(tr -cd '[:graph:]' < /dev/urandom | head -c "${string_length}")";
        else
            returned_characters="$(tr -cd '[:alnum:]' < /dev/urandom | head -c "${string_length}")";
        fi
    done

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "returned_characters -> ${returned_characters}";
    fi

    if [[ -n "${returned_characters}" ]] && (( return_code != 0 )) then printf "%s\n" "${returned_characters}"; fi

    if [[ -n "${return_code}" ]] && (( return_code != 0 )) then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )) then return_code="${error_count}"; fi

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

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")";
        runtime=$(( end_epoch - start_epoch ))

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

#=====  FUNCTION  =============================================================
#          NAME:  shredit
#   DESCRIPTION:  Destroys a target filesystem by overwriting the data
#    PARAMETERS:  File
#       RETURNS:  0 if success, 1 otherwise
#==============================================================================
function shredit()
{
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    local cname="misc.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local return_code=0;
    local error_count=0;
    local ret_code=0;
    local shred_file;
    local cmd_output;
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

    #======  FUNCTION  ============================================================
    #          NAME:  usage
    #   DESCRIPTION:
    #    PARAMETERS:  None
    #       RETURNS:  3
    #==============================================================================
    function usage()
    (
        if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
        if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

        local cname="misc.sh";
        local function_name="${cname}#${FUNCNAME[1]}";
        local return_code=3;

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        fi

        printf "%s %s\n" "${FUNCNAME[1]}" "Permanently destroys a provided file/filesystem." >&2;
        printf "%s %s\n" "Usage: ${FUNCNAME[1]}" "[ file/filesystem ]" >&2;
        printf "    %s: %s\n" "<file/filesystem>" "The file/filesystem to shred." >&2;

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
        fi

        [[ -n "${function_name}" ]] && unset -v function_name;
        [[ -n "${cname}" ]] && unset -v cname;

        if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
        if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

        return "${return_code}";
    )

    if (( ${#} == 0 )) then usage; return "${?}"; fi

    shred_file="${1}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "shred_file -> ${shred_file}";
    fi

    if [[ ! -w "${shred_file}" ]];
    then
        return_code=1;

        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Requested file ${shred_file} cannot be written to or does not exist.";
        fi
    else
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: cryptsetup -d /dev/urandom -c aes-xts-plain create delete ${shred_file}";
        fi

        [[ -n "${cmd_output}" ]] && unset -v cmd_output;
        [[ -n "${ret_code}" ]] && unset -v ret_code;

        cmd_output="$(cryptsetup -d /dev/urandom -c aes-xts-plain create delete ${shred_file})"; ## TODO: make this a property;
        ret_code="${?}";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cmd_output -> ${cmd_output}";
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cryptsetup -> ret_code -> ${ret_code}";
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: shred -vzn 0 /dev/mapper/delete";
        fi

        [[ -n "${cmd_output}" ]] && unset -v cmd_output;
        [[ -n "${ret_code}" ]] && unset -v ret_code;

        cmd_output="$(shred -vz /dev/mapper/delete)";
        ret_code="${?}";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cmd_output -> ${cmd_output}";
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "shred -> ret_code -> ${ret_code}";
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: sync && sleep ${THREAD_TIMEOUT:-10}";
        fi

        sync && sleep "${THREAD_TIMEOUT:-10}";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: cryptsetup remove delete";
        fi

        [[ -n "${cmd_output}" ]] && unset -v cmd_output;
        [[ -n "${ret_code}" ]] && unset -v ret_code;

        cmd_output="$(cryptsetup remove delete)";
        ret_code="${?}";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cmd_output -> ${cmd_output}";
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cryptsetup -> ret_code -> ${ret_code}";
        fi
    fi

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${shred_file}" ]] && unset -v shred_file;
    [[ -n "${cmd_output}" ]] && unset -v cmd_output;

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")";
        runtime=$(( end_epoch - start_epoch ))

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
