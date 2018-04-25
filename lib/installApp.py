#==============================================================================
#
#          FILE:  installApp.py
#         USAGE:  wsadmin.sh -lang jython -f installApp.py
#     ARGUMENTS:  appName, appPath, appTarget, appWarName, appWarFile, targetCell, targetCluster
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

def performAppInstallation(appName, appPath, appTarget, appWarName, appWarFile, targetCell, targetCluster)
    nodeList = AdminConfig.list('Node').split("\n")
    cluster = AdminControl.completeObjectName('cell=' + targetCell + ',type=Cluster,name=' + targetCluster + ',*')

    print "Installing application .."

    print AdminApp.update(appName, 'app', +
        '[ -operation update -contents ' + appPath + '-nopreCompileJSPs ' +
        '-installed.ear.destination ' + appTarget + ' -distributeApp -useMetaDataFromBinary ' +
        '-nodeployejb -createMBeansForResources -noreloadEnabled -nodeployws -validateinstall warn ' +
        '-noprocessEmbeddedConfig -filepermission .*\.dll=755#.*\.so=755#.*\.a=755#.*\.sl=755 ' +
        '-noallowDispatchRemoteInclude -noallowServiceRemoteInclude -asyncRequestDispatchType DISABLED ' +
        '-nouseAutoLink -MapModulesToServers [[ ' + appWarName + ' ' + appWarFile + ',WEB-INF/web.xml WebSphere:cell=' + targetCell + ',cluster=' + targetCluster + ' ]]]' )

    AdminApp.update(appName, 'app', +
        '[ -operation update -contents ' + appPath + '-nopreCompileJSPs ' +
        '-installed.ear.destination ' + appTarget + ' -distributeApp -useMetaDataFromBinary ' +
        '-nodeployejb -createMBeansForResources -noreloadEnabled -nodeployws -validateinstall warn ' +
        '-noprocessEmbeddedConfig -filepermission .*\.dll=755#.*\.so=755#.*\.a=755#.*\.sl=755 ' +
        '-noallowDispatchRemoteInclude -noallowServiceRemoteInclude -asyncRequestDispatchType DISABLED ' +
        '-nouseAutoLink -MapModulesToServers [[ ' + appWarName + ' ' + appWarFile + ',WEB-INF/web.xml WebSphere:cell=' + targetCell + ',cluster=' + targetCluster + ' ]]]' )

    print "Saving configuration.."

    AdminConfig.save()

    for node in nodeList:
        nodeName = AdminConfig.showAttribute(preNode, 'name')
        objName = "type=NodeSync,node=" + nodeName + ",*"
        syncNode = AdminControl.completeObjectName(objName)

        if syncNode != "":
            print "Checking node synchronization status.."
            nodeStatus = AdminControl.invoke(syncNode, 'isNodeSynchronized')
            print "Node status: " + nodeStatus
        else:
            print
        continue

    print "Performing ripple start.."

    AdminControl.invoke(cluster, 'rippleStart')

    print
    print "Executing getDeployStatus()"
    print AdminApp.getDeployStatus(appName)

    print
    print "Executing isAppReady()"
    print AdminApp.isAppReady(appName)

def printHelp():
    print "This script disables the HA Manager on a specific process"
    print "Format is disableHamOnProcess nodeName processName"

##################################
# main
#################################
if(len(sys.argv) == 7):
    performAppInstallation(sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4],sys.argv[5],sys.argv[6],sys.argv[7],)
else:
    printHelp()
