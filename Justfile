SSH_TARGET := "do"

default:

build:
  #!/usr/bin/env bash
  set -euxo pipefail
  source .env
  podman build . -t celeo/bobby_bot --build-arg DISCORD_TOKEN=${DISCORD_TOKEN}

image-save:
  podman image save --compress --output image.bin docker.io/celeo/bobby_bot

deploy: build image-save
  scp image.bin {{SSH_TARGET}}:/srv/
