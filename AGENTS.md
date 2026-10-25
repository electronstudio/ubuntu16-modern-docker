# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

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
- **Node.js**: v26.10.0 on 64-bit (unofficial build compatible with glibc 2.17; last release shipping a `linux-x64-glibc-217` tarball), v20.18.1 on 32-bit
- **Git**: v2.47.1 (from git-core PPA)
- **CMake**: v3.31.12 (from Kitware repositories)
- **Java**: OpenJDK 8
- **OpenSSL**: 1.1.1zh (kzalewski fork with backported security fixes)
- **Python**: Multiple versions (3.15.0, 3.14.9, 3.13.17, 3.12.15, 3.11.17, 3.10.22, 3.9.25, 3.8.20, 3.7.17) compiled from source
- **Go**: v1.26.10 (pre-built binary from golang.org)
- **PyPy**: High-performance Python implementations (3.10 v7.3.19, 3.11 v7.3.20)
- **SDL**: v2.32.10 static library for multimedia/game development

### Key Differences Between Dockerfiles
- `Dockerfile`: 64-bit build  
- `Dockerfile.i386`: 32-bit build
- Both include the same development libraries and tools

### Python build layers
Each Python version is pinned and built in its own layer via
`ARG PYTHON_VERSION_3_X` + `RUN /usr/local/lib/build-cpython "$PYTHON_VERSION_3_X"`,
so bumping one version only rebuilds that layer. The `/usr/local/lib/build-cpython`
helper (generated in the Dockerfile) chooses configure flags by version:
`--enable-optimizations` only when `--build-arg PYTHON_ENABLE_PGO=1` (default
`0` = off for fast local builds; CI passes `1`) and never on 3.7 (slow
full-test-suite PGO), plus `--disable-test-modules --without-static-libpython`
for every version (ignored with a warning by pre-3.10 configure scripts, which
don't know those options).

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
