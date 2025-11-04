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

# Compile and install OpenSSL 1.1.1 from source
RUN wget https://github.com/openssl/openssl/releases/download/OpenSSL_1_1_1w/openssl-1.1.1w.tar.gz \
    && tar -xzf openssl-1.1.1w.tar.gz \
    && cd openssl-1.1.1w \
    && ./config \
    && make -j$(nproc) \
    && make install_sw install_ssldirs \
    && ldconfig \
    && cd .. && rm -rf openssl-1.1.1*

# Install Node.js 20 (unofficial build compatible with glibc 2.17)
RUN curl -fsSL https://unofficial-builds.nodejs.org/download/release/v20.18.1/node-v20.18.1-linux-x64-glibc-217.tar.gz | tar -xz -C /usr/local --strip-components=1

# Install newer Git (via PPA)
RUN add-apt-repository ppa:git-core/ppa \
    && apt-get update \
    && apt-get install -y git \
    && rm -rf /var/lib/apt/lists/*

# Install modern CMake
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc | apt-key add - \
    && echo 'deb https://apt.kitware.com/ubuntu/ xenial main' | tee /etc/apt/sources.list.d/kitware.list \
    && apt-get update \
    && apt-get install -y cmake \
    && rm -rf /var/lib/apt/lists/*

# Install multiple Python versions with SSL support
ARG PYTHON_VERSIONS="3.14.0 3.13.9 3.12.9 3.11.14 3.10.19 3.9.25 3.8.20 3.7.17"
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
