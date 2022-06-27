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

[[ "$-" != *i* ]] || [ -z "${PS1}" ] && return;

[ -f "${HOME}/.etc/logging.properties" ] && . "${HOME}/.etc/logging.properties";
[ -f "${HOME}/.lib/logger.sh" ] && . "${HOME}/.lib/logger.sh";

typeset SCRIPT_NAME="profile";

[ ! -z "${ENABLE_PERFORMANCE}" -a "${ENABLE_PERFORMANCE}" = "${_TRUE}" ] && writeLogEntry "PERFORMANCE" "${SCRIPT_NAME}" "${LINENO}" "LOGIN" "${METHOD_NAME} START: $(/usr/bin/env date +"${TIMESTAMP_OPTS}")";
[ ! -z "${ENABLE_PERFORMANCE}" -a "${ENABLE_PERFORMANCE}" = "${_TRUE}" ] && typeset -i START_EPOCH=$(/usr/bin/env date +"%s");

[ ! -z "${ENABLE_VERBOSE}" -a "${ENABLE_VERBOSE}" = "${_TRUE}" ] && set -x || set +x;
[ ! -z "${ENABLE_TRACE}" -a "${ENABLE_TRACE}" = "${_TRUE}" ] && set -v || set +v;

typeset -x PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin";

## load profile
for PROFILE in ${HOME}/.profile.d/*
do
    [ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${SCRIPT_NAME}" "${LINENO}" "LOGIN" "PROFILE -> ${PROFILE}";

    [ -z "${PROFILE}" ] && continue;
    [ -d "${PROFILE}" ] && continue;

    [ ! -z "${ENABLE_TRACE}" -a "${ENABLE_TRACE}" = "${_TRUE}" ] && . ${PROFILE} 2>&1 | tee -a ${LOG_ROOT}/$(basename ${PROFILE}).${DATE_PATTERN}.log || . ${PROFILE};

    [ ! -z "${PROFILE}" ] && unset -v PROFILE;
done

[ ! -z "${PROFILE}" ] && unset -v PROFILE;

if [ -d ${HOME}/.profile.d/profiles/ ]
then
    for PROFILE in ${HOME}/.profile.d/profiles/*
    do
        [ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${SCRIPT_NAME}" "${LINENO}" "LOGIN" "PROFILE -> ${PROFILE}";

        [ -z "${PROFILE}" ] && continue;

        [ ! -z "${ENABLE_TRACE}" -a "${ENABLE_TRACE}" = "${_TRUE}" ] && . ${PROFILE} 2>&1 | tee -a ${LOG_ROOT}/$(basename ${PROFILE}).${DATE_PATTERN}.log || . ${PROFILE};

        [ ! -z "${PROFILE}" ] && unset -v PROFILE;
        [ ! -z "${IS_VALID_PROFILE}" ] && unset -v IS_VALID_PROFILE;
    done
fi

[ ! -z "${PROFILE}" ] && unset -v PROFILE;

[ ! -z "${ENABLE_TRACE}" -a "${ENABLE_TRACE}" = "${_TRUE}" ] && . ${HOME}/.alias 2>&1 | tee -a ${LOG_ROOT}/load-aliases.${DATE_PATTERN}.log || . ${HOME}/.alias;
[ ! -z "${ENABLE_TRACE}" -a "${ENABLE_TRACE}" = "${_TRUE}" ] && . ${HOME}/.functions 2>&1 | tee -a ${LOG_ROOT}/load-functions.${DATE_PATTERN}.log || . ${HOME}/.functions;

[ ! -f /etc/profile.d/cws.sh ] && showHostInfo;

## trap logout
trap 'source ~/.dotfiles/functions.d/F01-userProfile; logoutUser; exit' 0;

[ ! -z "$(/usr/bin/env which screen 2>/dev/null)" -a -z "${STY}" -a -f ${HOME}/.config/runscreen ] && /usr/bin/env screen -q;

[ ! -z "${ENABLE_VERBOSE}" -a "${ENABLE_VERBOSE}" = "${_TRUE}" ] && set -x || set +x;
[ ! -z "${ENABLE_TRACE}" -a "${ENABLE_TRACE}" = "${_TRUE}" ] && set -v || set +v;

[ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${SCRIPT_NAME}" "${LINENO}" "LOGIN" "${METHOD_NAME} -> exit";

[ ! -z "${SCRIPT_NAME}" ] && unset -v SCRIPT_NAME;
[ ! -z "LOGIN" ] && unset -v FUNCTION_NAME;

[ ! -z "${ENABLE_PERFORMANCE}" -a "${ENABLE_PERFORMANCE}" = "${_TRUE}" ] && typeset -i END_EPOCH=$(date +"%s");
[ ! -z "${ENABLE_PERFORMANCE}" -a "${ENABLE_PERFORMANCE}" = "${_TRUE}" ] && typeset -i RUNTIME=$(( ${START_EPOCH} - ${END_EPOCH} ));
[ ! -z "${ENABLE_PERFORMANCE}" -a "${ENABLE_PERFORMANCE}" = "${_TRUE}" ] && writeLogEntry "PERFORMANCE" "${SCRIPT_NAME}" "${LINENO}" "LOGIN" "${METHOD_NAME} TOTAL RUNTIME: $((${RUNTIME} / 60)) MINUTES, TOTAL ELAPSED: $((${RUNTIME} % 60)) SECONDS";
[ ! -z "${ENABLE_PERFORMANCE}" -a "${ENABLE_PERFORMANCE}" = "${_TRUE}" ] && writeLogEntry "PERFORMANCE" "${SCRIPT_NAME}" "${LINENO}" "LOGIN" "${METHOD_NAME} END: $(date +"${TIMESTAMP_OPTS}")";
