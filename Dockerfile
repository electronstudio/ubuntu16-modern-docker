FROM ubuntu:16.04

# Update package lists and install basic dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    build-essential \
    ca-certificates \
    libssl-dev \
    unzip \
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
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20 (unofficial build compatible with glibc 2.17)
RUN curl -fsSL https://unofficial-builds.nodejs.org/download/release/v20.18.1/node-v20.18.1-linux-x64-glibc-217.tar.gz | tar -xz -C /usr/local --strip-components=1

# Skip Python installation for now

# Install newer Git (via PPA)
RUN add-apt-repository ppa:git-core/ppa \
    && apt-get update \
    && apt-get install -y git \
    && rm -rf /var/lib/apt/lists/*

# Install Docker CLI (for Docker-in-Docker scenarios)
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable" \
    && apt-get update \
    && apt-get install -y docker-ce-cli \
    && rm -rf /var/lib/apt/lists/*

# Install modern CMake
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc | apt-key add - \
    && echo 'deb https://apt.kitware.com/ubuntu/ xenial main' | tee /etc/apt/sources.list.d/kitware.list \
    && apt-get update \
    && apt-get install -y cmake \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Default command
CMD ["/bin/bash"]