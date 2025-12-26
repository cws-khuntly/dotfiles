#!/usr/bin/env bash

#==============================================================================
#
#          FILE:  bash_profile
#         USAGE:  . bash_profile
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

CNAME="$(basename "${BASH_SOURCE[0]}")";
FUNCTION_NAME="${CNAME}#bash_profile";

## turn off ssh-agent and keychain
[[ -n "$(pidof ssh-agent)" ]] && pkill ssh-agent;
[[ -f "${HOME}/.ssh/ssh-agent.env" ]] && rm --force -- "${HOME}/.ssh/ssh-agent.env";

[[ -n "$(docker ps | grep kafka)" ]] && docker compose -f ${HOME}/workspace/docker/kafka/kafka.yaml down;

## write history
history -n; history -a; history -r;

## clear terminal scrollback
printf "\033c";

