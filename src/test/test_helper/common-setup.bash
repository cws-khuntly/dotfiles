#!/usr/bin/env bats

#==============================================================================
#          FILE:  rotatefiles
#         USAGE:  See usage section
#   DESCRIPTION:
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

_common_setup() {
    load '../../../test_helper/bats-support/load'
    load '../../../test_helper/bats-assert/load'

    DIR="$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && printf "%s" "${PWD}")")"
    PATH="${DIR}/../../src/main/shell/lib/system:${DIR}/../../src/main/shell/lib/rotatefiles:${PATH}"
}
