##############################################################################
# Source: https://github.com/linuxserver/docker-baseimage-alpine-python3/blob/master/Dockerfile
# Simply using it as a baseimage fails:
# - installing g++ fails (baseimage already installs it and purges it afterwards, so let's keep it)
# - installing python 3.7.3 because that is what py3-libtorrent-rasterbar requires (doesn't work with 3.6.8)
FROM lsiobase/alpine:3.10

RUN apk --no-cache add \
    ca-certificates \
    python3

RUN pip3 install flexget

##############################################################################
# Here starts the usual changes compared to baseimage.

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS="2"

# Set python to use utf-8 rather than ascii.
# Also, for python3: https://bugs.python.org/issue19846
ENV LANG C.UTF-8

# Copy local files.
COPY etc/ /etc
RUN chmod -v +x \
    /etc/cont-init.d/*  \
    /etc/services.d/*/run

# Ports and volumes.
EXPOSE 5050/tcp

# Flexget looks for config.yml automatically inside:
# /root/.flexget, /root/.config/flexget
# Since the uid/gid for user abc can be changed on the fly, set 777.
RUN CONFIG_SYMLINK_DIR=/root \
    && ln -s /config "$CONFIG_SYMLINK_DIR/.flexget" \
    && chmod 777 "$CONFIG_SYMLINK_DIR/" \
    && chmod 777 "$CONFIG_SYMLINK_DIR/.flexget/"
