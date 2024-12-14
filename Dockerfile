###########################################################################
# Fonts:
###########################################################################
FROM docker.io/node:18-slim AS fonts

WORKDIR /app

COPY ./assets/fonts ./

RUN yarn install && \
    node ./generate.js

###########################################################################
# Sprites:
###########################################################################
FROM docker.io/rust:slim AS sprites

RUN cargo install spreet

WORKDIR /data

RUN mkdir -p icons sprites

COPY assets/icons/ icons/

# osm-liberty
RUN cp -a icons/osm-liberty/svgs_not_in_iconset/. /tmp/osm-liberty && \
    cp -a icons/osm-liberty/svgs_iconset/. /tmp/osm-liberty && \
    mkdir -p sprites/osm-liberty && \
    spreet /tmp/osm-liberty sprites/osm-liberty/sprite && \
    spreet --retina /tmp/osm-liberty sprites/osm-liberty/sprite@2x && \
    rm -rf /tmp/osm-liberty

# mapbox-streets
RUN mkdir -p sprites/mapbox-streets && \
    spreet icons/mapbox-streets sprites/mapbox-streets/sprite && \
    spreet --retina icons/mapbox-streets sprites/mapbox-streets/sprite@2x

###########################################################################
# Deployment:
###########################################################################
FROM docker.io/bitnami/minideb:bookworm AS deploy

ARG TARGETARCH=amd64

ARG APP_NAME="TileServer GL Styles"
ARG APP_SLUG="tileserver-gl-styles"
ARG APP_VERSION="latest"

ENV APP_NAME="${APP_NAME}" \
    APP_SLUG="${APP_SLUG}" \
    APP_VERSION="${APP_VERSION}"

LABEL org.opencontainers.image.base.name="docker.io/bitnami/minideb:bookworm" \
      org.opencontainers.image.created="2024-12-13T00:38:06.649Z" \
      org.opencontainers.image.description="Application packaged by Broadcom, Inc." \
      org.opencontainers.image.documentation="https://github.com/laragis/tileserver-gl-styles/blob/main/README.md" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.ref.name="${APP_VERSION}-debian-12-r0" \
      org.opencontainers.image.source="https://github.com/laragis/tileserver-gl-styles" \
      org.opencontainers.image.title="tileserver-gl-styles" \
      org.opencontainers.image.version="${APP_VERSION}"


ENV OS_ARCH="${TARGETARCH}" \
    OS_FLAVOUR="debian-12" \
    OS_NAME="linux"

COPY prebuildfs /
SHELL ["/bin/bash", "-o", "errexit", "-o", "nounset", "-o", "pipefail", "-c"]

# Install required system packages and dependencies
# RUN install_packages build-essential ca-certificates curl git libbz2-1.0 libffi8 liblzma5 libncursesw6 libreadline8 libsqlite3-0 libsqlite3-dev libssl-dev libssl3 libtinfo6 pkg-config procps unzip wget zlib1g

RUN apt-get update && apt-get upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists /var/cache/apt/archives

RUN find / -perm /6000 -type f -exec chmod a-s {} \; || true

RUN sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS    90/' /etc/login.defs && \
    sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS    0/' /etc/login.defs && \
    sed -i 's/sha512/sha512 minlen=8/' /etc/pam.d/common-password

WORKDIR /data

COPY data/ ./
COPY --from=fonts /app/_output/ fonts/
COPY --from=sprites /data/sprites/ sprites/

USER 1001
