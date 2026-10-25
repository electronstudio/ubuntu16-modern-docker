# Ubuntu 16.04 Modern Build Environment

Docker images based on Ubuntu 16.04 with modern build tools for GitHub Actions and CI/CD.

## Available Images

- `electronstudio/ubuntu16-modern:latest` - 64-bit (x86_64)
- `electronstudio/ubuntu16-modern:i386` - 32-bit (x86)

Both tags are also published as `<tag>-<sha>` for pinning.

## Included Tools

| Tool | Version |
|------|---------|
| Node.js | **v26.10.0** on 64-bit (unofficial glibc-2.17 build), **v20.18.1** on 32-bit |
| Git | v2.47.1 (git-core PPA) |
| CMake | v3.31.12 (Kitware) |
| Go | v1.26.10 (official binary) |
| OpenJDK | 8 (1.8.0_292) |
| OpenSSL | 1.1.1zh (kzalewski fork, backported security fixes) |
| SDL | v2.32.10 (static, compiled from source) |
| GCC | 5.4.0 (xenial default) |
| CPython | 3.7 – 3.15 (9 versions, compiled from source) |
| PyPy | 3.10, 3.11, 3.12 |

Development libraries: OpenGL (Mesa/GLU/GLES), X11 (+Xrandr/Xi/xorg), audio (ALSA), Wayland
(+xkbcommon), SSL/TLS, zlib, ncurses, gdbm, readline, libffi, sqlite3, bz2, **lzma**, gbm.

### Python interpreters

All interpreters are on `PATH` under versioned names:

| Command | Version | Notes |
|---------|---------|-------|
| `python3.15` … `python3.7` | 3.15.0, 3.14.9, 3.13.17, 3.12.15, 3.11.17, 3.10.22, 3.9.25, 3.8.20, 3.7.17 | `make altinstall`, so `python3` stays the system 3.5 |
| `pip` for each | `python3.X -m pip` | via `ensurepip` |
| `pypy3.10` | PyPy 3.10.16 (v7.3.19) | official binary |
| `pypy3.11` | PyPy 3.11.13 (v7.3.20) | official binary |
| `pypy3.12` | PyPy 3.12.15 (v8.0.1) | **built from source** (see below) |
| `pip-pypy3.10`, `pip-pypy3.11`, `pip-pypy3.12` | matching pip | |

`pypy3.12` is translated from source because no official PyPy 3.12 build runs on xenial: PyPy ≥ 8.0
is built in `manylinux_2_28` and requires glibc ≥ 2.27, while Ubuntu 16.04 ships glibc 2.23.

## Known Limitations

- **`sqlite3` is unavailable on `python3.13`/`3.14`/`3.15` and on `pypy3.12`.** Current CPython
  requires SQLite ≥ 3.15.2 (PyPy needs newer still), and xenial ships SQLite 3.11.0. Older
  `python3.7`–`3.12` and `pypy3.10`/`3.11` have a working `sqlite3`.
- **`tkinter` is unavailable** for all interpreters (`tk-dev` is not installed).
- **`pypy3.12` lacks the `curses` cffi module** (no `libncursesw` development symlink).
- `python3.7`–`3.9` still ship the `test` package and `libpython3.x.a`, because those configure
  scripts predate `--disable-test-modules` / `--without-static-libpython` (the flags are passed
  anyway and are ignored with a warning).

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
          pypy3.12 --version
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

# With X11 forwarding for GUI applications
docker run -it \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -e DISPLAY=$DISPLAY \
  -v $(pwd):/workspace \
  electronstudio/ubuntu16-modern:latest
```

### TLS note

OpenSSL 1.1.1 is built with `--openssldir=/etc/ssl`, so anything linked against it — including all
the CPython builds — uses the distro CA bundle (`/etc/ssl/certs/ca-certificates.crt`).
`ssl`/`urllib` verify certificates out of the box; no `SSL_CERT_FILE` needed.

## Why Ubuntu 16.04?

Ubuntu 16.04 provides compatibility with older systems while still supporting modern build tools through:
- PPAs for newer Git versions
- Unofficial Node.js builds for newer JavaScript features
- Kitware repositories for modern CMake
- Source builds of OpenSSL 1.1.1, CPython 3.7–3.15 and PyPy 3.12 (no compatible binaries exist)

## Building from Source

```bash
# Build 64-bit image
docker build -t ubuntu16-modern:latest .

# Build 32-bit image
docker build --platform=linux/386 -f Dockerfile.i386 -t ubuntu16-modern:i386 .
```

### Build arguments

| Argument | Default | Purpose |
|----------|---------|---------|
| `PYTHON_VERSION_3_15` … `PYTHON_VERSION_3_7` | 3.15.0 … 3.7.17 | Pin individual CPython versions (one layer each) |
| `PYTHON_ENABLE_PGO` | `0` | `1` builds CPython with `--enable-optimizations` (PGO): ~2× compile time per version, ~10–20% faster interpreter. CI sets `1` |
| `PYPY3_12_VERSION` | `8.0.1` | PyPy 3.12 source release to translate |
| `PYPY2_7_VERSION` | `7.3.19` | PyPy 2.7 binary used as the RPython host interpreter |
| `GO_VERSION` | `1.26.10` | Go release |
| `SDL_VERSION` | `2.32.10` | SDL2 release |

### Build cost

Measured on an 8-core machine:

| Stage | Time |
|-------|------|
| apt / OpenSSL / Node / git / CMake / Go | ~1.5 min |
| each CPython version (PGO off) | 60–90 s → ~11 min for all 9 |
| each CPython version (PGO on) | ~2× the above |
| SDL + PyPy 3.10/3.11 | ~50 s |
| **PyPy 3.12 from source** | **~23 min, ~4.5 GB RAM** |

Final images are ~3.6 GB (64-bit) and ~3.3 GB (32-bit). Python versions are built one per layer, so
bumping a single version only rebuilds that version.

## Differences Between Architectures

| Feature | 64-bit | 32-bit |
|---------|--------|--------|
| Node.js | v26.10.0 | v20.18.1 |
| Git | v2.47.1 | v2.47.1 |
| CMake | v3.31.12 | v3.31.12 |
| OpenJDK | 8 | 8 |
| OpenSSL | 1.1.1zh | 1.1.1zh |
| CPython | 3.7 – 3.15 | 3.7 – 3.15 |
| PyPy | 3.10, 3.11, 3.12 | 3.10, 3.11, 3.12 |
| Go | v1.26.10 | v1.26.10 |
| SDL | v2.32.10 | v2.32.10 |
| All dev libraries | ✅ | ✅ |

## License

MIT License - see LICENSE file for details.

## Contributing

1. Fork this repository
2. Make your changes to the Dockerfiles
3. Test locally
4. Submit a pull request

Changes to Dockerfiles will automatically trigger new image builds via GitHub Actions.
