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

declare -x XDG_CONFIG_HOME="${HOME}/.config";
declare -x XDG_RUNTIME_DIR="/run/user/$(id -u)";
declare -x XDG_CACHE_HOME="${HOME}/.cache";
declare -x XDG_DATA_HOME="${HOME}/.local/share";
declare -x XDG_STATE_HOME="${HOME}/.local/state";
declare -x XDG_DATA_DIRS="${XDG_DATA_DIRS}:${HOME}/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share"
