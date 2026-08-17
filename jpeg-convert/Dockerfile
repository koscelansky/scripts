FROM debian:stable-slim

# keep apt's downloaded archives so the cache mounts below stay effective
RUN rm -f /etc/apt/apt.conf.d/docker-clean && \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

# install build tools and dependencies
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        wget \
        cmake \
        ninja-build \
        clang \
        libhwy-dev \
        liblcms2-dev \
        libpng-dev \
        libjpeg-dev \
        libgif-dev

COPY . /app

WORKDIR /app

RUN ./build-jpegli.sh
