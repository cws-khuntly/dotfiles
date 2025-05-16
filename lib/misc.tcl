#==============================================================================
#
#          FILE:  getAuthValue
#         USAGE:  ./getAuthValue
#   DESCRIPTION:  Executes an scp connection to a pre-defined server
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
#==============================================================================

proc parseParams { params } {
    for { set i 0 } { $i < [ llength $params ] } { incr i } {
        set arg [ lindex $params $i ]

        if { [ string equal -length 2 $arg "--" ] } {
            set _MYPARM [ string toupper [ string range $arg 2 [ string length $arg ] ] ]
        } else {
            set _MYVAR $arg
        }
    }

    return "$_MYPARM $_MYVAR"

    unset arg;
    unset i;
    unset _MYPARM;
    unset _MYVAR;
}
