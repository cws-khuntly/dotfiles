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
    load '../../../test_helper/common-setup'
    load 'rotatefiles'

    _common_setup
}

@test "can run our script" {
    rotateFiles

    [ status -eq 3 ]
}
