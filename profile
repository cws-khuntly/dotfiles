#!/usr/bin/env bash

#==============================================================================
#
#          FILE:  profile
#         USAGE:  . profile
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

## path
declare -x SYSTEM_PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/usr/games";
declare -x USER_PATH="${HOME}/bin";
declare -x USER_LIB_PATH="${HOME}/lib";
declare -x USER_CONFIG_PATH="${HOME}/.config";
declare -x PATH="${PATH}:${SYSTEM_PATH}:${USER_PATH}";

## trap logout
trap 'logoutUser; exit' EXIT;

## make the umask sane
umask 022;
