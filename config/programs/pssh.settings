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

[[ -z "$(compgen -c | grep -Ew "(^pssh)" | sort | uniq)" ]] && return;

alias pssh='pssh -p 5 -o ${HOME}/log/pssh -e ${HOME}/log/pssh -t 900 -P -l ${LOGNAME} -h ${HOME}/.dotfiles/config/pssh/hosts';
alias prsync='prsync -p 5 -o ${HOME}/log/pssh -e ${HOME}/log/pssh -t 900 -l ${LOGNAME} -h ${HOME}/.dotfiles/config/pssh/hosts';
