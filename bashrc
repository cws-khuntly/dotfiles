#!/usr/bin/env bash

#==============================================================================
#
#          FILE:  bash_profile
#         USAGE:  . bash_profile
#   DESCRIPTION:  Sets application-wide functions
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

if [[ -n "$(compgen -c | grep -Ew "(^tmux)" | sort | uniq)" ]]; then
    if [[ -z "${TMUX}" ]]; then
        tmux new-session -A -s default && exit;
    else
        [[ -n "${TERM}" ]] && [[ "${TERM}" =~ [Ss][Cc][Rr][Ee][Ee][Nn] ]] || tmux attach -t default && exit;
    fi
fi

CNAME="$(basename "${BASH_SOURCE[0]}")";
FUNCTION_NAME="${CNAME}#bashrc";
# shellcheck source=./.dotfiles/config/system/logging.properties
LOGGING_PROPERTIES="${HOME}/.dotfiles/config/system/logging.properties";

[[ "$-" != *i* ]] || [ -z "${PS1}" ] && return;

if [[ -f "/etc/bashrc" ]] && [[ -r "/etc/bashrc" ]] && [[ -s "/etc/bashrc" ]]; then source "/etc/bashrc"; fi
if [[ -z "${DOT_PROFILE_LOADED}" ]] || [[ "${DOT_PROFILE_LOADED}" =~ [Ff][AA][Ll][Ss][Ee] ]]; then
    if [[ -f "${HOME}/.profile" ]] && [[ -r "${HOME}/.profile" ]] && [[ -s "${HOME}/.profile" ]]; then
        # shellcheck source=./profile
        source "${HOME}/.profile";
    fi
fi

## load the logger
if [[ -r "${HOME}/lib/system/logging.sh" ]] && [[ -s "${HOME}/lib/system/logging.sh" ]]; then
    # shellcheck source=./lib/system/logging.sh
    source "${HOME}/lib/system/logging.sh"; ## if its here, override the above and use it
elif [[ -r "/usr/local/bin/logging.sh" ]] && [[ -s "/usr/local/bin/logging.sh" ]]; then
    source "/usr/local/bin/logging.sh"; ## if its here, use it
else
    printf "\[\e[91m\]%s\n" "Unable to load logger. No logging enabled!" >&2;
fi

if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
    START_EPOCH="$(date +"%s")";

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "${FUNCTION_NAME} START: $(date -d @"${START_EPOCH}" +"${TIMESTAMP_OPTS}")";
    fi
fi

if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

if [[ -d "${HOME}/.dotfiles/bashrc.d" ]]; then
    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "EXEC: mapfile -t FILE_LIST < <\(find ${HOME}/.dotfiles/bashrc.d -type f -name \*.bashrc 2>/dev/null\)";
    fi

    mapfile -t FILE_LIST < <(find "${HOME}/.dotfiles/bashrc.d" -type f -name \*.bashrc 2>/dev/null);

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "FILE_LIST -> ${FILE_LIST[*]}";
    fi

    if [[ -n "${FILE_LIST[*]}" ]] && (( ${#FILE_LIST[*]} >=1 )); then
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
    fi
fi

if [[ -z "${isReloadRequest}" ]] || [[ "${isReloadRequest}" == "${_FALSE}" ]]; then
    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "EXEC: showHostInfo";
    fi

    if [[ ! "$(uname -s)" =~ [Aa][Ii][Xx] ]]; then
        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "EXEC: showHostInfo";
        fi

        showHostInfo;
    fi

    if [[ -f "/etc/motd" ]] && [[ -r "/etc/motd" ]] && [[ -s "/etc/motd" ]]; then
        if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "EXEC: printf \"%s\n\n\" \"Message of the day:\"";
            writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "EXEC: cat /etc/motd";
        fi

        printf "%s\n\n" "Message of the day:";

        cat /etc/motd;
    fi

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "EXEC: runLoginCommands";
    fi

    runLoginCommands;
fi

## trap logout

trap '[[ -n "$(compgen -A function | grep -Ew "(^logoutUser)" | sort | uniq)" ]] && logoutUser; exit' EXIT;

## make the umask sane
umask 022;

if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
    END_EPOCH="$(date +"%s")"
    RUNTIME=$(( END_EPOCH - START_EPOCH ));

    writeLogEntry "FILE" "PERFORMANCE" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "${FUNCTION_NAME} END: $(date -d "@${END_EPOCH}" +"${TIMESTAMP_OPTS}")";
    writeLogEntry "FILE" "PERFORMANCE" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "${FUNCTION_NAME} TOTAL RUNTIME: $(( RUNTIME / 60)) MINUTES, TOTAL ELAPSED: $(( RUNTIME % 60)) SECONDS";
fi

if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

[[ -n "${FILE}" ]] && unset -v FILE;
[[ -n "${SUBDIR}" ]] && unset -v SUBDIR;
[[ -n "${FUNCTION_NAME}" ]] && unset -v FUNCTION_NAME;
[[ -n "${CNAME}" ]] && unset -v CNAME;
[[ -n "${START_EPOCH}" ]] && unset -v START_EPOCH;
[[ -n "${END_EPOCH}" ]] && unset -v END_EPOCH;
[[ -n "${RUNTIME}" ]] && unset -v RUNTIME;
