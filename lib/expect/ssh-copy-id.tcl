#!/usr/bin/env expect
#==============================================================================
#
#          FILE:  sshCopyIdentity
#         USAGE:  ./sshCopyIdentity
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

## set up some class info
global env;
global _CNAME;
global _METHOD_NAME;
global _LINE_TERMINATOR;

set _CNAME "ssh-copy-id.tcl";
set _METHOD_NAME "ssh-copy-id.tcl";
set _LINE_TERMINATOR "\r\n";
set USERNAME $env(LOGNAME);
set timeout 30;

if { ! [ info exists env(AUTHFILE) ] } {
    return -code error "No authfile was located in the environment. Cannot continue.";
}

if { [ info exists env(ENABLE_VERBOSE) ] } {
    if { [ string match -nocase $env(ENABLE_VERBOSE) "true" ] == 1 } {
        log_user 1;
        log_file -a $env(HOME)/log/ssh-copy-id.log;
    }
}

if { [ info exists env(ENABLE_TRACE) ] } {
    if { [ string match -nocase $env(ENABLE_TRACE) "true" ] == 1 } {
        exp_internal 1;
    }
}

if { [ info exists env(THREAD_TIMEOUT) ] } {
    set timeout $env(THREAD_TIMEOUT);
}

source [ file join [ file dirname [ info script ] ] env(HOME)/lib/tcl/misc.tcl ];

proc usage {} {
    global _METHOD_NAME;

    puts stderr "$_METHOD_NAME Perform an automated SSH-based task without user interaction.";
    puts stderr "Usage: $_METHOD_NAME \[ hostname \] \[ port \] \[ user \] \[ identity \]";
    puts stderr "\thostname            The target hostname to connect to. The host must be either an IP address or resolvable hostname.";
    puts stderr "\tport                The target port to connect to.";
    puts stderr "\tusername            The user to connect to the remote system as."; ## _USER_LOGINID
    puts stderr "\tidentity            The identity file to send"; ## _IDENTITY_FILE
    puts stderr "\ttimeout             A timeout value for the script to wait if it hangs. If not specified, a value of 10 seconds is used.";

    exit 3;
}

## make sure we have all our arguments
if { [ expr { $argc < 4 } ] } {
    usage;
} else {
    ## set runtime information
    for { set a 0 } { $a ne $argc } { incr a } {
        set PARM_NAME [ string toupper [ string range [ lindex $argv $a ] 2 [ string length [ lindex $argv $a ] ] ] ]
        set [ set PARM_NAME ] [ lindex [ split [ parseParams "[ lindex $argv $a ] [ lindex $argv [ expr "$a" + "1" ] ]" ] " " ] 1 ]

        incr a;
    }

    set _AUTH_DATA [ split [ exec -ignorestderr bash -c "gpg --decrypt [ $env(AUTHFILE) ] 2> /dev/null | grep -Ew \"(^[ $_HOSTNAME ]|[ $_USERNAME ])\"" " " ] ];

    switch [ llength $_AUTH_DATA ] {
        1 {
            set _USER_PASSWD $_AUTH_DATA;
        }
        2 {
            set _USER_KEY [ lindex $_AUTH_DATA 0 ];
            set _USER_PASSWD [ lindex $_AUTH_DATA 1 ];
        }
    }
}

if { ! [ info exists _USER_PASSWD ] } {
    puts stderr "No password was found. Cannot continue.";

    exit 1;
}

eval spawn ssh-copy-id -i "$IDENTITY" -f -oPort="$PORT "$USERNAME@$HOSTNAME";

set i 0;

expect {
    "*(yes/no)? " {
        exp_send "yes\r";

        exp_continue;
    }
    "*?assword*" {
        if { [ expr { $i == 1 } ] } {
            puts stderr "An invalid password was provided for user account $USERNAME on host $HOSTNAME";

            exit 1;
        }

        set i [ expr { $i + 1 } ];

        exp_send "$_USER_PASSWD\r";

        exp_continue;
    }
    "*All keys were skipped*" {
        puts "Keyfile $IDENTITY already exists on host $HOSTNAME for user $USERNAME";

        exit 0;
    }
    "\r\nNumber of key(s) added: 1\r\n" {
        puts "Keyfile $IDENTITY added to host $HOSTNAME for user $USERNAME";

        exit 0;
    }
    eof {
        append output $expect_out(buffer);

        exp_continue;
    }
}
