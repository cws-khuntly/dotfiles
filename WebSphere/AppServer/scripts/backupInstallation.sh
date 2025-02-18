#!/usr/bin/env bash

#==============================================================================
#          FILE:  createDeploymentManager.sh
#         USAGE:  createDeploymentManager.sh <property file>
#   DESCRIPTION:  Builds a WebSphere Application Server Deployment Manager
#
#       OPTIONS:  See usage section
#  REQUIREMENTS:  bash 4+
#          BUGS:  ---
#         NOTES:
#        AUTHOR:  Kevin Huntly <kmhuntly@gmail.com>
#       COMPANY:  CaspersBox Web Services
#       VERSION:  1.0
#       CREATED:  ---
#      REVISION:  ---
#==============================================================================

if [[ -r "${HOME}/lib/system/basefunctions.sh" ]] && [[ -s "${HOME}/lib/system/basefunctions.sh" ]]; then
    source ${HOME}/lib/system/basefunctions.sh;
else
    if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "Unable to load base functions. Please verify the file exists and can be read.";
        writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "Unable to load base functions. Please verify the file exists and can be read.";
    fi

    return 1;
fi

#=====  FUNCTION  =============================================================
#          NAME:  executeBackup
#   DESCRIPTION:  Backs up a WebSphere Application Server installation
#    PARAMETERS:  Directory to create
#       RETURNS:  0 if success, 1 otherwise
#==============================================================================
function executeBackup()   
{
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    cname="executeBackup";
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

    #======  FUNCTION  ============================================================
    #          NAME:  usage
    #   DESCRIPTION:  
    #    PARAMETERS:  None
    #       RETURNS:  0 regardless of result.
    #==============================================================================
    function usage()
    (
        if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
        if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

        set +o noclobber;
        cname="buildDeploymentManager";
        function_name="${cname}#${FUNCNAME[1]}";
        return_code=3;

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        fi

        printf "%s %s\n" "${FUNCNAME[1]}" "Backs up a WebSphere Application Server installation." >&2;
        printf "%s %s\n" "Usage: ${FUNCNAME[1]}" "[ property file ]" >&2;
        printf "    %s: %s\n" "<property file>" "The property file holding the server configuration values." >&2;

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
        fi

        if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
        if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

        return ${return_code};
    )

    if (( ${#} == 0 )); then usage; return "${?}"; fi

    property_file="${1}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "property_file -> ${property_file}";
    fi

    if [[ -r "${property_file}" ]] && [[ -s "${property_file}" ]]; then
        readPropertyFile "${property_file}";
        ret_code=${?};

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
        fi
    
        if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
            (( error_count += 1 ));

            if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to load property file. Ensure the file exists and can be read.";
                writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to load property file. Ensure the file exists and can be read.";
            fi
        else
            case "${BACKUP_TYPE}" in
                "[Pp][Rr][Oo][Ff][Ii][Ll][Ee]")
                    backupServerProfile "${PROFILE_NAME}";
                    ret_code=${?};

                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
                    fi

                    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                        (( error_count += 1 ));

                        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred backing up the server profile. Please review logs under ${WAS_INSTALL_ROOT}/logs/manageprofiles.";
                            writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred backing up the server profile. Please review logs under ${WAS_INSTALL_ROOT}/logs/manageprofiles.";
                        fi
                    fi
                "[Ff][Ii][Ll][Ee][Ss][Yy][Ss][Tt][Ee][Mm]")
                    backupServerFilesystem "${WAS_INSTALL_ROOT}" "${BACKUP_DIRECTORY}";
                    ret_code=${?};

                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
                    fi

                    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                        (( error_count += 1 ));

                        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred backing up the server filesystem. Please review logs.";
                            writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred backing up the server filesystem. Please review logs.";
                        fi
                    fi
                "[Aa][Ll][Ll]|[Bb][Oo][Tt][Hh]")
                    backupServerProfile "${PROFILE_NAME}";
                    ret_code=${?};

                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
                    fi

                    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                        (( error_count += 1 ));

                        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred backing up the server profile. Please review logs under ${WAS_INSTALL_ROOT}/logs/manageprofiles.";
                            writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred backing up the server profile. Please review logs under ${WAS_INSTALL_ROOT}/logs/manageprofiles.";
                        fi
                    else
                        backupServerFilesystem "${BACKUP_FILESYSTEM}" "${BACKUP_DIRECTORY}";
                        ret_code=${?};

                        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
                        fi

                        if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                            (( error_count += 1 ));

                            if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred backing up the server filesystem. Please review logs.";
                                writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred backing up the server filesystem. Please review logs.";
                            fi
                        fi
                    fi
                *)
                    (( error_count += 1 ));

                    if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "A valid backup type was not provided. Please review the configured property file.";
                        writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "A valid backup type was not provided. Please review the configured property file.";
                    fi
            esac
        fi
    else
        (( error_count += 1 ));

        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Unable to read provided property file ${property_file}. Please verify the file exists, is readable, and contains data.";
            writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Unable to read provided property file ${property_file}. Please verify the file exists, is readable, and contains data.";
        fi

        [[ -n "${ret_code}" ]] && unset -v ret_code;
        [[ -n "${property_file}" ]] && unset -v property_file;
    fi

    if [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${IBM_INSTALL_ROOT}" ]] && unset -v IBM_INSTALL_ROOT;
    [[ -n "${WAS_INSTALL_ROOT}" ]] && unset -v WAS_INSTALL_ROOT;
    [[ -n "${WAS_PROFILE_NAME}" ]] && unset -v WAS_PROFILE_NAME;
    [[ -n "${FILESYSTEM_BACKUP_WAS_ONLY}" ]] && unset -v FILESYSTEM_BACKUP_WAS_ONLY;
    [[ -n "${FILESYSTEM_BACKUP_IHS_ONLY}" ]] && unset -v FILESYSTEM_BACKUP_IHS_ONLY;
    [[ -n "${FILESYSTEM_BACKUP_WCT_ONLY}" ]] && unset -v FILESYSTEM_BACKUP_WCT_ONLY;
    [[ -n "${FILESYSTEM_BACKUP_WPS_ONLY}" ]] && unset -v FILESYSTEM_BACKUP_WPS_ONLY;
    [[ -n "${BACKUP_DIRECTORY}" ]] && unset -v BACKUP_DIRECTORY;
    [[ -n "${BACKUP_TYPE_PROFILE}" ]] && unset -v BACKUP_TYPE_PROFILE;
    [[ -n "${BACKUP_TYPE_FILESYSTEM}" ]] && unset -v BACKUP_TYPE_FILESYSTEM;
    [[ -n "${BACKUP_TYPE_ALL}" ]] && unset -v BACKUP_TYPE_ALL;
    [[ -n "${BACKUP_TYPE_DEFAULT}" ]] && unset -v BACKUP_TYPE_DEFAULT;
    [[ -n "${BACKUP_TYPE}" ]] && unset -v BACKUP_TYPE;

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${property_file}" ]] && unset -v property_file;

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( end_epoch - start_epoch ));

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${cname}" ]] && unset -v cname;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return ${return_code};
}

#=====  FUNCTION  =============================================================
#          NAME:  backupServerProfile
#   DESCRIPTION:  Creates a WebSphere Application Server deployment manager
#    PARAMETERS:  Directory to create
#       RETURNS:  0 if success, 1 otherwise
#==============================================================================
function backupServerProfile()
{
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    cname="backupProfile";
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

    #======  FUNCTION  ============================================================
    #          NAME:  usage
    #   DESCRIPTION:  
    #    PARAMETERS:  None
    #       RETURNS:  0 regardless of result.
    #==============================================================================
    function usage()
    (
        if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
        if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

        set +o noclobber;
        cname="backupServerProfile";
        function_name="${cname}#${FUNCNAME[1]}";
        return_code=3;

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        fi

        printf "%s %s\n" "${FUNCNAME[1]}" "Creates a filesystem backup of a provided WebSphere profile." >&2;
        printf "%s %s\n" "Usage: ${FUNCNAME[1]}" "[ profile ]" >&2;
        printf "    %s: %s\n" "<profile name>" "The name of the WebSphere profile to back up." >&2;

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
        fi

        if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
        if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

        return ${return_code};
    )

    if (( ${#} == 0 )); then usage; return "${?}"; fi

    profile_name="${1}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "profile_name -> ${profile_name}";
    fi

    if [[ -n "${profile_name}" ]]; then
        ## get a list of all the servers in this profile so we can turn them down
        
        /usr1/IBM/WebSphere/profiles/dmgr01/bin/serverStatus.sh -all 
        server_list="$(echo -e "$(/usr1/IBM/WebSphere/profiles/dmgr01/bin/serverStatus.sh -all | grep "Server name" | cut -d ":" -f 3)" | xargs)"
        ${WAS_INSTALL_ROOT}/${profile_name}/bin/stopManager.sh

        rm -rf /usr1/IBM/WebSphere/profiles/dmgr01/temp/*
        rm -rf /usr1/IBM/WebSphere/profiles/dmgr01/wstemp/*

        /usr1/IBM/WebSphere/profiles/dmgr01/bin/clearClassCache.sh
        /usr1/IBM/WebSphere/profiles/dmgr01/bin/osgiCfgInit.sh

        /usr1/IBM/WebSphere/AppServer/bin/manageprofiles.sh -backupProfile -profileName dmgr01 -backupFile /usr1/IBM/backups/dmgr01-PostPortalInstall-backup.$(date +"%d-%m-%Y_%H:%M:%S");
    else
        (( error_count += 1 ));

        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "No profile name was provided to back up. Cannot continue.";
        fi

        [[ -n "${ret_code}" ]] && unset -v ret_code;
        [[ -n "${property_file}" ]] && unset -v property_file;
    fi

    if [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${property_file}" ]] && unset -v property_file;

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( end_epoch - start_epoch ));

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${cname}" ]] && unset -v cname;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return ${return_code};
}

#=====  FUNCTION  =============================================================
#          NAME:  createDeploymentManager
#   DESCRIPTION:  Creates a directory and then changes into it
#    PARAMETERS:  Directory to create
#       RETURNS:  0 if success, 1 otherwise
#==============================================================================
function createDeploymentManager()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    cname="createDeploymentManager";
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

    #======  FUNCTION  ============================================================
    #          NAME:  usage
    #   DESCRIPTION:  
    #    PARAMETERS:  None
    #       RETURNS:  0 regardless of result.
    #==============================================================================
    function usage()
    (
        if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
        if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

        set +o noclobber;
        cname="F02-misc";
        function_name="${cname}#${FUNCNAME[1]}";
        return_code=3;

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        fi

        printf "%s %s\n" "${FUNCNAME[1]}" "Creates a deployment manager profile." >&2;
        printf "%s %s\n" "Usage: ${FUNCNAME[1]}" "[ hostname ] [ admin username ] [ admin password ] [ cell name ] [ node name ] [ profile name ] [ profile path ]" >&2;
        printf "    %s: %s\n" "<hostname>" "The fully qualified domain name for the deployment manager host. Defaults to the value provided by \$(hostname -f)" >&2;
        printf "    %s: %s\n" "<admin username>" "The administrative username for the deployment manager." >&2;
        printf "    %s: %s\n" "<admin password>" "The administrative password for the deployment manager." >&2;
        printf "    %s: %s\n" "<cell name>" "The name of the deployment manager cell. Defaults to dmgrCell01." >&2;
        printf "    %s: %s\n" "<node name>" "The name of the deployment manager node. Defaults to dmgrNode01." >&2;
        printf "    %s: %s\n" "<profile name>" "The name of the deployment manager profile. Defaults to dmgr01." >&2;
        printf "    %s: %s\n" "<profile path>" "The name of the deployment manager profile. Defaults to \${WEBSPHERE_BASE_PATH}/profiles/dmgr01." >&2;

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
        fi

        if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
        if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

        return ${return_code};
    )

    if (( ${#} == 0 )); then usage; return "${?}"; fi

    [[ -z "${DMGR_HOST_NAME}" ]] && DMGR_HOST_NAME="$(hostname -f)";
    [[ -z "${DMGR_PROFILE_CELL}" ]] && DMGR_PROFILE_CELL="dmgrCell01";
    [[ -z "${DMGR_PROFILE_NODE}" ]] && DMGR_PROFILE_CELL="dmgrNode01";
    [[ -z "${DMGR_PROFILE_NAME}" ]] && DMGR_PROFILE_NAME="dmgr01";
    [[ -z "${DMGR_PROFILE_PATH}" ]] && DMGR_PROFILE_NAME="${WEBSPHERE_BASE_PATH}/profiles/${DMGR_PROFILE_NAME}";

    ## turn off history for now
    set +o history;

    "${WAS_INSTALL_ROOT}/bin/manageprofiles.sh" -create -hostname "${DMGR_HOST_NAME}" \
        -adminUserName "${DMGR_ADMIN_USERNAME}" -adminPassword "${DMGR_ADMIN_PASSWORD}" -enableAdminSecurity true \
        -cellName "${DMGR_PROFILE_CELL}" -nodeName "${DMGR_PROFILE_NODE}" -profileName "${DMGR_PROFILE_NAME}" \
        -templatePath "${WAS_INSTALL_ROOT}/profileTemplates/management" -profilePath "${DMGR_PROFILE_PATH}";
    ret_code="${?}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
    fi

    ## turn history back on
    set -o history;

    if [[ -z "${ret_code}" ]] || [[ ${ret_code} != 0 ]]; then
        (( error_count += 1 ));

        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred creating the deployment manager profile. Please review logs under ${WAS_INSTALL_ROOT}/logs/manageprofiles.";
            writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred creating the deployment manager profile. Please review logs under ${WAS_INSTALL_ROOT}/logs/manageprofiles.";
        fi

        [[ -n "${ret_code}" ]] && unset -v ret_code;
    else
        writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "The deployment manager profile was successfully created.";
        writeLogEntry "STDOUT" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "The deployment manager profile was successfully created.";
    fi

    if [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${property_file}" ]] && unset -v property_file;

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( end_epoch - start_epoch ));

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${cname}" ]] && unset -v cname;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return ${return_code};
)

#=====  FUNCTION  =============================================================
#          NAME:  augmentDeploymentManager
#   DESCRIPTION:  Augments an existing deployment manager profile for WebSphere
#                 Portal Server
#    PARAMETERS:  Directory to create
#       RETURNS:  0 if success, 1 otherwise
#==============================================================================
function augmentDeploymentManager()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    cname="augmentDeploymentManager";
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

    #======  FUNCTION  ============================================================
    #          NAME:  usage
    #   DESCRIPTION:  
    #    PARAMETERS:  None
    #       RETURNS:  0 regardless of result.
    #==============================================================================
    function usage()
    (
        if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
        if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

        set +o noclobber;
        cname="F02-misc";
        function_name="${cname}#${FUNCNAME[1]}";
        return_code=3;

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; the
             writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        fi

        printf "%s %s\n" "${FUNCNAME[1]}" "Creates a deployment manager profile." >&2;
        printf "%s %s\n" "Usage: ${FUNCNAME[1]}" "[ hostname ] [ admin username ] [ admin password ] [ cell name ] [ node name ] [ profile name ] [ profile path ]" >&2;
        printf "    %s: %s\n" "<hostname>" "The fully qualified domain name for the deployment manager host. Defaults to the value provided by \$(hostname -f)" >&2;
        printf "    %s: %s\n" "<admin username>" "The administrative username for the deployment manager." >&2;
        printf "    %s: %s\n" "<admin password>" "The administrative password for the deployment manager." >&2;
        printf "    %s: %s\n" "<cell name>" "The name of the deployment manager cell. Defaults to dmgrCell01." >&2;
        printf "    %s: %s\n" "<node name>" "The name of the deployment manager node. Defaults to dmgrNode01." >&2;
        printf "    %s: %s\n" "<profile name>" "The name of the deployment manager profile. Defaults to dmgr01." >&2;
        printf "    %s: %s\n" "<profile path>" "The name of the deployment manager profile. Defaults to \${WEBSPHERE_BASE_PATH}/profiles/dmgr01." >&2;

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
        fi

        if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
        if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

        return ${return_code};
    )

    if (( ${#} == 0 )); then usage; return "${?}"; fi

    [[ -z "${DMGR_HOST_NAME}" ]] && DMGR_HOST_NAME="$(hostname -f)";
    [[ -z "${DMGR_PROFILE_CELL}" ]] && DMGR_PROFILE_CELL="dmgrCell01";
    [[ -z "${DMGR_PROFILE_NODE}" ]] && DMGR_PROFILE_CELL="dmgrNode01";
    [[ -z "${DMGR_PROFILE_NAME}" ]] && DMGR_PROFILE_NAME="dmgr01";
    [[ -z "${DMGR_PROFILE_PATH}" ]] && DMGR_PROFILE_NAME="${WEBSPHERE_BASE_PATH}/profiles/${DMGR_PROFILE_NAME}";

    if [[ -r "${PORTAL_DMGR_FILES}" ]]; then
        unzip "${PORTAL_DMGR_FILES}" -d "${WAS_INSTALL_ROOT}";
        ret_code="${?}";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
        fi

        if [[ -z "${ret_code}" ]] || [[ ${ret_code} != 0 ]]; then
            (( error_count += 1 ));

            if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred unzipping the Portal deployment manager files. Please review logs.";
                writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred unzipping the Portal deployment manager files. Please review logs.";
            fi

            [[ -n "${ret_code}" ]] && unset -v ret_code;
        else
            if [[ "${DMGR_PROFILE_PATH}" != "${WAS_INSTALL_ROOT}/profiles/Dmgr01" ]]; then
                ## move the wkplc metadata file to the appropriate location
                mv "${WAS_INSTALL_ROOT}/profiles/Dmgr01/.repository/metadata_wkplc.xml" "${DMGR_PROFILE_PATH}/config/.repository/metadata_wkplc.xml";
                ret_code="${?}";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
                fi

                if [[ -z "${ret_code}" ]] && [[ ${ret_code} != 0 ]]; then
                    (( error_count += 1 ));

                    if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred moving the Portal deployment manager wkplc file. Please review logs.";
                        writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred moving the Portal deployment manager wkplc file. Please review logs.";
                    fi

                    [[ -n "${ret_code}" ]] && unset -v ret_code;
                else
                    ## clean up
                    rm -rf "${WAS_INSTALL_ROOT}/profiles/Dmgr01";
                    ret_code="${?}";

                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
                    fi

                    if [[ -z "${ret_code}" ]] && [[ ${ret_code} != 0 ]]; then
                        (( error_count += 1 ));

                        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred moving the Portal deployment manager wkplc file. Please review logs.";
                            writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred moving the Portal deployment manager wkplc file. Please review logs.";
                        fi

                        [[ -n "${ret_code}" ]] && unset -v ret_code;
                    fi
                fi
            fi

            ## augment the profile and restart the dmgr
            "${DMGR_PROFILE_PATH}/bin/stopManager.sh";
            ret_code="${?}";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
            fi

            if [[ -z "${ret_code}" ]] && [[ ${ret_code} != 0 ]]; then
                (( error_count += 1 ));

                if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred stopping the deployment manager. Please review logs under ${DMGR_PROFILE_PATH}/logs and ${DMGR_PROFILE_PATH}/logs/${DMGR_PROFILE_NAME}.";
                    writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred stopping the deployment manager. Please review logs under ${DMGR_PROFILE_PATH}/logs and ${DMGR_PROFILE_PATH}/logs/${DMGR_PROFILE_NAME}.";
                fi

                [[ -n "${ret_code}" ]] && unset -v ret_code;
            else
                ## run the augment
                "${WAS_INSTALL_ROOT}/bin/manageprofiles.sh" -augment -profileName dmgr01 \
                    -templatePath "${WAS_INSTALL_ROOT}/profileTemplates/management.portal.augment" -profileName "${DMGR_PROFILE_NAME}";
                ret_code="${?}";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
                fi

                if [[ -z "${ret_code}" ]] || [[ ${ret_code} != 0 ]]; then
                    (( error_count += 1 ));

                    if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred augmenting the deployment manager profile. Please review logs under ${WAS_INSTALL_ROOT}/logs/manageprofiles.";
                        writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred augmenting the deployment manager profile. Please review logs under ${WAS_INSTALL_ROOT}/logs/manageprofiles.";
                    fi

                    [[ -n "${ret_code}" ]] && unset -v ret_code;
                else
                    ## restart the dmgr
                    "${DMGR_PROFILE_PATH}/bin/startManager.sh";
                    ret_code="${?}";

                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
                    fi

                    if [[ -z "${ret_code}" ]] && [[ ${ret_code} != 0 ]]; then
                        (( error_count += 1 ));

                        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred starting the deployment manager. Please review logs under ${DMGR_PROFILE_PATH}/logs and ${DMGR_PROFILE_PATH}/logs/${DMGR_PROFILE_NAME}.";
                            writeLogEntry "STDERR" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred starting the deployment manager. Please review logs under ${DMGR_PROFILE_PATH}/logs and ${DMGR_PROFILE_PATH}/logs/${DMGR_PROFILE_NAME}.";
                        fi

                        [[ -n "${ret_code}" ]] && unset -v ret_code;
                    else
                        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "The deployment manager profile was successfully augmented.";
                            writeLogEntry "CONSOLE" "STDOUT" "${$}" "${cname}" "${LINENO}" "${function_name}" "The deployment manager profile was successfully augmented.";
                        fi
                    fi

                    [[ -n "${ret_code}" ]] && unset -v ret_code;
                fi

                [[ -n "${ret_code}" ]] && unset -v ret_code;
            fi
        fi
    else
        (( error_count += 1 ));

        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "The location of the Portal deployment manager files was not found or could not be read. Please confirm the location of these files.";
            writeLogEntry "STDERR" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "The location of the Portal deployment manager files was not found or could not be read. Please confirm the location of these files.";
        fi

        [[ -n "${ret_code}" ]] && unset -v ret_code;
    fi

    if [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    [[ -n "${ret_code}" ]] && unset -v ret_code;

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( end_epoch - start_epoch ));

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${cname}" ]] && unset -v cname;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return ${return_code};
)
