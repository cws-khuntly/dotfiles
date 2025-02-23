#==============================================================================
#
#          FILE:  configureDMGR.py
#         USAGE:  wsadmin.sh -lang jython -f configureDMGR.py
#     ARGUMENTS:  wasVersion
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

import os
import sys

lineSplit = java.lang.System.getProperty("line.separator")

serverName = "dmgr"
targetCell = AdminControl.getCell()
nodeList = AdminTask.listManagedNodes().split(lineSplit)

def configureDeploymentManager(runAsUser="", runAsGroup=""):
    targetServer = AdminConfig.getid('/Server:' + serverName + '/')

    if (targetServer):
        print ("Starting configuration for deployment manager " + serverName + "...")

        haManager = AdminConfig.list("HAManagerService", targetServer)
        threadPools = AdminConfig.list("ThreadPool", targetServer).split(lineSplit)
        processExec = AdminConfig.list("ProcessExecution", targetServer)
        targetTransport = AdminConfig.list("TransportChannelService", targetServer)
        targetWebContainer = AdminConfig.list("WebContainer", targetServer)
        targetCookie = AdminConfig.list("Cookie", targetServer)
        targetTuning = AdminConfig.list("TuningParams", targetServer)
        targetTCPChannels = AdminConfig.list("TCPInboundChannel", targetServer).split(lineSplit)
        targetHTTPChannels = AdminConfig.list("HTTPInboundChannel", targetServer).split(lineSplit)
        containerChains = AdminTask.listChains(targetTransport, '[-acceptorFilter WebContainerInboundChannel]').split(lineSplit)

        AdminConfig.create('Property', targetWebContainer, '[[validationExpression ""] [name "com.ibm.ws.webcontainer.extractHostHeaderPort"] [description ""] [value "true"] [required "false"]]')
        AdminConfig.create('Property', targetWebContainer, '[[validationExpression ""] [name "trusthostheaderport"] [description ""] [value "true"] [required "false"]]')
        AdminConfig.create('Property', targetWebContainer, '[[validationExpression ""] [name "com.ibm.ws.webcontainer.invokefilterscompatibility"] [description ""] [value "true"] [required "false"]]')

        AdminConfig.modify(haManager, '[[enable "false"] [activateEnabled "true"] [isAlivePeriodSec "120"] [transportBufferSize "10"] [activateEnabled "true"]]')
        AdminConfig.modify(targetWebContainer, '[[sessionAffinityTimeout "0"] [enableServletCaching "true"] [disablePooling "false"] [defaultVirtualHostName "default_host"]]')
        AdminConfig.modify(targetCookie, '[[maximumAge "-1"] [name "JSESSIONID"] [domain ""] [secure "true"] [path "/"]]')
        AdminConfig.modify(targetTuning, '[[writeContents "ONLY_UPDATED_ATTRIBUTES"] [writeFrequency "END_OF_SERVLET_SERVICE"] [scheduleInvalidation "false"] [invalidationTimeout "60"]]')

        if ((runAsUser) and (runAsGroup)):
            AdminConfig.modify(processExec, '[[runAsUser "' + runAsUser + '"] [runAsGroup "' + runAsGroup + '"] [runInProcessGroup "0"] [processPriority "20"] [umask "022"]]')
        elif (runAsUser):
            AdminConfig.modify(processExec, '[[runAsUser "' + runAsUser + '"] [runInProcessGroup "0"] [processPriority "20"] [umask "022"]]')
        else:
            AdminConfig.modify(processExec, '[[runInProcessGroup "0"] [processPriority "20"] [umask "022"]]')
        #end if

        AdminTask.setJVMProperties('[-serverName ' + serverName + ' -nodeName dmgrNode01 -verboseModeGarbageCollection true -initialHeapSize 4096 -maximumHeapSize 4096 -genericJvmArguments "-Djava.compiler=NONE -Xdebug -Xnoagent -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=7792 -Xshareclasses:none"]')

        if (threadPools):
            for threadPool in (threadPools):
                poolName = threadPool.split("(")[0]

                if (poolName == "server.startup"):
                    AdminConfig.modify(threadPool, '[[maximumSize "10"] [name "' + poolName + '"] [inactivityTimeout "30000"] [minimumSize "0"] [description "This pool is used by WebSphere during server startup."] [isGrowable "false"]]')
                elif (poolName == "WebContainer"):
                    AdminConfig.modify(threadPool, '[[maximumSize "75"] [name "' + poolName + '"] [inactivityTimeout "5000"] [minimumSize "20"] [description ""] [isGrowable "false"]]')
                elif (poolName == "HAManagerService.Pool"):
                    AdminConfig.modify(threadPool, '[[minimumSize "0"] [maximumSize "6"] [inactivityTimeout "5000"] [isGrowable "true" ]]')
                else:
                    continue
                #endif
            #endfor
        #endif

        if (containerChains):
            for chain in (containerChains):
                chainName = chain.split("(")[0]

                if (chainName == "WCInboundDefault"):
                    continue
                elif (chainName != "WCInboudDefaultSecure"):
                    continue
                else:
                    AdminTask.deleteChain(chain, '[-deleteChannels true]')
                #endif
            #endfor
        #endif

        if (targetTCPChannels):
            for tcpChannel in (targetTCPChannels):
                tcpName = tcpChannel.split("(")[0]

                if (tcpName == "TCP_2"):
                    AdminConfig.modify(tcpChannel, '[[maxOpenConnections "50"]]')
                else:
                    continue
                #endif
            #endfor
        #endif

        if (targetHTTPChannels):
            for httpChannel in (targetHTTPChannels):
                httpName = httpChannel.split("(")[0]

                if (httpName == "HTTP_2"):
                    AdminConfig.modify(httpChannel, '[[maximumPersistentRequests "-1"] [persistentTimeout "300"] [enableLogging "true"]]')
                    AdminConfig.create('Property', httpChannel, '[[validationExpression ""] [name "RemoveServerHeader"] [description ""] [value "true"] [required "false"]]')
                else:
                    continue
                #endif
            #endfor
        #endif

        saveWorkspaceChanges()
        syncAllNodes(nodeList)

        print ("Completed configuration for deployment manager " + serverName + ".")
    else:
        print ("Deployment manager not found with server name " + serverName)
    #endif
#enddef

def printHelp():
    print ("This script configures a deployment manager for optimal settings.")
    print ("Execution: wsadmin.sh -lang jython -f configureDeploymentManager.py <runAsUser> <runAsGroup>")
    print ("<runAsUser> - The operating system username to run the process as. The user must exist on the local machine. Optional, if not provided no user is configured.")
    print ("<runAsGroup> - The operating system group to run the process as. The group must exist on the local machine. Optional, if not provided no group is configured.")
#enddef

##################################
# main
#################################


if (len(sys.argv) == 1):
    configureDeploymentManager(sys.argv[0])
elif (len(sys.argv) == 2):
    configureDeploymentManager(sys.argv[0], sys.argv[1])
else:
    configureDeploymentManager()
#endif
