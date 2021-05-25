FROM emscripten/emsdk:2.0.21

RUN apt update
RUN DEBIAN_FRONTEND=noninteractive apt install -y \
    ninja-build \
    ruby \
    ca-certificates \
    build-essential \
    libssl-dev \
    libffi-dev \
    python \
    python-setuptools \
    python3 \
    python3-pip \
    python3-dev \
    gnupg \
    apt-utils \
    ccache \
    curl \
    git \
    sudo \
    wget \
    xz-utils

# COPY ./build /jsc/build
# RUN update-ca-certificates
# RUN chmod +x /jsc/build/gn/install-posix.sh && /jsc/build/gn/install-posix.sh

# Add user
ARG USERNAME=docker-jsc
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID -o $USERNAME && \
    useradd -m -u $UID -g $GID -o -s /bin/bash $USERNAME && \
    usermod -a -G sudo $USERNAME && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Get Chromium depot tools
RUN git clone --depth 1 https://chromium.googlesource.com/chromium/tools/depot_tools.git /opt/depot_tools && \
    chown -R $UID:$GID /opt/depot_tools
ENV PATH /opt/depot_tools:$PATH


# Create workdir
RUN mkdir /jsc && chown $UID:$GID /jsc

# Setup CCache
ENV CCACHE_DIR /jsc/.ccache
ENV CCACHE_BASEDIR /jsc/src
ENV CCACHE_SLOPPINESS include_file_mtime

# Run as user
USER $USERNAME

# Run fetch and gclient initially since this pulls a lot of data when run
# for the first time
RUN fetch --help > /dev/null && \
    gclient --help > /dev/null

# Set working directory
WORKDIR /jsc