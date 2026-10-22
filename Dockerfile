FROM ubuntu:16.04

# Update package lists and install basic dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    build-essential \
    ca-certificates \
    unzip \
    pkg-config \
    libasound2-dev \
    mesa-common-dev \
    libx11-dev \
    libxrandr-dev \
    libxi-dev \
    xorg-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libwayland-dev \
    libxkbcommon-dev \
    openjdk-8-jdk \
    software-properties-common \
    apt-transport-https \
    gnupg \
    lsb-release \
    libgles2-mesa-dev \
    zlib1g-dev libncurses-dev libgdbm-dev libnss3-dev libreadline6-dev libffi-dev libsqlite3-dev libbz2-dev libgbm-dev \
    && rm -rf /var/lib/apt/lists/*

# Compile and install OpenSSL 1.1.1 from source (kzalewski fork: 1.1.1zh with backported security fixes)
RUN wget https://github.com/kzalewski/openssl-1.1.1/archive/refs/tags/1.1.1zh.tar.gz -O openssl-1.1.1zh.tar.gz \
    && tar -xzf openssl-1.1.1zh.tar.gz \
    && cd openssl-1.1.1-1.1.1zh \
    && ./config \
    && make -j$(nproc) \
    && make install_sw install_ssldirs \
    && ldconfig \
    && cd .. && rm -rf openssl-1.1.1*

# Install Node.js 26 (unofficial build compatible with glibc 2.17)
# NOTE: v26.10.0 is the last release shipping a linux-x64-glibc-217 build; v26.11.0+ dropped it.
RUN curl -fsSL https://unofficial-builds.nodejs.org/download/release/v26.10.0/node-v26.10.0-linux-x64-glibc-217.tar.xz | tar -xJ -C /usr/local --strip-components=1

# Install newer Git (via PPA)
RUN add-apt-repository ppa:git-core/ppa \
    && apt-get update \
    && apt-get install -y git \
    && rm -rf /var/lib/apt/lists/*

# Install modern CMake
RUN wget https://github.com/Kitware/CMake/releases/download/v3.31.12/cmake-3.31.12-linux-x86_64.tar.gz \
    && tar xvfz cmake-3.31.12-linux-x86_64.tar.gz \
    && cp -r cmake-3.31.12-linux-x86_64/* /usr/

# Install Go
ARG GO_VERSION="1.26.10"
RUN wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz \
    && rm go${GO_VERSION}.linux-amd64.tar.gz
ENV PATH=$PATH:/usr/local/go/bin

# Install multiple Python versions with SSL support
ARG PYTHON_VERSIONS="3.15.0 3.14.9 3.13.17 3.12.15 3.11.17 3.10.22 3.9.25 3.8.20 3.7.17"
RUN for version in $PYTHON_VERSIONS; do \
        wget https://www.python.org/ftp/python/$version/Python-$version.tgz && \
        tar -xf Python-$version.tgz && \
        cd Python-$version && \
        ./configure --enable-optimizations  && \
        make -j$(nproc) && \
        make altinstall && \
        cd .. && \
        rm -rf Python-$version*; \
    done

# Install SDL
ARG SDL_VERSION="2.32.10"
RUN wget https://github.com/libsdl-org/SDL/archive/refs/tags/release-$SDL_VERSION.tar.gz \
    && tar xvfz release-$SDL_VERSION.tar.gz \
    && mkdir build \
    && cd build \
    && cmake ../SDL-release-$SDL_VERSION -DSDL_SHARED=OFF -DSDL_STATIC=ON -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_BUILD_TYPE=Release \
    && cmake --build . --config Release \
    && cmake --install . \
    && cd .. && rm -rf build SDL-release-$SDL_VERSION release-$SDL_VERSION.tar.gz

# Install PyPy 3.10 and 3.11
RUN wget https://downloads.python.org/pypy/pypy3.10-v7.3.19-linux64.tar.bz2 \
    && wget https://downloads.python.org/pypy/pypy3.11-v7.3.20-linux64.tar.bz2 \
    && tar -xjf pypy3.10-v7.3.19-linux64.tar.bz2 -C /opt \
    && tar -xjf pypy3.11-v7.3.20-linux64.tar.bz2 -C /opt \
    && ln -s /opt/pypy3.10-v7.3.19-linux64/bin/pypy3 /usr/local/bin/pypy3.10 \
    && ln -s /opt/pypy3.11-v7.3.20-linux64/bin/pypy3 /usr/local/bin/pypy3.11 \
    && /usr/local/bin/pypy3.10 -m ensurepip \
    && /usr/local/bin/pypy3.11 -m ensurepip \
    && ln -s /opt/pypy3.10-v7.3.19-linux64/bin/pip3 /usr/local/bin/pip-pypy3.10 \
    && ln -s /opt/pypy3.11-v7.3.20-linux64/bin/pip3 /usr/local/bin/pip-pypy3.11 \
    && rm pypy3.10-v7.3.19-linux64.tar.bz2 pypy3.11-v7.3.20-linux64.tar.bz2

# Set working directory
WORKDIR /workspace

# Default command
CMD ["/bin/bash"]
