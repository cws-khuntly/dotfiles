#======  FUNCTION  ============================================================
#          NAME:  rotateArchiveLogs
#   DESCRIPTION:  Rotates log files in archive directory
#    PARAMETERS:  None
#       RETURNS:  0 regardless of result.
#==============================================================================
function rotateArchiveLogs
{
    set +o noclobber;
    typeset SCRIPT_NAME="logging.sh";
    typeset FUNCTION_NAME="${FUNCNAME[0]}";
    typeset -i COUNTER=${LOG_RETENTION_PERIOD};
    typeset -i RETURN_CODE=0;

    [ ! -z "${ENABLE_PERFORMANCE}" -a "${ENABLE_PERFORMANCE}" = "${_TRUE}" ] && writeLogEntry "PERFORMANCE" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "${FUNCTION_NAME} START: $(/usr/bin/env date +"${TIMESTAMP_OPTS}")";
    [ ! -z "${ENABLE_PERFORMANCE}" -a "${ENABLE_PERFORMANCE}" = "${_TRUE}" ] && typeset -i START_EPOCH=$(/usr/bin/env date +"%s");

    [ ! -z "${ENABLE_VERBOSE}" -a "${ENABLE_VERBOSE}" = "${_TRUE}" ] && set -x || set +x;
    [ ! -z "${ENABLE_TRACE}" -a "${ENABLE_TRACE}" = "${_TRUE}" ] && set -v || set +v;

    [ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "${FUNCTION_NAME} -> enter";
    [ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "Provided arguments: ${*}";

    for LOG_FILE in $(/usr/bin/env | /usr/bin/env grep "LOG_FILE" | /usr/bin/env cut -d "=" -f 2)
    do
        [ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "LOG_FILE -> ${LOG_FILE}";

        for ARCHIVE_FILE in $(/usr/bin/env ls -ltr ${ARCHIVE_LOG_ROOT} | /usr/bin/env grep "$(/usr/bin/env cut -d "." -f 1 <<< "${LOG_FILE}")" | /usr/bin/env awk '{print $NF}')
        do
            [ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "ARCHIVE_FILE -> ${ARCHIVE_FILE}";

            typeset -i FILE_COUNT="$(/usr/bin/env awk -F "." '{print $NF}' <<< "${ARCHIVE_FILE}")";
            typeset -i NEW_FILE_COUNT=$(( FILE_COUNT + 1 ));
            typeset BASE_FILE_NAME="$(/usr/bin/env basename $(/usr/bin/env awk 'BEGIN{FS=OFS="."}{$NF=""; NF--; print}' <<< ${ARCHIVE_FILE}))";

            [ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "FILE_COUNT -> ${FILE_COUNT}";
            [ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "NEW_FILE_COUNT -> ${NEW_FILE_COUNT}";
            [ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "BASE_FILE_NAME -> ${BASE_FILE_NAME}";

            case ${FILE_COUNT} in
                ${LOG_RETENTION_PERIOD})
                    ## delete
                    /usr/bin/env rm -f ${ARCHIVE_FILE};

                    [ ! -z "${FILE_COUNT}" ] && unset -v FILE_COUNT;
                    [ ! -z "${NEW_FILE_COUNT}" ] && unset -v NEW_FILE_COUNT;
                    [ ! -z "${BASE_FILE_NAME}" ] && unset -v BASE_FILE_NAME;
                    [ ! -z "${ARCHIVE_FILE}" ] && unset -v ARCHIVE_FILE;

                    continue;
                    ;;
                *)
                    /usr/bin/env cat ${ARCHIVE_FILE} >| ${ARCHIVE_LOG_ROOT}/${BASE_FILE_NAME}.${NEW_FILE_COUNT};
                    ;;
            esac

            [ ! -z "${FILE_COUNT}" ] && unset -v FILE_COUNT;
            [ ! -z "${NEW_FILE_COUNT}" ] && unset -v NEW_FILE_COUNT;
            [ ! -z "${BASE_FILE_NAME}" ] && unset -v BASE_FILE_NAME;
            [ ! -z "${ARCHIVE_FILE}" ] && unset -v ARCHIVE_FILE;
        done

        [ ! -z "${LOG_FILE}" ] && unset -v LOG_FILE;
    done

    [ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "RETURN_CODE -> ${RETURN_CODE}";
    [ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "${FUNCTION_NAME} -> exit";

    [ ! -z "${BASE_FILE_NAME}" ] && unset -v BASE_FILE_NAME;
    [ ! -z "${FILE_COUNT}" ] && unset -v FILE_COUNT;
    [ ! -z "${ARCHIVE_FILE}" ] && unset -v ARCHIVE_FILE;
    [ ! -z "${FUNCNAME}" ] && unset -v FUNCNAME;
    [ ! -z "${COUNTER}" ] && unset -v COUNTER;

    [ ! -z "${ENABLE_PERFORMANCE}" -a "${ENABLE_PERFORMANCE}" = "${_TRUE}" ] && typeset -i END_EPOCH=$(/usr/bin/env date +"%s");
    [ ! -z "${ENABLE_PERFORMANCE}" -a "${ENABLE_PERFORMANCE}" = "${_TRUE}" ] && typeset -i RUNTIME=$(( START_EPOCH - END_EPOCH ));
    [ ! -z "${ENABLE_PERFORMANCE}" -a "${ENABLE_PERFORMANCE}" = "${_TRUE}" ] && writeLogEntry "PERFORMANCE" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "${FUNCTION_NAME} TOTAL RUNTIME: $(( RUNTIME / 60)) MINUTES, TOTAL ELAPSED: $(( RUNTIME % 60)) SECONDS";
    [ ! -z "${ENABLE_PERFORMANCE}" -a "${ENABLE_PERFORMANCE}" = "${_TRUE}" ] && writeLogEntry "PERFORMANCE" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "${FUNCTION_NAME} END: $(/usr/bin/env date +"${TIMESTAMP_OPTS}")";

    [ ! -z "${FUNCTION_NAME}" ] && unset -v FUNCTION_NAME;
    [ ! -z "${SCRIPT_NAME}" ] && unset -v SCRIPT_NAME;

    return ${RETURN_CODE};
}

#======  FUNCTION  ============================================================
#          NAME:  rotateLogs
#   DESCRIPTION:  Rotates log files in logs directory
#    PARAMETERS:  None
#       RETURNS:  0 regardless of result.
#==============================================================================
function rotateLogs
{
    set +o noclobber;
    typeset SCRIPT_NAME="logging.sh";
    typeset FUNCTION_NAME="${FUNCNAME[0]}";
    typeset -i COUNTER=${LOG_RETENTION_PERIOD};
    typeset -i RETURN_CODE=0;

    [ ! -z "${ENABLE_PERFORMANCE}" -a "${ENABLE_PERFORMANCE}" = "${_TRUE}" ] && writeLogEntry "PERFORMANCE" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "${FUNCTION_NAME} START: $(/usr/bin/env date +"${TIMESTAMP_OPTS}")";
    [ ! -z "${ENABLE_PERFORMANCE}" -a "${ENABLE_PERFORMANCE}" = "${_TRUE}" ] && typeset -i START_EPOCH=$(/usr/bin/env date +"%s");

    [ ! -z "${ENABLE_VERBOSE}" -a "${ENABLE_VERBOSE}" = "${_TRUE}" ] && set -x || set +x;
    [ ! -z "${ENABLE_TRACE}" -a "${ENABLE_TRACE}" = "${_TRUE}" ] && set -v || set +v;

    [ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "${FUNCTION_NAME} -> enter";
    [ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "Provided arguments: ${*}";

    ## rotate archive logs first
    rotateArchiveLogs;

    for LOG_FILE in $(/usr/bin/env | /usr/bin/env grep "LOG_FILE" | /usr/bin/env cut -d "=" -f 2)
    do
        [ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "LOG_FILE -> ${LOG_FILE}";

        for FILE in $(/usr/bin/env ls -ltr ${LOG_ROOT} | /usr/bin/env grep "$(/usr/bin/env cut -d "." -f 1 <<< "${LOG_FILE}")" | /usr/bin/env awk '{print $NF}')
        do
            [ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "FILE -> ${FILE}";

            typeset -i FILE_COUNT="$(/usr/bin/env awk -F "." '{print $NF}' <<< "${FILE}")";
            typeset -i NEW_FILE_COUNT=$(( FILE_COUNT + 1 ));
            typeset BASE_FILE_NAME="$(/usr/bin/env basename $(/usr/bin/env awk 'BEGIN{FS=OFS="."}{$NF=""; NF--; print}' <<< ${FILE}))";

            [ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "FILE_COUNT -> ${FILE_COUNT}";
            [ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "NEW_FILE_COUNT -> ${NEW_FILE_COUNT}";
            [ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "BASE_FILE_NAME -> ${BASE_FILE_NAME}";

            case ${FILE_COUNT} in
                ${LOG_RETENTION_PERIOD})
                    ## mv it straight off to arhive dir
                    /usr/bin/env mv ${FILE} ${ARCHIVE_LOG_ROOT}/${BASE_FILE_NAME};

                    [ ! -z "${FILE_COUNT}" ] && unset -v FILE_COUNT;
                    [ ! -z "${NEW_FILE_COUNT}" ] && unset -v NEW_FILE_COUNT;
                    [ ! -z "${BASE_FILE_NAME}" ] && unset -v BASE_FILE_NAME;
                    [ ! -z "${FILE}" ] && unset -v FILE;

                    continue;
                    ;;
                *)
                    /usr/bin/env cat ${FILE} >| ${LOG_ROOT}/${BASE_FILE_NAME}.${NEW_FILE_COUNT};
                    ;;
            esac

            [ ! -z "${FILE_COUNT}" ] && unset -v FILE_COUNT;
            [ ! -z "${NEW_FILE_COUNT}" ] && unset -v NEW_FILE_COUNT;
            [ ! -z "${BASE_FILE_NAME}" ] && unset -v BASE_FILE_NAME;
            [ ! -z "${FILE}" ] && unset -v FILE;
        done


        typeset TOUCH_LOG_FILE="$(/usr/bin/env sed -e "s/.log/.${DATE_PATTERN}.log/" <<< "${LOG_FILE}")";

        [ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "TOUCH_LOG_FILE -> ${TOUCH_LOG_FILE}";

        /usr/bin/env touch ${TOUCH_LOG_FILE};

        [ ! -z "${TOUCH_LOG_FILE}" ] && unset -v TOUCH_LOG_FILE;
        [ ! -z "${LOG_FILE}" ] && unset -v LOG_FILE;
    done

    [ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "RETURN_CODE -> ${RETURN_CODE}";
    [ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "${FUNCTION_NAME} -> exit";

    [ ! -z "${LOG_FILE}" ] && unset -v LOG_FILE;
    [ ! -z "${FILE_COUNT}" ] && unset -v FILE_COUNT;
    [ ! -z "${NEW_FILE_COUNT}" ] && unset -v NEW_FILE_COUNT;
    [ ! -z "${BASE_FILE_NAME}" ] && unset -v BASE_FILE_NAME;
    [ ! -z "${FILE}" ] && unset -v FILE;
    [ ! -z "${COUNTER}" ] && unset -v COUNTER;

    [ ! -z "${ENABLE_PERFORMANCE}" -a "${ENABLE_PERFORMANCE}" = "${_TRUE}" ] && typeset -i END_EPOCH=$(/usr/bin/env date +"%s");
    [ ! -z "${ENABLE_PERFORMANCE}" -a "${ENABLE_PERFORMANCE}" = "${_TRUE}" ] && typeset -i RUNTIME=$(( START_EPOCH - END_EPOCH ));
    [ ! -z "${ENABLE_PERFORMANCE}" -a "${ENABLE_PERFORMANCE}" = "${_TRUE}" ] && writeLogEntry "PERFORMANCE" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "${FUNCTION_NAME} TOTAL RUNTIME: $(( RUNTIME / 60)) MINUTES, TOTAL ELAPSED: $(( RUNTIME % 60)) SECONDS";
    [ ! -z "${ENABLE_PERFORMANCE}" -a "${ENABLE_PERFORMANCE}" = "${_TRUE}" ] && writeLogEntry "PERFORMANCE" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "${FUNCTION_NAME} END: $(/usr/bin/env date +"${TIMESTAMP_OPTS}")";

    [ ! -z "${FUNCTION_NAME}" ] && unset -v FUNCTION_NAME;
    [ ! -z "${SCRIPT_NAME}" ] && unset -v SCRIPT_NAME;

    return ${RETURN_CODE};
}

#=====  FUNCTION  =============================================================
#          NAME:  writeLogEntry
#   DESCRIPTION:  Cleans up the archived log directory
#    PARAMETERS:  Archive Directory, Logfile Name, Retention Time
#       RETURNS:  0 regardless of result.
#==============================================================================
function writeLogEntry
{
    [ "$(/usr/bin/env | /usr/bin/env grep "ENABLE_VERBOSE" | /usr/bin/env cut -d "=" -f 2)" == "${_TRUE}" -a -z "${ENABLE_LOGGER_VERBOSE}" -o "${ENABLE_LOGGER_VERBOSE}" == "${_FALSE}" ] && set +x;
    [ "$(/usr/bin/env | /usr/bin/env grep "ENABLE_TRACE" | /usr/bin/env cut -d "=" -f 2)" == "${_TRUE}" -a -z "${ENABLE_LOGGER_TRACE}" -o "${ENABLE_LOGGER_TRACE}" == "${_FALSE}" ] && set +v;

    set +o noclobber;
    typeset SCRIPT_NAME="logging.sh";
    typeset FUNCTION_NAME="${FUNCNAME[0]}";
    typeset -i COUNTER=0;
    typeset -i RETURN_CODE=0;

    if [ ${#} -eq 0 -a ${#} -ne 5 ]
    then
        typeset RETURN_CODE=3;

        /usr/bin/env printf "${FUNCTION_NAME} - Write a log message to stdout/err or to a logfile\n" >&2;
        /usr/bin/env printf "Usage: ${FUNCTION_NAME} [ <level> ] [ <class/script> ] [ <method> ] [ <line> ] [ <message> ]
                 -> The level to write for. Supported levels (not case-sensitive):
                     STDOUT
                     STDERR
                     PERFORMANCE
                     FATAL
                     ERROR
                     INFO
                     WARN
                     AUDIT
                     DEBUG
                 -> The class/script calling the logger
                 -> The method calling the logger
                 -> The line number making the call
                 -> The message to be printed.\n" >&2;

        return ${RETURN_CODE};
    fi

    typeset LOG_DATE=$(date +"${TIMESTAMP_OPTS}");
    typeset LOG_LEVEL="${1}";
    typeset LOG_SOURCE="${2}";
    typeset LOG_METHOD="${3}";
    typeset LOG_LINE="${4}";
    typeset LOG_MESSAGE="${5}";

    case ${LOG_LEVEL} in
        [Ss][Tt][Dd][Oo][Uu][Tt]) printf "%s\n" "${5}" >&1; ;;
        [Ss][Tt][Dd][Ee][Rr][Rr]) printf "%s\n" "${5}" >&2; ;;
        [Pp][Ee][Rr][Ff][Oo][Rr][Mm][Aa][Nn][Cc][Ee]) typeset LOG_FILE="$(/usr/bin/env sed -e "s/.log/.${DATE_PATTERN}.log/" <<< "${PERF_LOG_FILE}")"; ;;
        [Ff][Aa][Tt][Aa][Ll]) typeset LOG_FILE="$(/usr/bin/env sed -e "s/.log/.${DATE_PATTERN}.log/" <<< "${FATAL_LOG_FILE}")"; ;;
        [Ee][Rr][Rr][Oo][Rr]) typeset LOG_FILE="$(/usr/bin/env sed -e "s/.log/.${DATE_PATTERN}.log/" <<< "${ERROR_LOG_FILE}")"; ;;
        [Ww][Aa][Rr][Nn]) typeset LOG_FILE="$(/usr/bin/env sed -e "s/.log/.${DATE_PATTERN}.log/" <<< "${WARN_LOG_FILE}")"; ;;
        [Ii][Nn][Ff][Oo]) typeset LOG_FILE="$(/usr/bin/env sed -e "s/.log/.${DATE_PATTERN}.log/" <<< "${INFO_LOG_FILE}")"; ;;
        [Aa][Uu][Dd][Ii][Tt]) typeset LOG_FILE="$(/usr/bin/env sed -e "s/.log/.${DATE_PATTERN}.log/" <<< "${AUDIT_LOG_FILE}")"; ;;
        [Dd][Ee][Bb][Uu][Gg]) typeset LOG_FILE="$(/usr/bin/env sed -e "s/.log/.${DATE_PATTERN}.log/" <<< "${DEBUG_LOG_FILE}")"; ;;
        [Mm][Oo][Nn][Ii][Tt][Oo][Rr]) typeset LOG_FILE="$(/usr/bin/env sed -e "s/.log/.${DATE_PATTERN}.log/" <<< "${MONITOR_LOG_FILE}")"; ;;
        *) typeset LOG_FILE="$(/usr/bin/env sed -e "s/.log/.${DATE_PATTERN}.log/" <<< "${DEFAULT_LOG_FILE}")"; ;;
    esac

    [ ! -z "${LOG_FILE}" ] && /usr/bin/env printf "${CONVERSION_PATTERN}\n" "${LOG_DATE}" "${PPID}" "${LOG_FILE}" "${LOG_LEVEL}" \
        "${LOG_SOURCE}" "${LOG_LINE}" "${LOG_METHOD}" "${LOG_MESSAGE}" >> "${LOG_ROOT}/${LOG_FILE}";

    [ ! -z "${LOG_DATE}" ] && unset -v LOG_DATE;
    [ ! -z "${LOG_LEVEL}" ] && unset -v LOG_LEVEL;
    [ ! -z "${LOG_METHOD}" ] && unset -v LOG_METHOD;
    [ ! -z "${LOG_SOURCE}" ] && unset -v LOG_SOURCE;
    [ ! -z "${LOG_LINE}" ] && unset -v LOG_LINE;
    [ ! -z "${LOG_MESSAGE}" ] && unset -v LOG_MESSAGE;
    [ ! -z "${LOG_FILE}" ] && unset -v LOG_FILE;

    [ "$(/usr/bin/env | grep "ENABLE_VERBOSE" | /usr/bin/env cut -d "=" -f 2)" == "${_TRUE}" ] && set -x;
    [ "$(/usr/bin/env | grep "ENABLE_TRACE" | /usr/bin/env cut -d "=" -f 2)" == "${_TRUE}" ] && set -v;

    return ${RETURN_CODE};
}

