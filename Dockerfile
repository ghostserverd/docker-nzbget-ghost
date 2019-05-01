FROM linuxserver/nzbget

# add ghost config file
COPY root/ /

WORKDIR /usr/local/bin

# add default post process
COPY nzbget-postprocess.sh nzbget-postprocess.sh
RUN chmod +rx nzbget-postprocess.sh
