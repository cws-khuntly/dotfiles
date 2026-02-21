#!/usr/bin/env bash

#==============================================================================
#
#          FILE:  alias
#         USAGE:  . alias
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

[[ ! -d "/var/named" ]] && return;
[[ -z "$(compgen -c | grep -Ew "(^named)" | sort | uniq)" ]] && return;

[[ "$(id dnsadm 2>/dev/null; printf "%s" "${?}")" == "0" ]] && alias dnsadm='sudo su - dnsadm';

[[ "$(id named 2>/dev/null; printf "%s" "${?}")" == "0" ]] && alias named='sudo -u named';

alias rndc='sudo -u named rndc -c /var/named/etc/conf.d/rndc.conf';
alias named-checkconf='sudo -u named named-checkconf -t /var/named';
alias named-checkzone='sudo -u named named-checkzone -t /var/named';
