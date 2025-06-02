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

set _AUTH_VALUE "none";
set _PASSWD_LENGTH "64";
set _RANDOM_GENERATOR "/dev/urandom";

proc getAuthValue { _HOSTNAME _USERNAME { _AUTH_FILE "" } { _ID_FILE "" } { _ENCRYPTED 1 } { _ENCRYPTION_PRG "gpg" } } {
    global env;
    global tcl_platform;
    global _DEFAULT_ENCRYPTION;
    global _AUTH_VALUE;
    global _PASSWD_LENGTH;
    global _RANDOM_GENERATOR;
    global _DEFAULT_AUTH;

    if { [ string length $_AUTH_FILE ] != 0 } {
        set _AUTH_VARIABLE [ split $_AUTH_FILE ":" ];
    } elseif { [ info exists env(PASSWD_FILE) ] } {
        set _AUTH_VARIABLE [ split $env(PASSWD_FILE) ":" ];
    }

    if { $_ENCRYPTED ne 0 } {
        if { [ info exists env(ENCR_TYPE) ] } {
            set _ENCRYPTION_TYPE $env(ENCR_TYPE);
        } elseif { [ string length $_ENCRYPTION_PRG ] != 0 } {
            set _ENCRYPTION_TYPE $_ENCRYPTION_PRG;
        } else {
            set _ENCRYPTION_TYPE $_DEFAULT_ENCRYPTION;
        }
    } else {
        set _ENCRYPTION_TYPE "";
    }

    switch [ lindex $_AUTH_VARIABLE 0 ] {
        pass {
            set _AUTH_VALUE [ lindex $_AUTH_VARIABLE 1 ];
        }
        key {
            set _USER_KEY [ lindex $_AUTH_VARIABLE 1 ]

            if { [ llength $_AUTH_VARIABLE ] == 3 } {
                # key has a password
                set _USER_PASSWD [ lindex $_AUTH_VARIABLE 2 ]
            }
        }
        file {
            if { [ file exists [ lindex $_AUTH_VARIABLE 1 ] ] == 1 } {
                if { [ string length $_ENCRYPTION_TYPE ] != 0 } {
                    switch $_ENCRYPTION_TYPE {
                        gpg {
                            set _DECRYPTED [ split [ exec -ignorestderr bash -c ". $env(HOME)/.functions.d/F05-security; fileCrypt decrypt [ lindex $_AUTH_VARIABLE 1 ] 2> /dev/null" ] "\n" ]
                        }
                        openssl {
                            ## need to figure out a way to pass in the auth string for openssl here ...
                        }
                    }

                    foreach _ENTRY $_DECRYPTED {
                        if { [ string match "#*" $_ENTRY ] } {
                            # ignore by just going straight to the next loop iteration
                            continue;
                        }

                        set _AUTH_ENTRY [ split $_ENTRY " " ];

                        if { [ string match "id_*" [ lindex $_AUTH_ENTRY 0 ] ] } {
                            if { [ string length $_ID_FILE ] != 0 } {
                                if { [ string match $_HOSTNAME [ lindex $_AUTH_ENTRY 0 ] ] } {
                                    set _AUTH_VALUE [ lindex $_AUTH_ENTRY 1 ];
                                } elseif { [ string match $_HOSTNAME [ lindex $_AUTH_ENTRY 0 ] ] } {
                                    set _AUTH_VALUE [ lindex $_AUTH_ENTRY 1 ];
                                } else {
                                    continue;
                                }
                            } else {
                                if { [ string match $_HOSTNAME [ lindex $_AUTH_ENTRY 0 ] ] } {
                                    set _AUTH_VALUE [ lindex $_AUTH_ENTRY 1 ];
                                } elseif { [ string match $_HOSTNAME [ lindex $_AUTH_ENTRY 0 ] ] } {
                                    set _AUTH_VALUE [ lindex $_AUTH_ENTRY 1 ];
                                } else {
                                    continue;
                                }
                            }
                        } elseif { [ string match -nocase [ lindex $_AUTH_ENTRY 0 ] $_USERNAME ] } {
                            # username:home directory:pass:password:(new pass)
                            if { [ string match [ lindex $_AUTH_ENTRY 2 ] "none" ] } {
                                return;
                            } elseif { [ string match [ lindex $_AUTH_ENTRY 2 ] "pass" ] } {
                                set _AUTH_VALUE [ lindex $_AUTH_ENTRY 3 ];

                                break;
                            } elseif { [ string match [ lindex $_AUTH_ENTRY 2 ] "key" ] } {
                                set _AUTH_VALUE [ lindex $_AUTH_ENTRY 3 ];

                                break;
                            } else {
                                continue;
                            }
                        } elseif { [ string match -nocase [ lindex $_AUTH_ENTRY 0 ] $_HOSTNAME ] } {
                            # hostname:username:home directory:pass:password:(new pass)
                            if { [ string match -nocase [ lindex $_AUTH_ENTRY 1 ] $_USERNAME ] } {
                                if { [ string match [ lindex $_AUTH_ENTRY 3 ] "none" ] } {
                                    return;
                                } elseif { [ string match [ lindex $_AUTH_ENTRY 3 ] "pass" ] } {
                                    set _AUTH_VALUE [ lindex $_AUTH_ENTRY 4 ];

                                    break;
                                } elseif { [ string match [ lindex $_AUTH_ENTRY 3 ] "key" ] } {
                                    set _AUTH_VALUE [ lindex $_AUTH_ENTRY 4 ];

                                    break;
                                } else {
                                    continue;
                                }
                            } else {
                                continue;
                            }
                        } else {
                            continue;
                        }

                        if { [ info exists _ENTRY ] } { unset _ENTRY; }
                        if { [ info exists _AUTH_ENTRY ] } { unset _AUTH_ENTRY; }
                    }
                } else {
                    set _AUTH_FILE [ open [ lindex $_AUTH_VARIABLE 1 ] r ];
                    fconfigure $_AUTH_FILE -buffering line;

                    while { [ gets $_AUTH_FILE _ENTRY ] >= 0 } {
                        if { [ string match "#*" $_ENTRY ] } {
                            # ignore by just going straight to the next loop iteration
                            continue;
                        }

                        set _AUTH_ENTRY [ split $_ENTRY " " ];

                        if { [ string length $_HOSTNAME ] == 0 && [ string length $_USERNAME ] == 0 && [ string length $_ID_FILE ] == 0 } {
                            ## assume only one line entry and use that
                            set _AUTH_VALUE [ lindex $_AUTH_ENTRY 0 ];
                        } else {
                            if { [ string match "id_*" [ lindex $_AUTH_ENTRY 0 ] ] } {
                                if { [ string match [ lindex $_AUTH_ENTRY 0 ] $_ID_FILE ] } {
                                    set _AUTH_VALUE [ lindex $_AUTH_ENTRY 1 ];

                                    break;
                                } else {
                                    continue;
                                }
                            } elseif { [ string match -nocase [ lindex $_AUTH_ENTRY 0 ] $_USERNAME ] } {
                                # username:home directory:pass:password:(new pass)
                                if { [ string match [ lindex $_AUTH_ENTRY 2 ] "none" ] } {
                                    return;
                                } elseif { [ string match [ lindex $_AUTH_ENTRY 2 ] "pass" ] } {
                                    set _AUTH_VALUE [ lindex $_AUTH_ENTRY 3 ];

                                    break;
                                } elseif { [ string match [ lindex $_AUTH_ENTRY 2 ] "key" ] } {
                                    set _AUTH_VALUE [ lindex $_AUTH_ENTRY 3 ];

                                    break;
                                } else {
                                    continue;
                                }
                            } elseif { [ string match -nocase [ lindex $_AUTH_ENTRY 0 ] $_HOSTNAME ] } {
                                # hostname:username:home directory:pass:password:(new pass)
                                if { [ string match -nocase [ lindex $_AUTH_ENTRY 1 ] $_USERNAME ] } {
                                    if { [ string match [ lindex $_AUTH_ENTRY 3 ] "none" ] } {
                                        return;
                                    } elseif { [ string match [ lindex $_AUTH_ENTRY 3 ] "pass" ] } {
                                        set _AUTH_VALUE [ lindex $_AUTH_ENTRY 4 ];

                                        break;
                                    } elseif { [ string match [ lindex $_AUTH_ENTRY 3 ] "key" ] } {
                                        set _AUTH_VALUE [ lindex $_AUTH_ENTRY 4 ];

                                        break;
                                    } else {
                                        continue;
                                    }
                                } else {
                                    continue;
                                }
                            } else {
                                continue;
                            }
                        }

                        if { [ info exists _ENTRY ] } { unset _ENTRY; }
                        if { [ info exists _AUTH_ENTRY ] } { unset _AUTH_ENTRY; }
                    }

                    close $_AUTH_FILE;

                    if { [ info exists _AUTH_FILE ] } { unset _AUTH_FILE; }
                }
            }
        }
    }

    if { [ info exists _HOSTNAME ] } { unset _HOSTNAME; }
    if { [ info exists _USERNAME ] } { unset _USERNAME; }
    if { [ info exists _AUTH_FILE ] } { unset _AUTH_FILE; }
    if { [ info exists _ID_FILE ] } { unset _ID_FILE; }
    if { [ info exists _ENCRYPTED ] } { unset _ENCRYPTED; }
    if { [ info exists _ENCRYPTION_PRG ] } { unset _ENCRYPTION_PRG; }
    if { [ info exists _ENCRYPTION_TYPE ] } { unset _ENCRYPTION_TYPE; }
    if { [ info exists _AUTH_VARIABLE ] } { unset _AUTH_VARIABLE; }
    if { [ info exists _USER_PASSWD ] } { unset _USER_PASSWD; }
    if { [ info exists _USER_KEY ] } { unset _USER_KEY; }
    if { [ info exists _DECRYPTED ] } { unset _DECRYPTED; }
    if { [ info exists _ENTRY ] } { unset _ENTRY; }
    if { [ info exists _AUTH_ENTRY ] } { unset _AUTH_ENTRY; }
    if { [ info exists _ENTRY_NAME ] } { unset _ENTRY_NAME; }
    if { [ info exists _USER_NAME ] } { unset _USER_NAME; }
    if { [ info exists _PLAIN_ENTRY ] } { unset _PLAIN_ENTRY; }

    return "$_AUTH_VALUE";
}

#==============================================================================
#
#          FILE:  changeAccountPassword.tcl
#         USAGE:  ./changeAccountPassword.tcl
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

set _RANDOM_GENERATOR "/dev/urandom";
set _PASSWD_LENGTH "64";
set _LINE_TERMINATOR "\r\n";

set timeout 10;

proc changeAccountPassword { _REQUEST_TYPE _USER_NAME _CURRENT_PASSWD { _NEW_PASSWD "" } } {
    global env;
    global tcl_platform;
    global _RANDOM_GENERATOR;
    global _PASSWD_LENGTH;
    global _LINE_TERMINATOR;

    set _PASSWD_LENGTH "64";
    set _RANDOM_GENERATOR "/dev/urandom";

    set i 0;
    set x 0;

    if { [ string length $_NEW_PASSWD ] == 0 } {
        set _NEW_PASSWD [ exec /bin/sh -c "cat $_RANDOM_GENERATOR | tr -dc \"A-Za-z0-9_\" | head -c $_PASSWD_LENGTH" ];
    }

    switch $_REQUEST_TYPE {
        key {
            eval spawn ssh-keygen -f $_SSH_KEYFILE -p;

            expect {
                "*old passphrase*" {
                    exp_send "$_CURRENT_PASSPHRASE\r";
                    exp_continue;
                }
                "*?nter new passphrase*" {
                    exp_send "$_NEW_PASSWD\r";
                    exp_continue;
                }
                "*?nter same passphrase*" {
                    exp_send "$_NEW_PASSWD\r";
                    exp_continue;
                }
                $_LINE_TERMINATOR {
                    return "$_NEW_PASSWD";
                }
            }
        }
        account {
            expect {
                "*(current) UNIX password:*" {
                    exp_send "$_CURRENT_PASSWD\r";
                    exp_continue;
                }
                "*Changing password for \"$_USER_NAME\"*" {
                    exp_send "$_CURRENT_PASSWD\r";
                    exp_continue;
                }
                "*$_USER_NAME's ?ld password:*" {
                    exp_send "$_CURRENT_PASSWD\r";
                    exp_continue;
                }
                "*?ld password*" {
                    exp_send "$_CURRENT_PASSWD\r";
                    exp_continue;
                }
                "*$_USER_NAME's ?ew password:*" {
                    exp_send "$_NEW_PASSWD\r";
                    exp_continue;
                }
                "*?ew*password*" {
                    exp_send "$_NEW_PASSWD\r";
                    exp_continue;
                }
                "*Enter the new password again:" {
                    exp_send "$_NEW_PASSWD\r";
                    exp_continue;
                }
                "*Retype new UNIX password: *" {
                    exp_send "$_NEW_PASSWD\r";
                    exp_continue;
                }
                "*Authentication token manipulation error*" {
                    return 2;
                }
                "*BAD PASSWORD:*" {
                    if { ! [ expr { $x > 3 } ] } {
                        set _NEW_PASSWD [ exec /bin/sh -c "cat $_RANDOM_GENERATOR | tr -dc \"A-Za-z0-9_\" | head -c $_PASSWD_LENGTH" ];
                        set x [ expr { $x + 1 } ];
                    } else {
                        return 2;
                    }

                    set x [ expr { $x + 1 } ];
                    set _NEW_PASSWD [ exec /bin/sh -c "cat $_RANDOM_GENERATOR | tr -dc \"A-Za-z0-9_\" | head -c $_PASSWD_LENGTH" ];

                    exp_continue;
                }
                "*passwd: Have exhausted maximum number of retries for service*" {
                    return 2;
                }
                "*passwd: all authentication tokens updated successfully.*" {
                    ## success!
                    return "$_NEW_PASSWD";
                }
                "*?assword:*" {
                    if { [ expr { $i == 1 } ] } {
                        return 1;
                    }

                    set i [ expr { $i + 1 } ];

                    exp_send "$_CURRENT_PASSWD\r";
                    exp_continue;
                }
                $_LINE_TERMINATOR {
                    exp_continue;
                }
                "*\$*" {
                    exp_send "exit\r";

                    return "$_NEW_PASSWD";
                }
                default {
                    exp_continue;
                }
            }
        }
    }
}
