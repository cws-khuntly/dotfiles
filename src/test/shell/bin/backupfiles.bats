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
    DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")" >/dev/null 2>&1 && pwd)"
    PATH="${DIR}/../../src/main/shell/bin:${DIR}/../../src/main/shell/lib/system:${DIR}/../../src/main/shell/lib/rotatefiles:${PATH}"
}

@test "can run our script" {
    backupfiles
}
