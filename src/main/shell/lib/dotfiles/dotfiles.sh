#!/usr/bin/env bash

#==============================================================================
#          FILE:  misc.sh
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

function reloadDotFiles()
{
    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set -v; fi

    local cname="dotfiles.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i return_code=0;
    local -i error_count=0;
    local -i ret_code=0;
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

    clearCustomFunctions;
    clearCustomAliases;

    # shellcheck source=/home/khuntly/.dotfiles/bashrc
    source "${HOME}/.bash_profile";

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${directory_to_create}" ]] && unset -v directory_to_create;
    [[ -n "${cmd_output}" ]] && unset -v cmd_output;

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")";
        runtime=$(( end_epoch - start_epoch ))

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
}

function clearCustomFunctions()
(
    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set -v; fi

    local cname="dotfiles.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i return_code=0;
    local -i error_count=0;
    local -i ret_code=0;
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

    user_libs_path=( "${USER_LIB_PATH}/system" "${USER_LIB_PATH}/profile" "${USER_LIB_PATH}/dotfiles" );

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "USER_LIB_PATH -> ${USER_LIB_PATH}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "user_libs_path -> ${user_libs_path[*]}";
    fi

    for lib_path in "${user_libs_path[@]}"; do
        if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "lib_path -> ${lib_path}";
        fi

        mapfile -t file_list < <(find "${lib_path}" -type f -name \*.sh 2>/dev/null);

        if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "file_list -> ${file_list[*]}";
        fi

        if [[ -z "${file_list[*]}" ]] || (( ${#file_list[*]} == 0 )); then continue; fi

        for file in "${file_list[@]}"; do
            if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "file -> ${file}";
            fi

            [[ -z "${file}" ]] && continue;

            if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "EXEC: source ${LIB_PATH}/${FILE}";
            fi

            # shellcheck source=/dev/null
            function_list=( "$(grep -E "(^function .*\(\)$)" "${file}" | awk '{print $NF}' | sed -e "s/()//g")" );

            if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "function_list -> ${function_list}";
            fi

            for found_function in "${function_list[@]}"; do
                if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "found_function -> ${found_function}";
                fi

                [[ -z "${found_function}" ]] && continue;

                [[ -n "$(grep -c "${found_function}" "${IGNORE_FUNCTION_LIST}")" ]] && continue;

                if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "EXEC: unset -v ${found_function}";
                fi

                unset -v "${found_function}";

                [[ -n "${found_function}" ]] && unset -v found_function;
            done
        done
    done

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${directory_to_create}" ]] && unset -v directory_to_create;
    [[ -n "${cmd_output}" ]] && unset -v cmd_output;

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")";
        runtime=$(( end_epoch - start_epoch ))

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

function clearCustomAliases()
(
    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set -v; fi

    local cname="dotfiles.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i return_code=0;
    local -i error_count=0;
    local -i ret_code=0;
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

    case "${OSNAME}" in
        "fedoralinux"|"redhatenterpriselinux")
            if [[ -f "${USER_CONFIG_PATH}/system/rhel.osalias" ]] && [[ -r "${USER_CONFIG_PATH}/system/rhel.osalias" ]] && [[ -s "${USER_CONFIG_PATH}/system/rhel.osalias" ]]; then
                alias_list=( "$(grep -E "(^alias .*)" "${USER_CONFIG_PATH}/system/rhel.osalias" | awk '{print $2}' | cut -d "=" -f 1 )" )

                if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "alias_list -> ${alias_list}";
                fi

                for found_alias in "${alias_list[@]}"; do
                    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "found_alias -> ${found_alias}";
                    fi

                    [[ -z "${found_alias}" ]] && continue;

                    [[ -n "$(grep -c "${found_alias}" "${IGNORE_ALIAS_LIST}")" ]] && continue;

                    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "EXEC: unset -v ${found_alias}";
                    fi

                    unset -v "${found_alias}";

                    [[ -n "${found_alias}" ]] && unset -v found_alias;
                done

                [[ -n "${alias_list[*]}" ]] && unset -v alias_list;
            fi
            ;;
        "archlinux")
            if [[ -f "${USER_CONFIG_PATH}/system/arch.osalias" ]] && [[ -r "${USER_CONFIG_PATH}/system/arch.osalias" ]] && [[ -s "${USER_CONFIG_PATH}/system/arch.osalias" ]]; then
                alias_list=( "$(grep -E "(^alias .*)" "${USER_CONFIG_PATH}/system/arch.osalias" | awk '{print $2}' | cut -d "=" -f 1 )" )

                if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "alias_list -> ${alias_list}";
                fi

                for found_alias in "${alias_list[@]}"; do
                    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "found_alias -> ${found_alias}";
                    fi

                    [[ -z "${found_alias}" ]] && continue;

                    [[ -n "$(grep -c "${found_alias}" "${IGNORE_ALIAS_LIST}")" ]] && continue;

                    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "EXEC: unset -v ${found_alias}";
                    fi

                    unset -v "${found_alias}";

                    [[ -n "${found_alias}" ]] && unset -v found_alias;
                done

                [[ -n "${alias_list[*]}" ]] && unset -v alias_list;
            fi
            ;;
        "ubuntu")
            if [[ -f "${USER_CONFIG_PATH}/system/ubuntu.osalias" ]] && [[ -r "${USER_CONFIG_PATH}/system/ubuntu.osalias" ]] && [[ -s "${USER_CONFIG_PATH}/system/ubuntu.osalias" ]]; then
                alias_list=( "$(grep -E "(^alias .*)" "${USER_CONFIG_PATH}/system/ubuntu.osalias" | awk '{print $2}' | cut -d "=" -f 1 )" )

                if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "alias_list -> ${alias_list}";
                fi

                for found_alias in "${alias_list[@]}"; do
                    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "found_alias -> ${found_alias}";
                    fi

                    [[ -z "${found_alias}" ]] && continue;

                    [[ -n "$(grep -c "${found_alias}" "${IGNORE_ALIAS_LIST}")" ]] && continue;

                    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "EXEC: unset -v ${found_alias}";
                    fi

                    unset -v "${found_alias}";

                    [[ -n "${found_alias}" ]] && unset -v found_alias;
                done

                [[ -n "${alias_list[*]}" ]] && unset -v alias_list;
            fi
        ;;
    esac

    user_config_paths=( "${USER_CONFIG_PATH}/system" "${USER_CONFIG_PATH}/profile" "${USER_CONFIG_PATH}/dotfiles" );

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "USER_CONFIG_PATH -> ${USER_CONFIG_PATH}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "user_config_paths -> ${user_config_paths[*]}";
    fi

    for config_path in "${user_config_paths[@]}"; do
        if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "config_path -> ${config_path}";
        fi

        file_list=( "$(ls -ltr "${config_path}" | grep -E "(\.alias$|\.settings$)" | awk '{print $NF}')" );

        if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "file_list -> ${file_list[*]}";
        fi

        if [[ -z "${file_list[*]}" ]] || (( ${#file_list[*]} == 0 )); then continue; fi

        for file in "${file_list[@]}"; do
            if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "file -> ${file}";
            fi

            [[ -z "${file}" ]] && continue;

            if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "EXEC: source ${LIB_PATH}/${FILE}";
            fi

            # shellcheck source=/dev/null
            alias_list=( "$(grep -E "(^alias .*)" "${file}" | awk '{print $2}' | cut -d "=" -f 1 )" )

            if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "alias_list -> ${alias_list}";
            fi

            for found_alias in "${alias_list[@]}"; do
                if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "found_alias -> ${found_alias}";
                fi

                [[ -z "${found_alias}" ]] && continue;

                [[ -n "$(grep -c "${found_alias}" "${IGNORE_ALIAS_LIST}")" ]] && continue;

                if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "EXEC: unset -v ${found_alias}";
                fi

                unset -v "${found_alias}";

                [[ -n "${found_alias}" ]] && unset -v found_alias;
            done
        done
    done

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${directory_to_create}" ]] && unset -v directory_to_create;
    [[ -n "${cmd_output}" ]] && unset -v cmd_output;

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")";
        runtime=$(( end_epoch - start_epoch ))

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

function reinstallDotFiles()
(
    if [[ -n "${CONFIG_MAP["ENABLE_VERBOSE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_VERBOSE"]}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${CONFIG_MAP["ENABLE_TRACE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_TRACE"]}" == "${_TRUE}" ]]; then set -v; fi

    local cname="dotfiles.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i return_code=0;
    local -i error_count=0;
    local -i ret_code=0;
    local setup_repo_url;
    local setup_temp_dir;
    local dotfiles_repo_url;
    local dotfiles_temp_dir;
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

    (( ${#} != 2 )) && return 3;

    setup_repo_url="${1}";
    dotfiles_repo_url="${2}";

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "setup_repo_url -> ${setup_repo_url}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "dotfiles_repo_url -> ${dotfiles_repo_url}";
    fi

    setup_temp_dir="$(mktemp -d)";
    dotfiles_temp_dir="$(mktemp -d)";

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "setup_temp_dir -> ${setup_temp_dir}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "dotfiles_temp_dir -> ${dotfiles_temp_dir}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: git clone ${setup_repo_url} ${setup_temp_dir}";
    fi

    git clone "${setup_repo_url}" "${setup_temp_dir}";
    ret_code="${?}";

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
    fi

    if [[ -z "${ret_code}" ]] || (( ret_code != 0 ))
    then
        (( error_count += 1 ));

        if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to clone ${setup_repo_url} into ${setup_temp_dir}.";
        fi
    else
        if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: chmod 755 ${setup_temp_dir}/bin/setup";
        fi

        chmod 755 "${setup_temp_dir}/bin/setup";
        ret_code="${?}";

        if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
        fi

        if [[ -z "${ret_code}" ]] || (( ret_code != 0 ))
        then
            (( error_count += 1 ));

            if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to clone ${setup_repo_url} into ${setup_temp_dir}.";
            fi
        else
            if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: git clone ${dotfiles_repo_url} ${dotfiles_temp_dir}";
            fi

            git clone "${dotfiles_repo_url}" "${dotfiles_temp_dir}";
            ret_code="${?}";

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 ))
            then
                (( error_count += 1 ));

                if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to clone ${dotfiles_repo_url} into ${dotfiles_temp_dir}.";
                fi
            else
                if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: sed -i'' -e \"s/BUILD_PATH=.*/BUILD_PATH=\"${dotfiles_repo_url}\"/\" ${dotfiles_repo_url}/config/dotfiles/setup.properties";
                fi

                sed -i'' -e "s/BUILD_PATH=.*/BUILD_PATH=\"${dotfiles_repo_url}\"/" ${dotfiles_repo_url}/config/dotfiles/setup.properties;
                ret_code="${?}";

                if [[ -z "${ret_code}" ]] || (( ret_code != 0 ))
                then
                    (( error_count += 1 ));

                    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to modify file ${dotfiles_repo_url}/config/dotfiles/setup.properties.";
                    fi
                else
                    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: ${setup_temp_dir}/bin/setup -n ${dotfiles_repo_url}/config/dotfiles/setup.properties";
                    fi

                    ${setup_temp_dir}/bin/setup -n "${dotfiles_repo_url}/config/dotfiles/setup.properties";
                    ret_code="${?}";

                    if [[ -z "${ret_code}" ]] || (( ret_code != 0 ))
                    then
                        (( error_count += 1 ));

                        if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "setup failed with return code ${ret_code}. Please review logs.";
                        fi
                    else
                        if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "File installation completed successfully.";
                        fi
                    fi
                fi
            fi
        fi
    fi

    [[ -d "${setup_temp_dir}" ]] && rm -rf "${setup_temp_dir}";
    [[ -d "${dotfiles_temp_dir}" ]] && rm -rf "${dotfiles_temp_dir}";

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${setup_repo_url}" ]] && unset -v setup_repo_url;
    [[ -n "${setup_temp_dir}" ]] && unset -v setup_temp_dir;
    [[ -n "${dotfiles_repo_url}" ]] && unset -v dotfiles_repo_url;
    [[ -n "${dotfiles_temp_dir}" ]] && unset -v dotfiles_temp_dir;
    [[ -n "${cmd_output}" ]] && unset -v cmd_output;

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_DEBUG"]}" ]] && [[ "${CONFIG_MAP["ENABLE_DEBUG"]}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${CONFIG_MAP["LOGGING_LOADED"]}" ]] && [[ "${CONFIG_MAP["LOGGING_LOADED"]}" == "${_TRUE}" ]] && [[ -n "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" ]] && [[ "${CONFIG_MAP["ENABLE_PERFORMANCE"]}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")";
        runtime=$(( end_epoch - start_epoch ))

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
