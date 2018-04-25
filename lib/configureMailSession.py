#==============================================================================
#
#          FILE:  configureMailSession.py
#         USAGE:  wsadmin.sh -lang jython -f configureMailSession.py
#     ARGUMENTS:  jndiName transportHost ((userName) (userPass) (mailFrom))
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

import sys

def configureMailSession(jndiName, transportHost, userName = "", userPass = "", mailFrom = ""):
    print "Adding mail session provider .."

    AdminConfig.create('MailSession', AdminConfig.getid('/Cell:' + AdminControl.getCell() + '/MailProvider:Built-in Mail Provider/'), '[[category ""] [description ""] [debug "false"] [name "' + jndiName + '"] [jndiName "jndi/' + jndiName + '"] [mailTransportHost "' + transportHost + '"]  [mailTransportUser "' + userName + '"] [mailTransportPassword "' + userPass + '"] [mailStoreUser ""] [mailStorePassword ""] [mailStoreHost ""] [strict "true"] [mailFrom ""]]')

    print "Saving configuration .."
    AdminConfig.save()

    nodeList = AdminTask.listManagedNodes().split("\n")

    for node in nodeList:
        nodeRepo = AdminControl.completeObjectName('type=ConfigRepository,process=nodeagent,node=' + node + ',*')

        if not nodeRepo:
            AdminControl.invoke(nodeRepo, 'refreshRepositoryEpoch')

        syncNode = AdminControl.completeObjectName('cell=' + AdminControl.getCell() + ',node=' + node + ',type=NodeSync,*')

        if not syncNode:
            AdminControl.invoke(syncNode, 'sync')

        continue

def printHelp():
    print "This script configures a cell-level mail transport."
    print "Format is configureMailSession jndiName transportHost ((userName) (userPass) (mailFrom))"

##################################
# main
#################################
if(len(sys.argv) >= 2):
    # get node name and process name from the command line
    if (len(sys.argv) == 5):
        configureMailSession(sys.argv[0], sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])
    else:
        configureMailSession(sys.argv[0], sys.argv[1])
else:
    printHelp()
