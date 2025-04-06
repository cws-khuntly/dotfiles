#==============================================================================
#
#          FILE:  git-update.service
#         USAGE:  Install unit file using appropriate systemctl syntax.
#     ARGUMENTS:  None
#   DESCRIPTION:  systemd service to run git update periodically
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
[Unit]
Description=git update for WebSphere repo
ConditionPathExists=%h/workspace/WebSphere

[Service]
Type=oneshot
ExecStart=/bin/git -C %h/workspace/WebSphere fetch origin
ExecStart=/bin/git -C %h/workspace/WebSphere reset --hard origin/master
ExecStart=/bin/git -C %h/workspace/WebSphere pull
SuccessExitStatus=0

[Install]
Also=git-update.timer
