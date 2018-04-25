#==============================================================================
#
#          FILE:  restartCluster.py
#         USAGE:  wsadmin.sh -lang jython -f restartCluster.py
#     ARGUMENTS:  (clusterName)
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
import time

def restartClusters():
    targetCell = AdminControl.getCell()
    lineSplit = java.lang.System.getProperty("line.separator")
    clusterList = AdminConfig.list('ServerCluster').split(lineSplit)

    for cluster in clusterList:
        clusterName = AdminControl.completeObjectName('cell=' + targetCell + ',type=Cluster,name=' + cluster.split("(")[0] + ',*')
        
        print "Cluster " + cluster.split("(")[0] + " is currently: " + AdminControl.getAttribute(clusterName, "state" ).split(".")[2]
        
        AdminControl.invoke(clusterName, "stop")
        
        time.sleep(900)
        
        if AdminControl.getAttribute(clusterName, "state" ).split(".")[2] = "stopped":
            AdminControl.invoke(clusterName, "rippleStart")

            continue

def restartCluster(clusterName):
    targetCell = AdminControl.getCell()
    lineSplit = java.lang.System.getProperty("line.separator")
    clusterList = AdminConfig.list('ServerCluster').split(lineSplit)

    for cluster in clusterList:
        if clusterName == cluster.split("(")[0]:
            break
        else:
            print "The provided cluster is not available on this system."

            sys.exit(1)

    for cluster in clusterList:
        clusterName = AdminControl.completeObjectName('cell=' + targetCell + ',type=Cluster,name=' + cluster.split("(")[0] + ',*')
        
        print "Cluster " + cluster.split("(")[0] + " is currently: " + AdminControl.getAttribute(clusterName, "state" ).split(".")[2]
        
        AdminControl.invoke(clusterName, "stop")
        
        time.sleep(900)
        
        if AdminControl.getAttribute(clusterName, "state" ).split(".")[2] = "stopped":
            AdminControl.invoke(clusterName, "rippleStart")

            continue

def printHelp():
    print "This script configures default values for the Deployment Manager."
    print "Format is configureDMGR wasVersion"

##################################
# main
#################################
if(len(sys.argv) == 1):
    # get node name and process name from the command line
    configureNodeAgent(sys.argv[0])
else:
    restartClusters()

