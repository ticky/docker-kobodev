# A Docker Image for Kobo Development

[![](https://images.microbadger.com/badges/image/ticky/kobodev.svg)](https://microbadger.com/images/ticky/kobodev)
[![](https://img.shields.io/docker/pulls/ticky/kobodev.svg?maxAge=604800)](https://hub.docker.com/r/ticky/kobodev/)

Cross-compile your Kobo projects inside a Docker container.

## Quick Start

Run this command in your project's root folder to build it inside a Docker container:

```bash
docker run -it --rm -v "$PWD:/src" ticky/kobodev make
```

This will mount the current folder to `/src` in the container and then run `make` inside `/src`. You may execute other commands, of course.

Omit the command to get a login shell (`/bin/bash`) in the running container:

```bash
docker run -it --rm -v "$PWD:/src" ticky/kobodev
```

## Continuous Integration

With the Docker image in hand, you can also build and test your Kobo applications on CI platforms. Here's an example configuration for Travis CI:

```yaml
# .travis.yml
language: c

sudo: required

services:
  - docker

script: docker run -it --rm -v "$PWD:/src" ticky/kobodev make test
```

## Origin

This project is forked from [Mathias Lafeldt](https://twitter.com/mlafeldt)'s [docker-ps2dev](https://github.com/mlafeldt/docker-ps2dev).
