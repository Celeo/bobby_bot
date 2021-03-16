default:

build:
  #!/usr/bin/env bash
  set -euxo pipefail
  source .env
  podman build . -t celeo/bobby_bot --build-arg DISCORD_TOKEN=${DISCORD_TOKEN}
