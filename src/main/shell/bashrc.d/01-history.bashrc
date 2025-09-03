#!/usr/bin/env bash

#==============================================================================
#
#          FILE:  defaults
#         USAGE:  . defaults
#   DESCRIPTION:  Sets default commandline options and variables for various programs
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

#
# history
#
case "$(awk -F "/" '{print $NF}' <<< "${SHELL}")" in
    [Bb][Aa][Ss][Hh])
        shopt -s histreedit;
        shopt -s histappend;
        shopt -s histverify;
        shopt -s cmdhist;
        ;;
esac

history -a;
history -n;

HISTFILE="${HOME}/.bash_history";
HISTSIZE=10000;
HISTFILESIZE=10000;
HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S ";
HISTCONTROL="ignoredups:ignorespace:ignoreboth:erasedups";
HISTIGNORE="ls:ll:lt:la:l:cd:pwd:exit:mc:su:df:clear:cls:bg:fg:passwd"
