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
    SRCDIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")" >/dev/null 2>&1 && pwd)"
    PATH="${SRCDIR}/../../src/main/shell/lib/system:${SRCDIR}/../../src/main/shell/lib/rotatefiles:${PATH}"

    export SRCDIR

    load "${SRCDIR}/../../../test_helper/bats-support/load"
    load "${SRCDIR}/../../../test_helper/bats-assert/load"
}
