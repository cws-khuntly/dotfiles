#!/usr/bin/env bash

#==============================================================================
#          FILE:  rotatefiles.sh
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
#          NAME:  rotateFiles
#   DESCRIPTION:  Reads a provided property file into the shell
#    PARAMETERS:  File
#       RETURNS:  0 if success, 1 otherwise
#==============================================================================
function rotateFiles()
(
    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set -v; fi

    local cname="rotatefiles.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i ret_code=0;
    local -i return_code=0;
    local -i error_count=0;
    local operating_mode;
    local source_directory;
    local source_file_pattern;
    local remote_directory;
    local remote_file_name;
    local -i max_age;
    local -i start_epoch;
    local -i start_epoch;
    local -i runtime;

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

    (( ${#} < 1 )) && return 3;

    operating_mode="${1}";

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "operating_mode -> ${operating_mode}";
    fi

    case "${operating_mode}" in
        "${ROTATION_TYPE_LOCAL}")
            (( ${#} != 6 )) && return 3;

            source_directory="${2}";
            source_file_pattern="${3}";
            remote_directory="${4}";
            remote_file_name="${5}";
            max_age="${6}";

            if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "source_directory -> ${source_directory}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "source_file_pattern -> ${source_file_pattern}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "remote_directory -> ${remote_directory}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "remote_file_name -> ${remote_file_name}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "max_age -> ${max_age}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: rotateLocalFiles ${source_directory} ${source_file_pattern} ${remote_directory} ${remote_file_name} ${max_age}";
            fi

            [[ -n "${cname}" ]] && builtin unset -v cname;
            [[ -n "${function_name}" ]] && builtin unset -v function_name;
            [[ -n "${ret_code}" ]] && builtin unset -v ret_code;

            rotateLocalFiles "${source_directory}" "${source_file_pattern}" "${remote_directory}" "${remote_file_name}" "${max_age}";
            ret_code="${?}";

            cname="rotatefiles.sh";
            function_name="${cname}#${FUNCNAME[0]}";

            if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "rotateLocalFiles -> ret_code -> ${ret_code}";
            fi

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

                if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred during local cleanup. Please review logs.";
                fi
            else
                if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "Local file cleanup completed successfully.";
                fi
            fi
            ;;
        "${ROTATION_TYPE_REMOTE}")
            (( ${#} != 4 )) && return 3;

            source_directory="${2}";
            source_file_pattern="${3}";
            max_age="${4}";

            if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "source_directory -> ${source_directory}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "source_file_pattern -> ${source_file_pattern}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "max_age -> ${max_age}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: rotateRemoteFiles ${source_directory} ${source_file_pattern} ${max_age}";
            fi

            [[ -n "${cname}" ]] && builtin unset -v cname;
            [[ -n "${function_name}" ]] && builtin unset -v function_name;
            [[ -n "${ret_code}" ]] && builtin unset -v ret_code;

            rotateRemoteFiles "${source_directory}" "${source_file_pattern}" "${max_age}"
            ret_code="${?}";

            cname="rotatefiles.sh";
            function_name="${cname}#${FUNCNAME[0]}";

            if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "rotateRemoteFiles -> ret_code -> ${ret_code}";
            fi

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

                if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Remote cleanup of package files failed. Please review logs.";
                fi
            fi
            ;;
        *)
            return_code=1;

            if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An invalid operation mode was specified. operating_mode -> ${operating_mode}. Cannot continue.";
            fi
            ;;
    esac

    if [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${ret_code}" ]] && builtin unset -v ret_code;
    [[ -n "${error_count}" ]] && builtin unset -v error_count;
    [[ -n "${operating_mode}" ]] && builtin unset -v operating_mode;

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( end_epoch - start_epoch ));

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    [[ -n "${start_epoch}" ]] && builtin unset -v start_epoch;
    [[ -n "${end_epoch}" ]] && builtin unset -v end_epoch;
    [[ -n "${runtime}" ]] && builtin unset -v runtime;
    [[ -n "${function_name}" ]] && builtin unset -v function_name;
    [[ -n "${cname}" ]] && builtin unset -v cname;

    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set +v; fi

    return "${return_code}";
)

#=====  FUNCTION  =============================================================
#          NAME:  rotateLocalFiles
#   DESCRIPTION:  Reads a provided property file into the shell
#    PARAMETERS:  File
#       RETURNS:  0 if success, 1 otherwise
#==============================================================================
function rotateLocalFiles()
(
    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set -v; fi

    local cname="rotatefiles.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i return_code=0;
    local -i error_count=0;
    local -i ret_code=0;
    local temp_tar_file;
    local source_directory;
    local source_file_pattern;
    local remote_directory;
    local remote_file_name;
    local -i max_age;
    local file_list;
    local file;
    local cmd_output;
    local local_cksum;
    local remote_cksum;
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

    source_directory="${1}";
    source_file_pattern="${2}";
    remote_directory="${3}";
    remote_file_name="${4}";
    max_age="${5}";

    if [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "source_directory -> ${source_directory}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "source_file_pattern -> ${source_file_pattern}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "remote_directory -> ${remote_directory}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "remote_file_name -> ${remote_file_name}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "max_age -> ${max_age}";
    fi

    file_list=( "$(find "${source_directory}" -type f -name "${source_file_pattern}" -mtime +"${max_age}")" );

    if [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "file_list -> ${file_list[*]}";
    fi

    if [[ -z "${file_list[*]}" ]] || (( ${#file_list[*]} == 0 )); then
        [[ -z "${ret_code}" ]] && return_code=1 || [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

        if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "No files were found to rotate. Cannot continue.";
        fi
    else
        # make an empty tar
        temp_tar_file="$(mktemp --tmpdir="${USABLE_TMP_DIR:-${TMPDIR}}")";

        if [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "temp_tar_file -> ${temp_tar_file}";
        fi

        if [[ -z "${temp_tar_file}" ]]; then
            [[ -z "${ret_code}" ]] && return_code=1 || [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

            if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to generate temporary file for archive.";
            fi
        else
            if [[ ! -f "${temp_tar_file}" ]] || [[ ! -w "${temp_tar_file}" ]]; then
                [[ -z "${ret_code}" ]] && return_code=1 || [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

                if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to generate temporary file for archive.";
                fi
            else
                if [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Preload the archive...";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: tar cf ${temp_tar_file} --files-from=/dev/null";
                fi

                [[ -n "${cmd_output}" ]] && unset -v cmd_output;
                [[ -n "${ret_code}" ]] && unset -v ret_code;

                cmd_output="$(tar cf "${temp_tar_file}" --files-from=/dev/null)";
                ret_code="${?}";

                if [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cmd_output -> ${cmd_output}";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
                fi

                if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                    [[ -z "${ret_code}" ]] && return_code=1 || [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

                    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred while creating the pre-loaded archive. Please review logs.";
                    fi
                else
                    if [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: ( cd ${source_directory}; for file in ${file_list[*]}; do tar uf ./${file} ${temp_tar_file}; done ); gzip ${temp_tar_file}";
                    fi

                    (
                        cd "${source_directory}" || return 1;

                        for file in "${file_list[@]}"; do
                            # shellcheck disable=SC2030
                            # shellcheck disable=SC2001
                            filename="$(sed -e "s^${source_directory}/^^g" <<< "${file}")"; local filename;

                            tar uf ./"${filename}" "${temp_tar_file}";

                            [[ -n "${filename}" ]] && unset -v filename;
                            [[ -n "${file}" ]] && unset -v file;
                        done
                    ); gzip "${temp_tar_file}";

                    if [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Archive complete. Verifying...";
                    fi

                    for file in "${file_list[@]}"; do
                        if [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "file -> ${file}";
                        fi

                        [[ -n "${ret_code}" ]] && unset -v ret_code;

                        # shellcheck disable=SC2312
                        tar tf "${temp_tar_file}" | grep -w "${file}";
                        ret_code="${?}";

                        if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                            (( error_count += 1 ));

                            if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "File ${file} was not found in archive file ${temp_tar_file}. Not removing source file.";
                            fi
                        else
                            if [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "File ${file} was found in archive file ${temp_tar_file}. Removing source file.";
                                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: rm -f ${file}";
                            fi

                            [[ -n "${cmd_output}" ]] && unset -v cmd_output;
                            [[ -n "${ret_code}" ]] && unset -v ret_code;

                            cmd_output="$(rm -f "${file}")";
                            ret_code="${?}";

                            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                                (( error_count += 1 ));

                                if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to remove source file ${file}. Please review logs.";
                                fi
                            fi
                        fi

                        [[ -n "${file}" ]] && unset -v file;
                    done

                    if [[ -n "${error_count}" ]] && (( error_count != 0 )) && [[ -n "${ret_code}" ]] && (( ret_code != 0 )); then
                        [[ -z "${ret_code}" ]] && return_code=1 || [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

                        if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "One or more failures occurred during the rotation process. Cannot continue.";
                        fi
                    else
                        if [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: sha512sum ${temp_tar_file} | awk '{print $1}'";
                        fi

                        # no errors, checksum and move
                        local_cksum="$(sha512sum "${temp_tar_file}" | awk '{print $1}')";

                        if [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "local_cksum -> ${local_cksum}";
                            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: cp ${temp_tar_file} ${remote_directory}/${remote_file_name}";
                        fi

                        cp -p "${temp_tar_file}" "${remote_directory}/${remote_file_name}";
                        ret_code="${?}";

                        if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                            [[ -z "${ret_code}" ]] && return_code=1 || [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

                            if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to copy source archive ${temp_tar_file} to target ${remote_directory}/${remote_file_name}";
                            fi
                        else
                            if [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: sha512sum ${temp_tar_file} | awk '{print $1}'";
                            fi

                            # no errors, checksum and move
                            remote_cksum="$(sha512sum "${remote_directory}/${remote_file_name}" | awk '{print $1}')";

                            if [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "remote_cksum -> ${remote_cksum}";
                            fi

                            if [[ "${local_cksum}" != "${remote_cksum}" ]]; then
                                return_code=1;

                                if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Local checksum (${local_cksum}) does not match remote checksum (${remote_cksum}). Considering file copy a failure.";
                                fi
                            fi
                        fi
                    fi
                fi
            fi
        fi
    fi

    if [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -f "${temp_tar_file}" ]] && rm -f "${temp_tar_file}";

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${source_directory}" ]] && unset -v source_directory;
    [[ -n "${source_file_pattern}" ]] && unset -v source_file_pattern;
    [[ -n "${remote_directory}" ]] && unset -v remote_directory;
    [[ -n "${remote_file_name}" ]] && unset -v remote_file_name;
    [[ -n "${max_age}" ]] && unset -v max_age;
    [[ -n "${temp_tar_file}" ]] && unset -v temp_tar_file;
    [[ -n "${cmd_output}" ]] && unset -v cmd_output;
    [[ -n "${filename}" ]] && unset -v filename;
    [[ -n "${file}" ]] && unset -v file;
    [[ -n "${local_cksum}" ]] && unset -v local_cksum;
    [[ -n "${remote_cksum}" ]] && unset -v remote_cksum;
    [[ -n "${file_list[*]}" ]] && unset -v file_list;

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

    [[ -n "${start_epoch}" ]] && unset -v start_epoch;
    [[ -n "${end_epoch}" ]] && unset -v end_epoch;
    [[ -n "${runtime}" ]] && unset -v runtime;
    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${cname}" ]] && unset -v cname;

    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set +v; fi

    return "${return_code}";
)

#=====  FUNCTION  =============================================================
#          NAME:  rotateRemoteFiles
#   DESCRIPTION:  Reads a provided property file into the shell
#    PARAMETERS:  File
#       RETURNS:  0 if success, 1 otherwise
#==============================================================================
function rotateRemoteFiles()
(
    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set -v; fi

    local cname="rotatefiles.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i return_code=0;
    local -i error_count=0;
    local -i ret_code=0;
    local source_directory;
    local source_file_pattern;
    local -i max_age;
    local file_list;
    local file;
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

    source_directory="${1}";
    source_file_pattern="${2}";
    max_age="${3}";

    if [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "source_directory -> ${source_directory}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "source_file_pattern -> ${source_file_pattern}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "max_age -> ${max_age}";
    fi

    file_list=( "$(find "${source_directory}" -type f -name "${source_file_pattern}" -mtime +"${max_age}")" );

    if [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "file_list -> ${file_list[*]}";
    fi

    if [[ -z "${file_list[*]}" ]] || (( ${#file_list[*]} == 0 )); then
        [[ -z "${ret_code}" ]] && return_code=1 || [[ -z "${ret_code}" ]] && return_code=1 || return_code="${ret_code}";

        if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "No files were found to rotate. Cannot continue.";
        fi
    else
        for file in "${file_list[@]}"; do
            if [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "file -> ${file}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: rm -f ${file}";
            fi

            [[ -n "${ret_code}" ]] && unset -v ret_code;

            rm -f "${file}";
            ret_code="${?}";

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                (( error_count += 1 ));

                if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to remove archive file ${file}";
                fi
            fi

            [[ -n "${file}" ]] && unset -v file;
        done
    fi

    if [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${source_directory}" ]] && unset -v source_directory;
    [[ -n "${source_file_pattern}" ]] && unset -v source_file_pattern;
    [[ -n "${max_age}" ]] && unset -v max_age;
    [[ -n "${file}" ]] && unset -v file;
    [[ -n "${file_list[*]}" ]] && unset -v file_list;

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

    [[ -n "${start_epoch}" ]] && unset -v start_epoch;
    [[ -n "${end_epoch}" ]] && unset -v end_epoch;
    [[ -n "${runtime}" ]] && unset -v runtime;
    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${cname}" ]] && unset -v cname;

    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set +v; fi

    return "${return_code}";
)
