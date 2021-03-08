default:

build:
  #!/usr/bin/env bash
  set -euxo pipefail
  source .env
  docker build . -t bobby_bot --build-arg DISCORD_TOKEN=${DISCORD_TOKEN}
