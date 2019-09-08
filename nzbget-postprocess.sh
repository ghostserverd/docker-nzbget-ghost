#!/bin/sh -xu

###########################################
### NZBGET POST-PROCESSING SCRIPT       ###

# FileBot postprocessing script
#
# This script triggers the FileBot container via curl

### NZBGET POST-PROCESSING SCRIPT       ###
###########################################

# Input Parameters
ARG_PATH="$NZBPP_DIRECTORY"
ARG_NAME="$NZBPP_NZBNAME"
ARG_LABEL="$NZBPP_CATEGORY"

# Configuration
CONFIG_OUTPUT="$HOME/Media"
FILEBOT_PORT=${FILEBOT_PORT:-7676}

FILEBOT_CMD=$(\
echo curl \
    --data-urlencode name=\"${ARG_NAME}\" \
    --data-urlencode path=\"${ARG_PATH}\" \
    --data-urlencode label=\"${ARG_LABEL}\" \
    http://filebot:${FILEBOT_PORT}/amc)

echo $FILEBOT_CMD >> /config/filebot.log
$FILEBOT_CMD

# NZBGet Exit Codes
if [ $? = 0 ]; then
	exit 93 # SUCCESS
else
	exit 94 # FAILURE
fi
