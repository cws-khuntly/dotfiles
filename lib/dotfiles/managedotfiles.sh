#!/usr/bin/env bash

#======  FUNCTION  ============================================================
#          NAME:  runInstallLocalFiles
#   DESCRIPTION:  Installs dotfiles
#    PARAMETERS:  None
#       RETURNS:  0 regardless of result.
#==============================================================================
function runInstallLocalFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    function_name="${cname}#${FUNCNAME[0]}";
    return_code=0;
    error_count=0;

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
        fi
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

	if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: installFiles ${INSTALL_LOCATION_LOCAL}";
	fi

	[[ -n "${cname}" ]] && unset -v cname;
	[[ -n "${function_name}" ]] && unset -v function_name;
	[[ -n "${ret_code}" ]] && unset -v ret_code;

	installFiles "${INSTALL_LOCATION_LOCAL}";
	ret_code="${?}";

	cname="managedotfiles.sh";
	function_name="${cname}#${FUNCNAME[0]}";

	if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
	fi

    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
		return_code="${ret_code}"

        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred while processing action ${TARGET_ACTION} on host $(hostname -s) as user ${LOGNAME}. Please review logs.";
        fi
    else
        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "${TARGET_ACTION} on host $(hostname -s) as user ${LOGNAME} has completed successfully.";
        fi
    fi

    [[ -n "${ret_code}" ]] && unset -v ret_code;

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

#======  FUNCTION  ============================================================
#          NAME:  runInstallRemoteFiles
#   DESCRIPTION:  Installs dotfiles
#    PARAMETERS:  None
#       RETURNS:  0 regardless of result.
#==============================================================================
function runInstallRemoteFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
	cname="managedotfiles.sh";
    function_name="${cname}#${FUNCNAME[0]}";
    return_code=0;
    error_count=0;

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
        fi
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

	(( ${#} != 4 )) && return 3;

	target_hostname="${1}";
	target_ssh_port="${2}";
	target_ssh_user="${3}";
	force_exec="${4}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_hostname -> ${target_hostname}";
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_ssh_port -> ${target_ssh_port}";
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_ssh_user -> ${target_ssh_user}";
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "force_exec -> ${force_exec}";
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: installFiles ${INSTALL_LOCATION_REMOTE} ${target_hostname} ${target_ssh_port} ${target_ssh_user} ${force_exec}";
	fi

	[[ -n "${cname}" ]] && unset -v cname;
	[[ -n "${function_name}" ]] && unset -v function_name;
	[[ -n "${ret_code}" ]] && unset -v ret_code;

	installFiles "${INSTALL_LOCATION_REMOTE}" "${target_hostname}" "${target_ssh_port}" "${target_ssh_user}" "${force_exec}";
	ret_code="${?}";

	cname="managedotfiles.sh";
	function_name="${cname}#${FUNCNAME[0]}";

	if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
	fi

	if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
		return_code="${ret_code}"

		if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
			writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred while processing action ${TARGET_ACTION} on host ${target_hostname} as user ${target_ssh_user}. Please review logs.";
		fi
	else
		if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
			writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "${TARGET_ACTION} on host ${target_hostname} as user ${target_ssh_user} has completed successfully.";
		fi
	fi

	[[ -n "${target_hostname}" ]] && unset -v target_hostname;
	[[ -n "${target_ssh_port}" ]] && unset -v target_ssh_port;
	[[ -n "${target_ssh_user}" ]] && unset -v target_ssh_user;
	[[ -n "${force_exec}" ]] && unset -v force_exec;
	[[ -n "${ret_code}" ]] && unset -v ret_code;

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

#======  FUNCTION  ============================================================
#          NAME:  runDeployLocalFiles
#   DESCRIPTION:  Deploys dotfiles but does not install.
#    PARAMETERS:  None
#       RETURNS:  0 regardless of result.
#==============================================================================
function runDeployLocalFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
	cname="managedotfiles.sh";
    function_name="${cname}#${FUNCNAME[0]}";
    return_code=0;
    error_count=0;

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
        fi
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

	if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
		 writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: buildPackage";
	fi

	[[ -n "${cname}" ]] && unset -v cname;
	[[ -n "${function_name}" ]] && unset -v function_name;
	[[ -n "${ret_code}" ]] && unset -v ret_code;

	buildPackage;
	ret_code="${?}";

	cname="managedotfiles.sh";
	function_name="${cname}#${FUNCNAME[0]}";

	if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
	fi

    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
		return_code="${ret_code}"

        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to execute buildPackage. Please review logs.";
        fi
    else
		transfer_file_list="${TMPDIR:-${USABLE_TMP_DIR}}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}|${DEPLOY_TO_DIR},";
		transfer_file_list+="${WORKING_CONFIG_FILE}|${DEPLOY_TO_DIR}/$(basename "${WORKING_CONFIG_FILE}"),";
		transfer_file_list+="${INSTALL_CONF}|${DEPLOY_TO_DIR}/$(basename "${INSTALL_CONF}")";

		if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
			writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "transfer_file_list -> ${transfer_file_list}";
			writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: transferFiles ${TRANSFER_LOCATION_LOCAL} ${transfer_file_list}";
		fi

		[[ -n "${cname}" ]] && unset -v cname;
		[[ -n "${function_name}" ]] && unset -v function_name;
		[[ -n "${ret_code}" ]] && unset -v ret_code;

		transferFiles "${TRANSFER_LOCATION_LOCAL}" "${transfer_file_list}";
		ret_code="${?}";

		cname="managedotfiles.sh";
		function_name="${cname}#${FUNCNAME[0]}";

		if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
			writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
		fi

		if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
			return_code="${ret_code}"

			if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
				writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to perform file transfer to $(hostname -s). Please review logs.";
			fi
		else
			if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
				writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "Successfully transferred files to host $(hostname -s) as user ${LOGNAME}.";
			fi
		fi
    fi

    [[ -n "${transfer_file_list}" ]] && unset -v transfer_file_list;
    [[ -n "${ret_code}" ]] && unset -v ret_code;

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

#======  FUNCTION  ============================================================
#          NAME:  runDeployRemoteFiles
#   DESCRIPTION:  Deploys dotfiles but does not install.
#    PARAMETERS:  None
#       RETURNS:  0 regardless of result.
#==============================================================================
function runDeployRemoteFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
	cname="managedotfiles.sh";
    function_name="${cname}#${FUNCNAME[0]}";
    return_code=0;
    error_count=0;

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
        fi
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

	(( ${#} != 4 )) && return 3;

	target_host="${1}";
	ssh_port_number="${2}";
	target_user="${3}";
	force_exec="${4}";

	if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_host -> ${target_host}";
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ssh_port_number -> ${ssh_port_number}";
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_user -> ${target_user}";
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "force_exec -> ${force_exec}";
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: buildPackage";
	fi

	[[ -n "${cname}" ]] && unset -v cname;
	[[ -n "${function_name}" ]] && unset -v function_name;
	[[ -n "${ret_code}" ]] && unset -v ret_code;

	buildPackage;
	ret_code="${?}";

	cname="managedotfiles.sh";
	function_name="${cname}#${FUNCNAME[0]}";

	if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
	fi

    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
		return_code="${ret_code}"

        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to execute buildPackage. Please review logs.";
        fi
    else
		transfer_file_list="${TMPDIR:-${USABLE_TMP_DIR}}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}|${DEPLOY_TO_DIR},";
		transfer_file_list+="${WORKING_CONFIG_FILE}|${DEPLOY_TO_DIR}/$(basename "${WORKING_CONFIG_FILE}"),";
		transfer_file_list+="${INSTALL_CONF}|${DEPLOY_TO_DIR}/$(basename "${INSTALL_CONF}")";

		if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
			writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "transfer_file_list -> ${transfer_file_list}";
			writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: transferFiles ${TRANSFER_LOCATION_REMOTE} ${transfer_file_list} ${target_host} ${ssh_port_number} ${target_user} ${force_exec}";
		fi

		[[ -n "${cname}" ]] && unset -v cname;
		[[ -n "${function_name}" ]] && unset -v function_name;
		[[ -n "${ret_code}" ]] && unset -v ret_code;

		transferFiles "${TRANSFER_LOCATION_REMOTE}" "${transfer_file_list}" "${target_host}" "${ssh_port_number}" "${target_user}" "${force_exec}";
		ret_code="${?}";

		cname="managedotfiles.sh";
		function_name="${cname}#${FUNCNAME[0]}";

		if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
			writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
		fi

		if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
			return_code="${ret_code}"

			if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
				writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "${TARGET_ACTION} on host ${target_host} as user ${target_user} has completed failed. Please review logs.";
			fi
		else
			if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
				writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "${TARGET_ACTION} on host $(hostname -s) as user ${target_user} has completed successfully.";
			fi
		fi
	fi

    [[ -n "${transfer_file_list}" ]] && unset -v transfer_file_list;
	[[ -n "${target_host}" ]] && unset -v target_host;
	[[ -n "${ssh_port_number}" ]] && unset -v ssh_port_number;
	[[ -n "${target_user}" ]] && unset -v target_user;
	[[ -n "${force_exec}" ]] && unset -v force_exec;
    [[ -n "${ret_code}" ]] && unset -v ret_code;

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

#======  FUNCTION  ============================================================
#          NAME:  runRemoveLocalFiles
#   DESCRIPTION:  Removes installed dotfiles
#    PARAMETERS:  None
#       RETURNS:  0 regardless of result.
#==============================================================================
function runRemoveLocalFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    function_name="${cname}#${FUNCNAME[0]}";
    return_code=0;
    error_count=0;

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
        fi
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

    [[ -n "${cname}" ]] && unset -v cname;
	[[ -n "${function_name}" ]] && unset -v function_name;
	[[ -n "${ret_code}" ]] && unset -v ret_code;

	uninstallFiles "${UNINSTALL_LOCATION_LOCAL}";
	ret_code="${?}";

    cname="managedotfiles.sh";
	function_name="${cname}#${FUNCNAME[0]}";

	if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
	fi

    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
		return_code="${ret_code}"

        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to execute uninstallFiles with uninstall type of ${UNINSTALL_LOCATION_LOCAL}. Please review logs.";
        fi
    else
        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "File removal complete on host $(hostname -s) for user ${LOGNAME}.";
        fi
    fi

    [[ -n "${ret_code}" ]] && unset -v ret_code;

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

#======  FUNCTION  ============================================================
#          NAME:  runRemoveRemoteFiles
#   DESCRIPTION:  Removes installed dotfiles
#    PARAMETERS:  None
#       RETURNS:  0 regardless of result.
#==============================================================================
function runRemoveRemoteFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    function_name="${cname}#${FUNCNAME[0]}";
    return_code=0;
    error_count=0;

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
        fi
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

	(( ${#} != 4 )) && return 3;

	target_host="${1}";
	ssh_port_number="${2}";
	target_user="${3}";
	force_exec="${4}";

	if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_host -> ${target_host}";
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ssh_port_number -> ${ssh_port_number}";
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_user -> ${target_user}";
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "force_exec -> ${force_exec}";
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: uninstallFiles ${UNINSTALL_LOCATION_REMOTE} ${target_host} ${ssh_port_number} ${target_user} ${force_exec}";
	fi

    [[ -n "${cname}" ]] && unset -v cname;
	[[ -n "${function_name}" ]] && unset -v function_name;
	[[ -n "${ret_code}" ]] && unset -v ret_code;

	uninstallFiles "${UNINSTALL_LOCATION_REMOTE}" "${target_host}" "${ssh_port_number}" "${target_user}" "${force_exec}";
	ret_code="${?}";

    cname="managedotfiles.sh";
	function_name="${cname}#${FUNCNAME[0]}";

	if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
		writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
	fi

    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
		return_code="${ret_code}"

        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to execute uninstallFiles with uninstall type of ${UNINSTALL_LOCATION_REMOTE} on host ${target_host} as user ${target_user}. Please review logs.";
        fi
    else
        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "File removal on host ${target_host} as user ${target_user} complete.";
        fi
    fi

    [[ -n "${target_host}" ]] && unset -v target_host;
	[[ -n "${ssh_port_number}" ]] && unset -v ssh_port_number;
	[[ -n "${target_user}" ]] && unset -v target_user;
	[[ -n "${force_exec}" ]] && unset -v force_exec;
    [[ -n "${ret_code}" ]] && unset -v ret_code;

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
