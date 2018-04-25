#==============================================================================
#
#          FILE:  parseConfigurationFile.py
#         USAGE:  python parseConfigurationFile.py
#     ARGUMENTS:  config-file section
#   DESCRIPTION:  Provides the values of a given configuration file/section
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

import os;

from sys import argv;
from sys import _getframe;
from os import path;
from os import access;
from os import environ;
from subprocess import Popen;
from inspect import currentframe;
from inspect import getframeinfo;
from ConfigParser import SafeConfigParser;

DEBUG_ENABLED = environ["ENABLE_DEBUG"];

def getSectionVariables(iniFileName, sectionName):
    if (DEBUG_ENABLED):
        Popen(["bash", "-c", ". " + environ["HOME"] + "/.lib/logger.sh; writeLogEntry DEBUG " + getframeinfo(currentframe()).function + " " + getframeinfo(currentframe()).filename + " " + str(getframeinfo(currentframe()).lineno) + " \"" + iniFileName + "\""]);
        Popen(["bash", "-c", ". " + environ["HOME"] + "/.lib/logger.sh; writeLogEntry DEBUG " + getframeinfo(currentframe()).function + " " + getframeinfo(currentframe()).filename + " " + str(getframeinfo(currentframe()).lineno) + " \"" + sectionName + "\""]);

    if not (path.isfile(iniFileName)) or not (access(iniFileName, os.R_OK)):
        Popen(["bash", "-c", ". " + environ["HOME"] + "/.lib/logger.sh; writeLogEntry ERROR " + getframeinfo(currentframe()).function + " " + getframeinfo(currentframe()).filename + " " + str(getframeinfo(currentframe()).lineno) + " \"The provided file: " + iniFileName + " does not exist or cannot be read."]);
        Popen(["bash", "-c", ". " + environ["HOME"] + "/.lib/logger.sh; writeLogEntry STDERR " + getframeinfo(currentframe()).function + " " + getframeinfo(currentframe()).filename + " " + str(getframeinfo(currentframe()).lineno) + " \"The provided file: " + iniFileName + " does not exist or cannot be read."]);

        return 1;

    config = SafeConfigParser();

    if (DEBUG_ENABLED):
        Popen(["bash", "-c", ". " + environ["HOME"] + "/.lib/logger.sh; writeLogEntry DEBUG " + getframeinfo(currentframe()).function + " " + getframeinfo(currentframe()).filename + " " + str(getframeinfo(currentframe()).lineno) + " \"" + iniFileName + "\""]);
        Popen(["bash", "-c", ". " + environ["HOME"] + "/.lib/logger.sh; writeLogEntry DEBUG " + getframeinfo(currentframe()).function + " " + getframeinfo(currentframe()).filename + " " + str(getframeinfo(currentframe()).lineno) + " \"" + sectionName + "\""]);

    config.read(iniFileName);

    for key, val in config.items(sectionName):
        if (DEBUG_ENABLED):
            Popen(["bash", "-c", ". " + environ["HOME"] + "/.lib/logger.sh; writeLogEntry DEBUG " + getframeinfo(currentframe()).function + " " + getframeinfo(currentframe()).filename + " " + str(getframeinfo(currentframe()).lineno) + " \"Key: " + key + ", Value: " + val + "\""]);

        print "%s:%s" % (key.rstrip(), val.rstrip());

    return 0;

def printHelp():
    print "Returns values from a given configuration file (INI) and provided section thereof";
    print "Format is parseConfigurationFile iniFileName sectionName";

##################################
# main
#################################
if (len(argv) == 2):
    getSectionVariables(argv[0], argv[1]);
elif (len(argv) == 3):
    getSectionVariables(argv[1], argv[2]);
else:
    printHelp();
