#!/usr/bin/env bash

#==============================================================================
#
#          FILE:  /etc/profile.d/cws.sh
#         USAGE:  . /etc/profile.d/cws.sh
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

#=====  FUNCTION  =============================================================
#          NAME:  showHostInfo
#   DESCRIPTION:  Re-loads existing dotfiles for use
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function showHostInfo()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    local cname="cws-profile.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local return_code=0;
    local error_count=0;
    local host_system_name;
    local host_ip_address;
    local host_kernel_version;
    local host_cpu_count;
    local host_cpu_info;
    local host_memory_size;
    local swap_memory_size;
    local system_process_count;
    local user_disk_usage;
    local user_process_count;
    local start_epoch;
    local end_epoch;
    local runtime;

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

    ## system information
    host_system_name="$(hostname -s | tr '[:upper:]' '[:lower:]')";
    host_ip_address=("$(ip addr show 2> /dev/null | grep "inet" | grep -E -v "(inet6|127.0.0.1)" | awk '{print $2}' | tr "\n" " ")");
    host_kernel_version="$(uname -r)";
    host_cpu_count=$(grep -c "model name" /proc/cpuinfo);
    host_cpu_info="$(grep -E "model name" /proc/cpuinfo | uniq | cut -d ":" -f 2 | sed -e 's/^ *//g;s/ *$//g' | tr -s " ")";
    host_memory_size="$(( $(grep -E MemTotal /proc/meminfo | awk '{print $2}') / 1024 ^ 2 ))";
    swap_memory_size="$(( $(grep -E SwapTotal /proc/meminfo | awk '{print $2}') / 1024 ^ 2 ))";
    system_process_count=$(ps -ef | tail -n +1 | wc -l | awk '{print $1}');

    ## user information
    user_disk_usage=$(du -sh "${HOME}" 2> /dev/null | awk '{print $1}');
    user_process_count=$(ps -ef | tail -n +1 | grep -v grep | grep -c "${LOGNAME}");

    clear;

    printf "%s\n" "+-------------------------------------------------------------------+" >&2;
    printf "%40s %s\n" "Welcome to" "${host_system_name}" >&2;
    printf "%s\n" "+-------------------------------------------------------------------+" >&2;
    printf "\n" >&2;
    printf "%s\n" "+---------------------- System Information -------------------------+" >&2;
    printf "%-16s : %-10s\n" "+ IP Address" "${host_ip_address[@]}" >&2;
    printf "%-16s : %-10s\n" "+ Kernel version" "${host_kernel_version}" >&2;
    printf "%-16s : %-10s\n" "+ CPU" "${host_cpu_count} / ${host_cpu_info}" >&2;
    printf "%-16s : %-10d\n" "+ Processes" "${system_process_count}" >&2;
    printf "%-16s : %-10d MB\n" "+ Memory" "${host_memory_size}" >&2;
    printf "%-16s : %-10d MB\n" "+ Swap" "${swap_memory_size}" >&2;
    printf "%s\n" "+-------------------------------------------------------------------+" >&2;
    printf "\n" >&2;
    printf "%s\n" "+----------------------- User Information --------------------------+" >&2;
    printf "%-16s : %-10s\n" "+ Username" "${LOGNAME}" >&2;
    printf "%-16s : %-10s %s in %s\n" "+ Disk Usage" "You're currently using" "${user_disk_usage}" "${HOME}" >&2;
    printf "%-16s : %-10d\n" "+ Processes" "${user_process_count}" >&2;
    printf "%s\n" "+-------------------------------------------------------------------+" >&2;

    if [[ -r /etc/motd ]] && [[ -s /etc/motd ]]; then
        printf "\n" >&2;
        printf "%s\n" "+------------------------------ MOTD -------------------------------+" >&2;
        cat /etc/motd >&2;
        printf "%s\n" "+-------------------------------------------------------------------+" >&2;
    fi

    printf "\n" >&2;

    if [[ -n "${return_code}" ]] && (( return_code != 0 )); then return "${return_code}"; elif [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${host_system_name}" ]] && unset -v host_system_name;
    [[ -n "${host_ip_address[*]}" ]] && unset -v host_ip_address;
    [[ -n "${host_kernel_version}" ]] && unset -v host_kernel_version;
    [[ -n "${host_cpu_count}" ]] && unset -v host_cpu_count;
    [[ -n "${host_cpu_info}" ]] && unset -v host_cpu_info;
    [[ -n "${host_memory_size}" ]] && unset -v host_memory_size;
    [[ -n "${swap_memory_size}" ]] && unset -v swap_memory_size;
    [[ -n "${system_process_count}" ]] && unset -v system_process_count;
    [[ -n "${user_disk_usage}" ]] && unset -v user_disk_usage;
    [[ -n "${user_process_count}" ]] && unset -v user_process_count;

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${LOGGING_LOADED}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( end_epoch - start_epoch ));

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    [[ -n "${start_epoch}" ]] && unset -v start_epoch;
    [[ -n "${end_epoch}" ]] && unset -v end_epoch;
    [[ -n "${runtime}" ]] && unset -v runtime;
    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${cname}" ]] && unset -v cname;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return "${return_code}";
)

showHostInfo;
