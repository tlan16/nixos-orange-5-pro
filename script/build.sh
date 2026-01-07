#!/usr/bin/env bash
set -euo pipefail

# Orchestrate building an Orange Pi SD image inside a Nix-enabled Docker container.
# Usage:
#   script/build.sh [--board orangepi5|orangepi5plus] [--mode template|checks]
#
# Modes:
#   template - follows README flow using the provided flake template (default)
#   checks   - builds via this repo's flake checks outputs (quick, no customization)
#
# Output image will be copied into ./artifacts on the host.

BOARD="orangepi5"
MODE="template"

while test $# -gt 0; do
  case "$1" in
    --board)
      BOARD="${2:-}"; shift 2;
      ;;
    --mode)
      MODE="${2:-}"; shift 2;
      ;;
    -h|--help)
      sed -n '1,20p' "$0"; exit 0;
      ;;
    *)
      echo "Unknown arg: $1" >&2; exit 1;
      ;;
  esac

done

if [[ "$BOARD" != "orangepi5" && "$BOARD" != "orangepi5plus" ]]; then
  echo "--board must be 'orangepi5' or 'orangepi5plus'" >&2
  exit 2
fi

# Ensure artifacts dir exists
mkdir -p artifacts

# Build docker image if needed
if ! docker image inspect socle-nix-builder:latest >/dev/null 2>&1; then
  echo "[build] Building docker image socle-nix-builder:latest"
  docker compose build builder
fi

# Compose the inner build script based on the chosen mode
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
ARTIFACT_NAME="${BOARD}-${TIMESTAMP}.img.zst"

# Run the build inside the container as a one-off task
echo "[build] Starting containerized build: board=$BOARD mode=$MODE"

if [[ "$MODE" == "template" ]]; then
  docker compose run --rm \
    -e BOARD="$BOARD" -e ARTIFACT_NAME="$ARTIFACT_NAME" \
    builder sh -se <<'INNERSH'
set -eu
WORKDIR=/tmp/socle-build
mkdir -p "$WORKDIR" && cd "$WORKDIR"
# Materialize template from the mounted repository (local flake)
# The template lives at /workspace#orangepi-5x
rm -rf nixos
nix flake new -t /workspace#orangepi-5x nixos
cd nixos
# Build the selected board image
nix build .#nixosConfigurations.${BOARD}.config.system.build.sdImage
# Copy artifact to the mounted workspace
set -- result/sd-image/*.img.zst
IMG="$1"
cp -v "$IMG" "/workspace/artifacts/${ARTIFACT_NAME}"
INNERSH
elif [[ "$MODE" == "checks" ]]; then
  docker compose run --rm \
    -e BOARD="$BOARD" -e ARTIFACT_NAME="$ARTIFACT_NAME" \
    builder sh -se <<'INNERSH'
set -eu
cd /workspace
SYS=$(uname -m)
case "$SYS" in
  x86_64) SYS_ATTR=x86_64-linux ;;
  aarch64|arm64) SYS_ATTR=aarch64-linux ;;
  *) echo "Unsupported arch: $SYS" >&2; exit 1 ;;
esac
# Map board to checks attribute name
case "$BOARD" in
  orangepi5) BOARD_ATTR=orangepi-5 ;;
  orangepi5plus) BOARD_ATTR=orangepi-5-plus ;;
  *) echo "Unknown board: $BOARD" >&2; exit 1 ;;
esac
nix build .#checks.${SYS_ATTR}.${BOARD_ATTR}
set -- result/sd-image/*.img.zst
IMG="$1"
cp -v "$IMG" "/workspace/artifacts/${ARTIFACT_NAME}"
INNERSH
else
  echo "Unknown --mode: $MODE" >&2; exit 3
fi

echo "[build] Done. Artifact saved to artifacts/$ARTIFACT_NAME"
