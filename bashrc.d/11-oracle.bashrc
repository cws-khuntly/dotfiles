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

[[ -d "/usr/lib/oracle" ]] && return;

if [[ ! -d "${HOME}/.dotfiles/config/oracle/admin" ]] && [[ ! -f "${HOME}/.dotfiles/config/oracle/admin/tnsnames.ora" ]]; then return; fi

declare -x PATH="${PATH}:/usr/lib/oracle/19/client64/lib";
declare -x LD_LIBRARY_PATH="$LD_LIBRARY_PATH}:/usr/lib/oracle/19/client64/lib";

declare -x TNS_ADMIN="${HOME}/.dotfiles/config/oracle/admin";
