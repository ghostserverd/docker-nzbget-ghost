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
SONARR_CATEGORY=${SONARR_CATEGORY:-"sonarr"}
RADARR_CATEGORY=${RADARR_CATEGORY:-"radarr"}

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
eval $FILEBOT_CMD

REFRESH_NAME=""
REFRESH_URL=""

case $ARG_LABEL in
    $SONARR_CATEGORY)
        REFRESH_NAME="RescanSeries"
        REFRESH_URL="http://sonarr:${SONARR_PORT}/api/command?apikey=${SONARR_API_KEY}"
    ;;

    $RADARR_CATEGORY)
        REFRESH_NAME="RescanMovie"
        REFRESH_URL="http://radarr:${RADARR_PORT}/api/command?apikey=${RADARR_API_KEY}"
    ;;
esac

if [ $REFRESH_URL != "" ]; then
    REFRESH_CMD=$(\
        echo curl \
        -d \"{\\\"name\\\":\\\"${REFRESH_NAME}\\\"}\" \
        -H \"Content-Type: application/json\" \
        -X POST \
        ${REFRESH_URL})
    echo $REFRESH_CMD >> /config/pvr-refresh.log
    eval $REFRESH_CMD
fi

# NZBGet Exit Codes
if [ $? = 0 ]; then
	exit 93 # SUCCESS
else
	exit 94 # FAILURE
fi
