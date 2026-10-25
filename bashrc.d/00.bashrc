#!/usr/bin/env bash

#==============================================================================
#          FILE:  00-tmux.sh
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

if [[ $(command -v tmux 2>/dev/null) ]] && [[ -n "${PS1}" ]] && [[ -z "${TMUX}" ]] && [[ "${TERM_PROGRAM}" != "vscode" ]]; then
    exec tmux new-session -A -s main;
fi
