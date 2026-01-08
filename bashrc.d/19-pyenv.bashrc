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

[[ ! -d "${HOME}/workspace/venv" ]] && mkdir "${HOME}/workspace/venv";

if [[ -f "${HOME}/workspace/venv/bin/activate" ]]; then
    source "${HOME}/workspace/venv/bin/activate";
else
    /usr/bin/env python -m venv "${HOME}/workspace/venv";

    source "${HOME}/workspace/venv/bin/activate";
fi
