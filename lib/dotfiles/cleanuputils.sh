#!/usr/bin/env bash

#=====  FUNCTION  =============================================================
#          NAME:  cleanupFiles
#   DESCRIPTION:  Cleans up after a deployment/installation
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function cleanupFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    cname="cleanuputils.sh";
    function_name="${cname}#${FUNCNAME[0]}";
    return_code=0;
    error_count=0;

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi


    (( ${#} < 2 )) && return 3;

    if [[ "${target_host}" == "localhost" ]] || [[ "${target_host}" == "localhost.localdomain" ]] || [[ "${target_host}" == "127.0.0.1" ]] || \
        [[ "${target_host}" == "$(hostname -s)" ]] || [[ "${target_host}" == "$(hostname -f)" ]]; then
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Target host is localhost or $(hostname -s) / $(hostname -f). Performing local cleanup.";
        fi

        operating_mode="${1}";
        cleanup_file_list="${2}";
    else
        (( ${#} != 6 )) && return 3;

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Target host is remote: ${target_host}. Performing remote cleanup.";
        fi

        operating_mode="${1}";
        cleanup_file_list="${2}";
        target_host="${3}";
        target_port="${4}";
        target_user="${5}";
        force_exec="${6}";
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "operating_mode -> ${operating_mode}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cleanup_file_list -> ${cleanup_file_list}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_host -> ${target_host}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_port -> ${target_port}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_user -> ${target_user}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "force_exec -> ${force_exec}";
    fi

    if [[ -n "${cleanup_file_list}" ]]; then
        case "${operating_mode}" in
            "${CLEANUP_LOCATION_LOCAL}")
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: cleanupLocalFiles ${cleanup_file_list}";
                fi

                [[ -n "${cname}" ]] && unset -v cname;
                [[ -n "${function_name}" ]] && unset -v function_name;
                [[ -n "${ret_code}" ]] && unset -v ret_code;

                cleanupLocalFiles "${cleanup_file_list}";
                ret_code="${?}";

                cname="cleanuputils.sh";
                function_name="${cname}#${FUNCNAME[0]}";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
                fi

                if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                    return_code="${ret_code}"

                    if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred during local cleanup. Please review logs.";
                    fi
                else
                    if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "Local file cleanup completed successfully.";
                    fi
                fi
                ;;
            "${CLEANUP_LOCATION_REMOTE}")
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: cleanupRemoteFiles ${cleanup_file_list} ${target_host} ${target_port} ${target_user}";
                fi

                [[ -n "${cname}" ]] && unset -v cname;
                [[ -n "${function_name}" ]] && unset -v function_name;
                [[ -n "${ret_code}" ]] && unset -v ret_code;

                cleanupRemoteFiles "${cleanup_file_list}" "${target_host}" "${target_port}" "${target_user}"
                ret_code="${?}";

                cname="cleanuputils.sh";
                function_name="${cname}#${FUNCNAME[0]}";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
                fi

                if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                    return_code="${ret_code}";

                    if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Remote cleanup of package files failed. Please review logs.";
                    fi
                fi
                ;;
            *)
                return_code=1;

                if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An invalid operation mode was specified. operating_mode -> ${operating_mode}. Cannot continue.";
                fi
                ;;
        esac
    else
        return_code=1;

        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "The list of files to operate against appears to be empty. Cannot continue.";
        fi
    fi

    [[ -n "${target_user}" ]] && unset -v target_user;
    [[ -n "${target_host}" ]] && unset -v target_host;
    [[ -n "${target_port}" ]] && unset -v target_port;
    [[ -n "${force_exec}" ]] && unset -v force_exec;
    [[ -n "${cleanup_file_list}" ]] && unset -v cleanup_file_list;
    [[ -n "${operating_mode}" ]] && unset -v operating_mode;

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( end_epoch - start_epoch ));

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${function_name}" ]] && unset -v function_name;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return ${return_code};
)

#=====  FUNCTION  =============================================================
#          NAME:  cleanupLocalFiles
#   DESCRIPTION:  Cleans up locally after a deployment/installation
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function cleanupLocalFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    cname="cleanuputils.sh";
    function_name="${cname}#${FUNCNAME[0]}";
    return_code=0;
    error_count=0;

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

    (( ${#} != 1 )) && return 3;

    requested_files="${1}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "requested_files -> ${requested_files[*]}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: mapfile -d \",\" -t files_to_process < <(printf \"%s\" \"${requested_files}\")";
    fi

    mapfile -d "," -t files_to_process < <(printf "%s" "${requested_files}");

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "files_to_process -> ${files_to_process[*]}"; fi

    for eligibleFile in "${files_to_process[@]}"; do
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "eligibleFile -> ${eligibleFile}";
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Check if file ${eligibleFile} exists and removing if necessary";
        fi

        [[ -z "${eligibleFile}" ]] && continue;

        targetFile="$(cut -d "|" <<< "${eligibleFile}" -f 1)";
        targetDir="$(cut -d "|" <<< "${eligibleFile}" -f 2)";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "targetFile -> ${targetFile}";
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "targetDir -> ${targetDir}";
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Check if file ${targetDir}/${targetFile} exists and removing if necessary";
        fi

        if [[ -n "${targetFile}" ]] && [[ -n "${targetDir}" ]]; then
            if [[ -d "${targetDir}/${targetFile}" ]] && [[ -w "${targetDir}/${targetFile}" ]]; then
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Removing directory ${targetDir}/${targetFile}";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: rm -rf ${targetDir}/${targetFile}";
                fi

                [[ -n "${cmd_output}" ]] && unset -v cmd_output;
                [[ -n "${ret_code}" ]] && unset -v ret_code;

                cmd_output=$(rm -rf "${targetDir:?}/${targetFile}");
                ret_code="${?}";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cmd_output -> ${cmd_output}";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
                fi

                if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                    (( error_count += 1 ));

                    if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to remove directory ${targetDir:?}/${targetFile}. Please remove the directory manually.";
                    fi
                else
                    if [[ -e "${targetDir}/${targetFile}" ]] || [[ -w "${targetDir}/${targetFile}" ]]; then
                        (( error_count += 1 ))

                        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to remove file ${targetDir:?}/${targetFile}. Please remove the directory manually.";
                        fi
                    else
                        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "Directory ${targetDir:?}/${targetFile} successfully removed.";
                        fi
                    fi
                fi
            elif [[ -e "${targetDir}/${targetFile}" ]] && [[ -w "${targetDir}/${targetFile}" ]]; then
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Removing file ${targetDir}/${targetFile}";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: rm -f ${targetDir}/${targetFile}";
                fi

                [[ -n "${cmd_output}" ]] && unset -v cmd_output;
                [[ -n "${ret_code}" ]] && unset -v ret_code;

                cmd_output=$(rm -f "${targetDir:?}/${targetFile}");
                ret_code="${?}";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cmd_output -> ${cmd_output}";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
                fi

                if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                    (( error_count += 1 ));

                    if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to remove file ${targetDir:?}/${targetFile}. Please remove the file manually.";
                    fi
                else
                    if [[ -e "${targetDir}/${targetFile}" ]] || [[ -w "${targetDir}/${targetFile}" ]]; then
                        (( error_count += 1 ))

                        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to remove file ${targetDir:?}/${targetFile}. Please remove the file manually.";
                        fi
                    else
                        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "File ${targetDir:?}/${targetFile} successfully removed.";
                        fi
                    fi
                fi
            fi
        else
            if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "targetFile ${targetDir}/${targetFile} was null or empty. Skipping entry.";
            fi

            continue;
        fi

        [[ -n "${eligibleFile}" ]] && unset -v eligibleFile;
        [[ -n "${targetFile}" ]] && unset -v targetFile;
        [[ -n "${ret_code}" ]] && unset -v ret_code;
    done

    [[ -n "${targetFile}" ]] && unset -v targetFile;
    [[ -n "${eligibleFile}" ]] && unset -v eligibleFile;
    [[ -n "${files_to_process[*]}" ]] && unset -v files_to_process;
    [[ -n "${requested_files}" ]] && unset -v requested_files;

    (( error_count != 0 )) && return_code="${error_count}";

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( end_epoch - start_epoch ));

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${function_name}" ]] && unset -v function_name;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return ${return_code};
)

#=====  FUNCTION  =============================================================
#          NAME:  cleanupRemoteFiles
#   DESCRIPTION:  Cleans up a remote system after a deployment/installation
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function cleanupRemoteFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    cname="cleanuputils.sh";
    function_name="${cname}#${FUNCNAME[0]}";
    file_counter=0;
    return_code=0;
    error_count=0;

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

    (( ${#} != 4 )) && return 3;

    requested_files="${1}";
    target_host="${2}";
    target_port="${3}";
    target_user="${4}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "requested_files -> ${requested_files}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_host -> ${target_host}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_port -> ${target_port}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_user -> ${target_user}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Generating file cleanup file...";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: mktemp --tmpdir=${TMPDIR:-${USABLE_TMP_DIR}}";
    fi

    file_cleanup_file="$(mktemp --tmpdir="${TMPDIR:-${USABLE_TMP_DIR}}")";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "file_cleanup_file -> ${file_cleanup_file}"; fi

    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
        return_code="${ret_code}"

        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to generate the file cleanup script ${file_cleanup_file}. Please ensure the file exists and can be written to.";
        fi
    else
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Clearing any existing content in ${file_cleanup_file}";
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: cat /dev/null >| ${file_cleanup_file}";
        fi

        [[ -n "${ret_code}" ]] && unset -v ret_code;

        cat /dev/null >| ${file_cleanup_file};
        ret_code="${?}";

        if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
            return_code="${ret_code}"

            if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to clear any existing content in ${file_cleanup_file}. Please review logs.";
            fi
        else
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Populating file cleanup file ${file_cleanup_file}...";
            fi

            for eligibleFile in "${files_to_process[@]}"; do
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "file_counter -> ${file_counter}";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "eligibleFile -> ${eligibleFile}";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Check if file ${eligibleFile} exists and removing if necessary";
                fi

                [[ -z "${eligibleFile}" ]] && continue;

                targetFile="$(awk -F "|" '{print $1}' <<< "${eligibleFile}")";
                targetDir="$(awk -F "|" '{print $2}' <<< "${eligibleFile}")";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "targetFile -> ${targetFile}";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "targetDir -> ${targetDir}";
                fi

                if [[ -n "${targetDir}" ]] && [[ -n "${targetFile}" ]]; then
                    if (( file_counter == 0 )); then
                        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: printf \"%s %s %s\n\" \"-\" \"rm\" \"${targetDir:?}/${targetFile}\" >| ${file_cleanup_file}";
                        fi

                        { printf "%s %s %s\n" "-" "rm" "${targetDir:?}/${targetFile}"; } >| "${file_cleanup_file}";
                    else
                        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: printf \"%s %s %s\n\" \"-\" \"rm\" \"${targetDir:?}/${targetFile}\" >> ${file_cleanup_file}";
                        fi

                        { printf "%s %s %s\n" "-" "rm" "${targetDir:?}/${targetFile}"; } >> "${file_cleanup_file}";
                    fi
                else
                    if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "targetFile ${targetDir}/${targetFile} was null or empty. Skipping entry.";
                    fi

                    continue;
                fi

                (( file_counter += 1 ));

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "file_counter -> ${file_counter}";
                fi

                [[ -n "${eligibleFile}" ]] && unset -v eligibleFile;
                [[ -n "${targetFile}" ]] && unset -v targetFile;
                [[ -n "${targetDir}" ]] && unset -v targetDir;
            done

            if [[ ! -s "${file_cleanup_file}" ]]; then
                return_code="${ret_code}"

                if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to populate the file cleanup file ${file_cleanup_file}. Please ensure the file exists and can be written to.";
                fi
            else
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: sftp -b ${file_cleanup_file} -oPort=${target_port} ${target_user}@${target_host} > /dev/null 2>&1"; fi

                [[ -n "${ret_code}" ]] && unset -v ret_code;

                sftp -b "${file_cleanup_file}" -oPort="${target_port}" "${target_user}@${target_host}" > /dev/null 2>&1;
                ret_code="${?}";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}"; fi

                if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                    return_code="${ret_code}"

                    if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred during the file cleanup process on host ${target_host} as user ${target_user}. Please review logs.";
                    fi
                else
                    if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "File ${file_cleanup_file} successfully generated and transferred to ${target_host} as user ${target_user}.";
                    fi
                fi
            fi
        fi
    fi

    [[ -w "${file_cleanup_file}" ]] && rm -f "${file_cleanup_file}";

    [[ -n "${targetFile}" ]] && unset -v targetFile;
    [[ -n "${targetDir}" ]] && unset -v targetDir;
    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${requested_files}" ]] && unset -v requested_files;
    [[ -n "${target_host}" ]] && unset -v target_host;
    [[ -n "${target_port}" ]] && unset -v target_port;
    [[ -n "${target_user}" ]] && unset -v target_user;
    [[ -n "${file_counter}" ]] && unset -v file_counter;
    [[ -n "${eligibleFile}" ]] && unset -v eligibleFile;
    [[ -n "${file_cleanup_file}" ]] && unset -v file_cleanup_file;
    [[ -n "${files_to_process[*]}" ]] && unset -v files_to_process;

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( end_epoch - start_epoch ));

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${function_name}" ]] && unset -v function_name;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return ${return_code};
)
