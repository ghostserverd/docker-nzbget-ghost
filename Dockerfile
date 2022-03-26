FROM linuxserver/nzbget:testing-version-v21.2-r2333

# add ghost config file
COPY root/ /

WORKDIR /usr/local/bin

# add default post process
COPY nzbget-postprocess.sh nzbget-postprocess.sh
COPY nzbget.conf nzbget.conf
RUN chmod +rx nzbget-postprocess.sh
