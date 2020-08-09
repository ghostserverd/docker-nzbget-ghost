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
IGNORE_LABELS=${IGNORE_LABELS:-""}

SONARR_CATEGORY=${SONARR_CATEGORY:-"sonarr"}
SONARR_PORT=${SONARR_PORT:-""}
SONARR_API_KEY=${SONARR_API_KEY:-""}

RADARR_CATEGORY=${RADARR_CATEGORY:-"radarr"}
RADARR_PORT=${RADARR_PORT:-""}
RADARR_API_KEY=${RADARR_API_KEY:-""}

LIDARR_CATEGORY=${LIDARR_CATEGORY:-"lidarr"}
LIDARR_PORT=${LIDARR_PORT:-""}
LIDARR_API_KEY=${LIDARR_API_KEY:-""}

FILEBOT_LABEL=$ARG_LABEL
case $FILEBOT_LABEL in
    $SONARR_CATEGORY)
        FILEBOT_LABEL="tv"
    ;;

    $RADARR_CATEGORY)
        FILEBOT_LABEL="movie"
    ;;

    $LIDARR_CATEGORY)
        FILEBOT_LABEL="music"
    ;;
esac

# exit with success if label should not be processed by filebot
[ ! -z "$IGNORE_LABELS" ] && case $FILEBOT_LABEL in $IGNORE_LABELS) exit 93;; esac

FILEBOT_CMD=$(\
echo curl \
    --data-urlencode name=\"${ARG_NAME}\" \
    --data-urlencode path=\"${ARG_PATH}\" \
    --data-urlencode label=\"${FILEBOT_LABEL}\" \
    http://filebot:${FILEBOT_PORT}/amc)

echo $FILEBOT_CMD >> /config/filebot.log
eval $FILEBOT_CMD

REFRESH_NAME=""
REFRESH_URL=""

case $ARG_LABEL in
    $SONARR_CATEGORY)
        if [ $SONARR_PORT != "" ] && [ $SONARR_API_KEY != "" ]; then
            REFRESH_NAME="RescanSeries"
            REFRESH_URL="http://sonarr:${SONARR_PORT}/api/command?apikey=${SONARR_API_KEY}"
	fi
    ;;

    $RADARR_CATEGORY)
        if [ $RADARR_PORT != "" ] && [ $RADARR_API_KEY != "" ]; then
            REFRESH_NAME="RescanMovie"
            REFRESH_URL="http://radarr:${RADARR_PORT}/api/command?apikey=${RADARR_API_KEY}"
        fi
    ;;

    $LIDARR_CATEGORY)
        if [ $LIDARR_PORT != "" ] && [ $LIDARR_API_KEY != "" ]; then
            REFRESH_NAME="RescanArtist"
            REFRESH_URL="http://lidarr:${LIDARR_PORT}/api/v1/command?apikey=${LIDARR_API_KEY}"
        fi
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
