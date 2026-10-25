# Ubuntu 16.04 Modern Build Environment

Docker images based on Ubuntu 16.04 with modern build tools for GitHub Actions and CI/CD.

## Available Images

- `electronstudio/ubuntu16-modern:latest` - 64-bit (x86_64)
- `electronstudio/ubuntu16-modern:i386` - 32-bit (x86)

## Included Tools

- **Node.js v26.10.0** - Modern JavaScript runtime (unofficial build compatible with glibc 2.17). v26.10.0 is the last release shipping a `linux-x64-glibc-217` tarball; v26.11.0+ dropped it.
- **Git v2.47.1** - Modern Git (from the git-core PPA)
- **CMake v3.31.12** - Modern CMake build system (from Kitware)
- **OpenJDK 8** - Java development kit
- **Multiple Python versions** - Python 3.15.0, 3.14.9, 3.13.17, 3.12.15, 3.11.17, 3.10.22, 3.9.25, 3.8.20, 3.7.17 (compiled from source with PGO optimizations). See [Python caveats](#python-caveats).
- **PyPy versions** - PyPy 3.10 v7.3.19, PyPy 3.11 v7.3.20 (high-performance Python implementations)
- **Go v1.26.10** - Go programming language (pre-built binary from golang.org)
- **OpenSSL 1.1.1zh** - Built from source (kzalewski fork with backported security fixes)
- **SDL v2.32.10** - Static library for multimedia, games, and cross-platform development (compiled from source)
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
          python3.15 --version
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
          python3.15 --version
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

## Python caveats

### `sqlite3` is unavailable on Python 3.13, 3.14 and 3.15

CPython 3.13+ requires SQLite **>= 3.15.2** to build `_sqlite3`. Ubuntu 16.04 ships
SQLite **3.11.0**, so `configure` silently skips the module. The result is that
`import sqlite3` raises `ModuleNotFoundError: No module named '_sqlite3'` on
3.13/3.14/3.15, while Python 3.12 and earlier are unaffected.

If you need `sqlite3`, use **Python 3.12 or older**. Do not assume a newer Python
gives you more working stdlib modules on this base image.

### stdlib modules that *are* available

`_ssl` (with a working CA trust store, see below), `_lzma`, `_bz2`, `_uuid`,
`_decimal` (C implementation), `_tkinter` (Tk 8.6), `_ctypes`, `_hashlib`,
`zlib`, `readline`, `_curses`, `_gdbm`, `pyexpat`.

### HTTPS / certificate verification

OpenSSL is installed to `/usr/local/ssl`, so CPython's compiled-in default CA
paths (`/usr/local/ssl/cert.pem`, `/usr/local/ssl/certs/`) do not exist. The
image symlinks the distro CA bundle into those locations, so `urllib`,
`requests`, `pip` and friends verify TLS certificates out of the box on every
installed Python version.

If you replace or extend the CA trust store, either install into
`/etc/ssl/certs/ca-certificates.crt` (the symlink follows it) or set
`SSL_CERT_FILE`/`SSL_CERT_DIR` explicitly.

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
| Node.js | v26.10.0 | v26.10.0 |
| Git | v2.47.1 | v2.47.1 |
| CMake | v3.31.12 | v3.31.12 |
| OpenJDK | 8 | 8 |
| OpenSSL | 1.1.1zh | 1.1.1zh |
| Python | 3.15.0, 3.14.9, 3.13.17, 3.12.15, 3.11.17, 3.10.22, 3.9.25, 3.8.20, 3.7.17 | same |
| PyPy | 3.10 v7.3.19, 3.11 v7.3.20 | 3.10 v7.3.19, 3.11 v7.3.20 |
| Go | v1.26.10 | v1.26.10 |
| SDL | v2.32.10 | v2.32.10 |
| `sqlite3` module | only on Python ≤ 3.12 | only on Python ≤ 3.12 |
| All dev libraries | ✅ | ✅ |

## License

MIT License - see LICENSE file for details.

## Contributing

1. Fork this repository
2. Make your changes to the Dockerfiles
3. Test locally
4. Submit a pull request

Changes to Dockerfiles will automatically trigger new image builds via GitHub Actions.