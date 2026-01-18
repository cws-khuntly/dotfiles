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

#=====  FUNCTION  =============================================================
#          NAME:  isNaN
#   DESCRIPTION:  Checks if the provided variable is a number
#    PARAMETERS:  Variable to check
#       RETURNS:  0 if true, 1 if false
#==============================================================================
printf "%s\n" "$(gpg --list-secret-keys --keyid-format=long | grep "[S]" | cut -d "/" -f 2 | awk '{print $1}')"

exit 0;
