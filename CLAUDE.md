# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Docker image project that creates Ubuntu 16.04-based containers with modern build tools for CI/CD and GitHub Actions. The project builds two architectures:
- 64-bit (x86_64) - main Dockerfile
- 32-bit (i386) - Dockerfile.i386

## Build Commands

### Docker Images
```bash
# Build 64-bit image
docker build -t ubuntu16-modern:latest .

# Build 32-bit image  
docker build --platform=linux/386 -f Dockerfile.i386 -t ubuntu16-modern:i386 .
```

### Testing Locally
```bash
# Run 64-bit container
docker run -it -v $(pwd):/workspace electronstudio/ubuntu16-modern:latest

# Run 32-bit container
docker run -it -v $(pwd):/workspace electronstudio/ubuntu16-modern:i386

# With X11 forwarding for GUI applications
docker run -it \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -e DISPLAY=$DISPLAY \
  -v $(pwd):/workspace \
  electronstudio/ubuntu16-modern:latest
```

## Architecture

### Container Images
- **Base**: Ubuntu 16.04 (xenial) for compatibility with older systems
- **Node.js**: v20.18.1 (unofficial builds compatible with glibc 2.17)
- **Git**: v2.47.1 (from git-core PPA)
- **CMake**: v3.20.5 (from Kitware repositories)
- **Java**: OpenJDK 8
- **Docker CLI**: Included in 64-bit only (not available for 32-bit)

### Key Differences Between Dockerfiles
- `Dockerfile`: 64-bit build with Docker CLI support
- `Dockerfile.i386`: 32-bit build, skips Docker CLI installation
- Both include the same development libraries and tools

### CI/CD Integration
The project uses GitHub Actions (.github/workflows/docker.yml) to automatically build and push images to Docker Hub when changes are made to the main branch. The workflow builds both architectures in parallel using a matrix strategy.

### Development Libraries Included
- OpenGL (Mesa)
- X11 windowing system
- Audio (ALSA)
- Wayland
- SSL/TLS
- Build essentials (GCC, Make)

## Published Images
- `electronstudio/ubuntu16-modern:latest` - 64-bit
- `electronstudio/ubuntu16-modern:i386` - 32-bit