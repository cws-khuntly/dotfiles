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

[[ -d "${HOME}/.kube" ]] || return;

declare -x KUBECONFIG="${HOME}/.kube/config";

printf '\e[31m%s\e[0m\n' "*** KUBECONFIG SET TO DEFAULT. DONT FORGET TO CHANGE.";
