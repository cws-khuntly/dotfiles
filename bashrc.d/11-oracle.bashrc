#!/usr/bin/env bash

#==============================================================================
#
#          FILE:  P01-oracle
#         USAGE:  . P01-oracle
#   DESCRIPTION:  Loads keychain and adds available keys to it
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

[[ -d "/usr/lib/oracle" ]] || return;

if [[ ! -d "${HOME}/.dotfiles/config/oracle/admin" ]] && [[ ! -f "${HOME}/.dotfiles/config/oracle/admin/tnsnames.ora" ]]; then return; fi

for d in $(ls -ltr "/usr/lib/oracle" | grep -E "(^d)" | awk '{print $NF}'); do
    [[ -d "${d}/client/bin" ]] && declare -x PATH="${PATH}:${d}/client/bin";
    [[ -d "${d}/client64/bin" ]] && declare -x PATH="${PATH}:${d}/client64/bin";

    [[ -d "${d}/client/bin" ]] && declare -x LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${d}/client/lib";
    [[ -d "${d}/client64/bin" ]] && declare -x LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${d}/client64/lib";
done

declare -x TNS_ADMIN="${HOME}/.dotfiles/config/oracle/admin";
