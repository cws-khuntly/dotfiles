#!/usr/bin/env bash

#==============================================================================
#          FILE:  basefunctions.sh
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

declare -Ax CONFIG_MAP=();

#=====  FUNCTION  =============================================================
#          NAME:  readPropertyFile
#   DESCRIPTION:  Reads a provided property file into the shell
#    PARAMETERS:  File
#       RETURNS:  0 if success, 1 otherwise
#==============================================================================
function readPropertyFile()
{
    local cname="basefunctions.sh";
    local function_name="${cname}#${FUNCNAME[0]}";
    local -i return_code=0;
    local -i error_count=0;
    local property_name;
    local property_value;
    local config_file;
    local -i start_epoch;
    local -i end_epoch;
    local -i runtime;

    (( ${#} != 1 )) && return 3;

    config_file="${1}";

    mapfile -t config_entries < "${config_file}";

    if (( ${#config_entries[*]} == 0 )); then
        (( error_count += 1 ));
    else
        for entry in "${config_entries[@]}"; do
            [[ -z "${entry}" ]] && continue;
            [[ "${entry}" =~ ^# ]] && continue;

            property_name="$(cut -d "=" -f 1 <<< "${entry}" | xargs)";
            property_value="$(cut -d "=" -f 2- <<< "${entry}" | xargs)";

            CONFIG_MAP["${property_name}"]="${property_value}";

            [[ -n "${property_name}" ]] && unset property_name;
            [[ -n "${property_value}" ]] && unset property_value;
            [[ -n "${entry}" ]] && unset entry;
        done
    fi

    if [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${property_name}" ]] && unset property_name;
    [[ -n "${property_value}" ]] && unset property_value;
    [[ -n "${entry}" ]] && unset entry;

    [[ -n "${start_epoch}" ]] && unset start_epoch;
    [[ -n "${end_epoch}" ]] && unset end_epoch;
    [[ -n "${runtime}" ]] && unset runtime;
    [[ -n "${function_name}" ]] && unset function_name;
    [[ -n "${cname}" ]] && unset cname;

    return "${return_code}";
}
