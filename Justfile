SSH_TARGET := "do"
IMAGE_FILE := "bobby_bot.image.bin"

default:

build:
  #!/usr/bin/env bash
  set -euxo pipefail
  source .env.prod
  podman build . -t celeo/bobby_bot --build-arg DISCORD_TOKEN=${DISCORD_TOKEN}

image-save:
  rm -f {{IMAGE_FILE}}
  podman image save --output {{IMAGE_FILE}} celeo/bobby_bot

deploy: build image-save
  scp {{IMAGE_FILE}} {{SSH_TARGET}}:/srv/bobby_bot.image
