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
declare -x PATH="${PATH}:${HOME}/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/usr/games";
declare -x MANPATH="${MANPATH}:${HOME}/man:/usr/man:/usr/local/man:/usr/share/man";

## libpath
declare -x LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${HOME}/lib:${HOME}/lib64:/lib:/lib64:/usr/lib:/usr/lib64:/usr/local/lib:/usr/local/lib64";
declare -x LIBPATH="${LD_LIBRARY_PATH}";
declare -x LIB_PATH="${LD_LIBRARY_PATH}";
declare -x LD_RUN_PATH="${LD_LIBRARY_PATH}";

## trap logout
trap 'logoutUser; exit' EXIT;

## make the umask sane
umask 022;
