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

setup() {
    SRCDIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")" >/dev/null 2>&1 && pwd)"

    load "common-setup"
    load "../rotatefiles"

    _common_setup
}

@test "can run our script" {
    rotateFiles

    [ status -eq 3 ]
}

@test "TEST: rotateFiles local" {
    rotateFiles "local" "/var/tmp/local" "*" "/var/tmp/remote" "backup" 7
}

@test "TEST: rotateFiles remote" {
    rotateFiles "remote" "/var/tmp/remote" "*" 14
}
