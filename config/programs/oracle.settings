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

[[ -z "$(compgen -c | grep -Ew "(^sqlplus)" | sort | uniq)" ]] && return;

if [[ ! -d "${HOME}/.dotfiles/config/oracle/admin" ]] && [[ ! -f "${HOME}/.dotfiles/config/oracle/admin/tnsnames.ora" ]]; then return; fi

declare -x TNS_ADMIN="${HOME}/.dotfiles/config/oracle/admin";
