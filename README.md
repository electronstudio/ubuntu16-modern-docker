# Ubuntu 16.04 Modern Build Environment

Docker images based on Ubuntu 16.04 with modern build tools for GitHub Actions and CI/CD.

## Available Images

- `electronstudio/ubuntu16-modern:latest` - 64-bit (x86_64)
- `electronstudio/ubuntu16-modern:i386` - 32-bit (x86)

## Included Tools

- **Node.js v20.18.1** - Modern JavaScript runtime (unofficial builds compatible with glibc 2.17)
- **Git v2.47.1** - Latest Git version
- **CMake v3.20.5** - Modern CMake build system
- **OpenJDK 8** - Java development kit
- **Build essentials** - GCC, Make, and compilation tools
- **Development libraries**:
  - OpenGL (libgl1-mesa-dev, libglu1-mesa-dev)
  - X11 (libx11-dev, libxrandr-dev, libxi-dev)
  - Audio (libasound2-dev)
  - Wayland (libwayland-dev)
  - SSL (libssl-dev)
  - And more...

## Usage

### In GitHub Actions

```yaml
name: Build
on: [push]

jobs:
  build-64bit:
    runs-on: ubuntu-latest
    container: electronstudio/ubuntu16-modern:latest
    steps:
      - uses: actions/checkout@v4
      - name: Build project
        run: |
          node --version
          java -version
          # Your build commands here

  build-32bit:
    runs-on: ubuntu-latest
    container: electronstudio/ubuntu16-modern:i386
    steps:
      - uses: actions/checkout@v4
      - name: Build project
        run: |
          node --version
          java -version
          # Your build commands here
```

### Local Development

```bash
# Run 64-bit container
docker run -it -v $(pwd):/workspace electronstudio/ubuntu16-modern:latest

# Run 32-bit container
docker run -it -v $(pwd):/workspace electronstudio/ubuntu16-modern:i386

# With X11 forwarding (for GUI applications)
docker run -it \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -e DISPLAY=$DISPLAY \
  -v $(pwd):/workspace \
  electronstudio/ubuntu16-modern:latest
```

## Why Ubuntu 16.04?

Ubuntu 16.04 provides compatibility with older systems while still supporting modern build tools through:
- PPAs for newer Git versions
- Unofficial Node.js builds for newer JavaScript features
- Kitware repositories for modern CMake
- Backported development libraries

## Building from Source

```bash
# Build 64-bit image
docker build -t ubuntu16-modern:latest .

# Build 32-bit image
docker build --platform=linux/386 -f Dockerfile.i386 -t ubuntu16-modern:i386 .
```

## Differences Between Architectures

| Feature | 64-bit | 32-bit |
|---------|--------|--------|
| Node.js | v20.18.1 | v20.18.1 |
| Git | v2.47.1 | v2.47.1 |
| CMake | v3.20.5 | v3.20.5 |
| OpenJDK | 8 | 8 |
| Docker CLI | ✅ | ❌ (not available) |
| All dev libraries | ✅ | ✅ |

## License

MIT License - see LICENSE file for details.

## Contributing

1. Fork this repository
2. Make your changes to the Dockerfiles
3. Test locally
4. Submit a pull request

Changes to Dockerfiles will automatically trigger new image builds via GitHub Actions.