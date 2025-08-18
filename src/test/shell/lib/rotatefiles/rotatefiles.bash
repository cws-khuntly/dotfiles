#!/usr/bin/env bash

#==============================================================================
#          FILE:  rotatefiles.sh
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

# shellcheck source=../../config/rotatefiles/rotatefiles.properties
source "../../config/rotatefiles/rotatefiles.properties";

# shellcheck source=../../../../main/shell/lib/rotatefiles/rotatefiles.sh
source "../../../../main/shell/lib/rotatefiles/rotatefiles.sh";
