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

[[ ! -d "${HOME}/workspace/python/venv" ]] && mkdir -pv
"${HOME}/workspace/python/venv";

if [[ -f "${HOME}/workspace/python/venv/bin/activate" ]]; then
    source "${HOME}/workspace/python/venv/bin/activate";
else
    [[ -z "$(compgen -c | grep -Ew "(^python)" | sort | uniq)" ]] && return;

    /usr/bin/env python -m venv "${HOME}/workspace/python/venv";

    source "${HOME}/workspace/python/venv/bin/activate";
fi

