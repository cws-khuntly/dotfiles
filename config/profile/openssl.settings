#!/usr/bin/env bash

#==============================================================================
#
#          FILE:  A05-openssl
#         USAGE:  . A05-openssl
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

[[ -z "$(compgen -c | grep -Ew "(^openssl)" | sort | uniq)" ]] && return;

alias sha512sum='openssl sha512';
alias checkCSR='openssl req -text -noout -verify -in';
