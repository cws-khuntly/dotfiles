#!/usr/bin/env bash

#==============================================================================
#
#          FILE:  libs
#         USAGE:  . libs
#   DESCRIPTION:  Sets application-wide aliases
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

CNAME="$(basename "${BASH_SOURCE[0]}")";
FUNCTION_NAME="${CNAME}#librc";

if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
    START_EPOCH="$(date +"%s")";

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "${FUNCTION_NAME} START: $(date -d @"${START_EPOCH}" +"${TIMESTAMP_OPTS}")";
    fi
fi

if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

## load libs
USER_LIB_PATHS=( "${USER_LIB_PATH}/system" "${USER_LIB_PATH}/programs" "${USER_LIB_PATH}/profile" "${USER_LIB_PATH}/dotfiles" );

if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "USER_LIB_PATH -> ${USER_LIB_PATH}";
    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "USER_LIB_PATHS -> ${USER_LIB_PATHS[*]}";
fi

for LIB_PATH in "${USER_LIB_PATHS[@]}"; do
    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "LIB_PATH -> ${LIB_PATH}";
    fi

    mapfile -t FILE_LIST < <(find "${LIB_PATH}" -type f -name \*.sh 2>/dev/null);

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "FILE_LIST -> ${FILE_LIST[*]}";
    fi

    if [[ -z "${FILE_LIST[*]}" ]] || (( ${#FILE_LIST[*]} == 0 )); then continue; fi

    for FILE in "${FILE_LIST[@]}"; do
        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "FILE -> ${FILE}";
        fi

        [[ -z "${FILE}" ]] && continue;
        [[ "$(basename "${FILE}")" == "logging.sh" ]] && continue;

        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "EXEC: source ${FILE}";
        fi

        # shellcheck source=/dev/null
        source "${FILE}";

        [[ -n "${FILE}" ]] && unset -v FILE;
    done

    [[ -n "${LIB_PATH}" ]] && unset -v LIB_PATH;
done

if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
    END_EPOCH="$(date +"%s")"
    RUNTIME=$(( END_EPOCH - START_EPOCH ));

    writeLogEntry "FILE" "PERFORMANCE" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "${FUNCTION_NAME} END: $(date -d "@${END_EPOCH}" +"${TIMESTAMP_OPTS}")";
    writeLogEntry "FILE" "PERFORMANCE" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "${FUNCTION_NAME} TOTAL RUNTIME: $(( RUNTIME / 60)) MINUTES, TOTAL ELAPSED: $(( RUNTIME % 60)) SECONDS";
fi

if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

[[ -n "${FILE}" ]] && unset -v FILE;
[[ -n "${FILE_LIST}" ]] && unset -v FILE_LIST;
[[ -n "${CONFIG_PATH}" ]] && unset -v CONFIG_PATH;
[[ -n "${USER_LIB_PATHS[*]}" ]] && unset -v USER_LIB_PATHS;

[[ -n "${FUNCTION_NAME}" ]] && unset -v FUNCTION_NAME;
[[ -n "${CNAME}" ]] && unset -v CNAME;
[[ -n "${START_EPOCH}" ]] && unset -v START_EPOCH;
[[ -n "${END_EPOCH}" ]] && unset -v END_EPOCH;
[[ -n "${RUNTIME}" ]] && unset -v RUNTIME;
