#!/usr/bin/env bash

#==============================================================================
#
#          FILE:  websphere
#         USAGE:  . websphere
#   DESCRIPTION:  Loads keychain and adds available keys to it
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

if [[ -z "$(compgen -c | grep -Ew "(^docker)" | sort | uniq)" ]]; then alias websphere-liberty='docker pull websphere-liberty'; fi

[[ ! -d "/opt/IBM/WebSphere" ]] && return;

alias wasadm='sudo su - wasadm';

[[ ! -d "/opt/IBM/HTTPServer" ]] && return;

alias ihsadm='sudo su - ihsadm';
