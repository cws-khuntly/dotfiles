#!/usr/bin/env bash

#=====  FUNCTION  =============================================================
#          NAME:  buildPackage
#   DESCRIPTION:  Generates the package for deployment
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function buildPackage()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    cname="buildutils.sh";
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

    if [[ -d "${DOTFILES_BASE_PATH}" ]]; then
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: tar --exclude-vcs --exclude=README.md --exclude=LICENSE.md --exclude=dotfiles.code-workspace --exclude log --exclude logs -C ${DOTFILES_BASE_PATH} -cf - ./*";
        fi

        [[ -n "${ret_code}" ]] && unset -v ret_code;

        ( cd "${DOTFILES_BASE_PATH}"; tar --exclude-vcs --exclude=README.md --exclude=LICENSE.md --exclude=dotfiles.code-workspace -cf - ./*) | ${ARCHIVE_PROGRAM} > "${TMPDIR:-${USABLE_TMP_DIR}}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}";
        ret_code="${?}";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
        fi

        if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
            return_code="${ret_code}"

            if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred while building the package. Please review logs.";
            fi
        else
            if [[ ! -s "${TMPDIR:-${USABLE_TMP_DIR}}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}" ]]; then
                return_code=1;

                if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred while building the package. Please review logs.";
                fi
            else
                if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "Package ${TMPDIR:-${USABLE_TMP_DIR}}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION} created successfully.";
                fi
            fi
        fi
    else
        return_code=1;

        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "The specified source directory ${DOTFILES_BASE_PATH} does not exist. Cannot continue.";
        fi
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( end_epoch - start_epoch ));

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${function_name}" ]] && unset -v function_name;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return ${return_code};
)
