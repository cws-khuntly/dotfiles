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
FUNCTION_NAME="${CNAME}#configrc";

if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
    START_EPOCH="$(date +"%s")";

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "${FUNCTION_NAME} START: $(date -d @"${START_EPOCH}" +"${TIMESTAMP_OPTS}")";
    fi
fi

if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

OSNAME="$(grep -E "(^ID=)" /etc/os-release | cut -d "=" -f 2)";

if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "OSNAME -> ${OSNAME}";
fi

if [[ -f "${USER_CONFIG_PATH}/system/${OSNAME}.settings" ]] && [[ -r "${USER_CONFIG_PATH}/system/${OSNAME}.settings" ]] && \
    [[ -s "${USER_CONFIG_PATH}/system/${OSNAME}.settings" ]]; then

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "EXEC: source ${USER_CONFIG_PATH}/system/${OSNAME}.settings";
    fi

    source "${USER_CONFIG_PATH}/system/${OSNAME}.settings";
fi

## load libs
USER_CONFIG_PATHS=( "${USER_CONFIG_PATH}/system" "${USER_CONFIG_PATH}/programs" "${USER_CONFIG_PATH}/profile" "${USER_CONFIG_PATH}/dotfiles" );

if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "USER_CONFIG_PATH -> ${USER_CONFIG_PATH}";
    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "USER_CONFIG_PATHS -> ${USER_CONFIG_PATHS[*]}";
fi

for CONFIG_PATH in "${USER_CONFIG_PATHS[@]}"; do
    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "CONFIG_PATH -> ${CONFIG_PATH}";
    fi

    mapfile -t FILE_LIST < <(find "${LIB_PATH}" -type f -name \*.settings 2>/dev/null);

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "FILE_LIST -> ${FILE_LIST[*]}";
    fi

    if [[ -z "${FILE_LIST[*]}" ]] || (( ${#FILE_LIST[*]} == 0 )); then continue; fi

    for FILE in "${FILE_LIST[@]}"; do
        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "FILE -> ${FILE}";
        fi

        [[ -z "${FILE}" ]] && continue;

        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "EXEC: source ${CONFIG_PATH}/${FILE}";
        fi

        # shellcheck source=/dev/null
        source "${FILE}";

        [[ -n "${FILE}" ]] && unset -v FILE;
    done

    [[ -n "${CONFIG_PATH}" ]] && unset -v CONFIG_PATH;
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
[[ -n "${USER_CONFIG_PATHS[*]}" ]] && unset -v USER_CONFIG_PATHS;

[[ -n "${FUNCTION_NAME}" ]] && unset -v FUNCTION_NAME;
[[ -n "${CNAME}" ]] && unset -v CNAME;
[[ -n "${START_EPOCH}" ]] && unset -v START_EPOCH;
[[ -n "${END_EPOCH}" ]] && unset -v END_EPOCH;
[[ -n "${RUNTIME}" ]] && unset -v RUNTIME;
