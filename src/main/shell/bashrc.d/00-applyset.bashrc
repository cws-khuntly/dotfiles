#!/usr/bin/env bash

#==============================================================================
#          FILE:  00-applyset.sh
#         USAGE:  Import file into script and call relevant functions
#   DESCRIPTION:  Base system functions that don't necessarily belong elsewhere
#
#       OPTIONS:  See usage section
#  REQUIREMENTS:  bash 4+
#          BUGS:  ---
#         NOTES:
#        AUTHOR:  Kevin Huntly <kmhuntly@gmail.com>
#       COMPANY:  ---
#       VERSION:  1.0
#       CREATED:  ---
#      REVISION:  ---
#==============================================================================

set -o nounset;
set -o errexit;
set -o pipefail;
set -o notify;
set -o monitor;
set -o bell-visible-style;
