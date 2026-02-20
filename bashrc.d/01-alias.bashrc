#!/usr/bin/env bash

#==============================================================================
#
#          FILE:  A999-custom
#         USAGE:  . A999-custom
#   DESCRIPTION:  Customizations
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

## customs
alias mountt="mount | column -t";
alias lt="ls -ltrhpF --color=auto";
alias la="ls -ltrahpF --color=auto";
alias ll="ls -lhpF --color=auto";
alias ll.="ls -ltrdhpF .* --color=auto";
alias li="ls -iltrhpF --color=auto";
alias li.="ls -iltrahpF --color=auto";
alias ld="ls -ldhpF --color=auto";
alias sizeof="du -sk";
alias mktd="pushd $(mktemp)";
alias stamp="date -d @\"${EPOCHREALTIME}\" +\"%Y%m%d %H:%M:%S\"";
alias da="date +\"%Y-%m-%d %A    %T %Z\"";
alias zero="cat /dev/null >|";
alias ssh="ssh -qt4AC";
alias removeKey="ssh-keygen -R";
alias win2unix="sed -e \"s/$/\r/"\";
alias fixtty="clear; reset; stty sane; clear; reset;";
alias time="time --format=\"%C took %e seconds\"";
alias pdftotext="pdftotext -enc UTF-8 -layout";
alias ff="find . -type f";
alias fd="find . -type d";
alias clearScroll="printf \"\033c\"";
alias icanhazip="dig +short @resolver1.opendns.com myip.opendns.com";
alias ipv4sort="sort -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4";
alias tailf="tail -f";
alias telnet="nc -vz";
alias shred="shred -vzu";
alias runsudoprior="sudo !!";

#
# meminfo
#
alias meminfo="free -m -l -t";
alias psmem="ps auxf | sort -nr -k 4";
alias psmem10="ps auxf | sort -nr -k 4 | head -10";
alias pscpu="ps auxf | sort -nr -k 3";
alias pscpu10="ps auxf | sort -nr -k 3 | head -10";
alias gpumeminfo="grep -i --color memory /var/log/Xorg.0.log";
alias hogc="ps -e -o %cpu,pid,ppid,user,cmd | sort -nr | head";
alias hogm="ps -e -o %mem,pid,ppid,user,cmd | sort -nr | head";
alias cpuCount="grep -c "^processor" /proc/cpuinfo";

## script tracing
alias enableDebug="ENABLE_DEBUG=\"${_TRUE}\"";
alias enableVerbose="ENABLE_VERBOSE=\"${_TRUE}\"";
alias enableTrace="ENABLE_TRACE=\"${_TRUE}\"";
alias enablePerf="ENABLE_PERFORMANCE=\"${_TRUE}\"";
alias disableDebug="ENABLE_DEBUG=\"${_FALSE}\"";
alias disableVerbose="ENABLE_VERBOSE=\"${_FALSE}\"";
alias disableTrace="ENABLE_TRACE=\"${_FALSE}\"";
alias disablePerf="ENABLE_PERFORMANCE=\"${_FALSE}\"";
alias reloadProfile="source \"${HOME}/.bash_profile\"";
alias listFunctions="compgen -A function";
alias listAliases="compgen -A alias";

#
# sudo aliases
#
alias sysadm="sudo su - sysadm";
alias root="sudo su -";

#
# run as alias
#
alias runAs="sudo -u";

#
# vim
#
[[ -n "$(compgen -c | grep -Ew "(^vim)" | sort | uniq)" ]] && alias vi="vim" || true;
