#!/bin/sh -xu

# Input Parameters
ARG_PATH="$NZBPP_DIRECTORY"
ARG_NAME="$NZBPP_NZBNAME"
ARG_LABEL="$NZBPP_CATEGORY"

# Configuration
CONFIG_OUTPUT="$HOME/Media"
FILEBOT_PORT=${FILEBOT_PORT:-7676}

curl \
    --data-urlencode "name=${ARG_NAME}" \
    --data-urlencode "path=${ARG_PATH}" \
    --data-urlencode "label=${ARG_LABEL}" \
    http://filebot:${FILEBOT_PORT}/amc

# NZBGet Exit Codes
if [ $? = 0 ]; then
	exit 93 # SUCCESS
else
	exit 94 # FAILURE
fi
