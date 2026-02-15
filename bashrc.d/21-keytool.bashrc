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

[[ -z "$(compgen -c | grep -Ew "(^keytool)" | sort | uniq)" ]] && return;

====  FUNCTION  =============================================================
#          NAME:  returnRandomCharacters
#   DESCRIPTION:  Returns a random string of alphanumeric characters
#    PARAMETERS:  Length of string, include special characters
#       RETURNS:  0 regardless of result.
#==============================================================================
function addTrustedCert() { keytool -importcert -trustcacerts -alias "${1}" -file "${2}" -keystore "${3}" -storetype PKCS12; }
