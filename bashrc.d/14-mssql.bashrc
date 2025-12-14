#!/usr/bin/env bash

#==============================================================================
#
#          FILE:  A02-git
#         USAGE:  . A02-git
#   DESCRIPTION:  Useful git aliases
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

[[ -d "/opt/microsoft" ]] || return;

declare -x PATH="${PATH}:/opt/mssql-tools18/bin";
declare -x LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/opt/microsoft/msodbcsql18/lib64";
