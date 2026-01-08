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

[[ -z "${LOGNAME}" ]] && declare -x LOGNAME="$(whoami)";

#
# path and things
#
declare -x SYSTEM_PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/usr/games";
declare -x USER_PATH="${HOME}/bin:${HOME}/.local/bin";
declare -x USER_LIB_PATH="${HOME}/lib";
declare -x USER_CONFIG_PATH="${HOME}/.dotfiles/config";
declare -x PATH="${PATH}:${SYSTEM_PATH}:${USER_PATH}";
declare -x DOT_PROFILE_LOADED="true";

#
# read-only
#
declare -rx TIMEFORMAT=$'\nreal %3R\tuser %3U\tsys %3S\tpcpu %P\n' 2>/dev/null;
declare -rx LESS="-QR" 2>/dev/null;
declare -rx BLOCKSIZE="K" 2>/dev/null;
declare -rx PAGER="less" 2>/dev/null;
declare -rx EDITOR="vim" 2>/dev/null;
declare -rx FCEDIT="vim" 2>/dev/null;
declare -rx VISUAL="vim" 2>/dev/null;
declare -rx SSH_AUTH_SOCK="${XDG_RUNTIME_DIR:-/run/user/${UID}}/ssh-agent.socket" 2>/dev/null;

#
# read-write
#
declare -x DISPLAY="127.0.0.1:0.0";
declare -ix THREAD_TIMEOUT=10;
declare -x MODIFIED_IFS="^";
declare -x RANDOM_GENERATOR="/dev/urandom";
declare -x ENTROPY_FILE="${HOME}/.dotfiles/config/entropy";
declare -ix ENTROPY_FILE_SIZE=16384;
declare -x WGETRC="${HOME}/.dotfiles/config/system/wgetrc";
declare -x LDAPRC="${HOME}/.dotfiles/config/system/ldaprc";
declare -x AUTHFILE="${HOME}/.dotfiles/config/profile/authfile.gpg";
declare -x LOGGING_PROPERTIES="${HOME}/.dotfiles/config/dotfiles/logging.properties";

#
# mail
#
declare -x MAIL="/var/spool/mail/${LOGNAME:?}";
declare -ix MAILCHECK=10;

#
# prompt
#
declare -x PROMPT_COMMAND=setPromptCommand;
