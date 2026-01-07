# Nix-enabled builder container for building RK3588 SD images via flakes
# Keep the image minimal; rely on Nix for toolchain resolution
FROM nixos/nix:2.24.1

# Enable flakes and the new CLI
ENV NIX_CONFIG="experimental-features = nix-command flakes"

# Work under /workspace which will be bind-mounted by docker-compose
WORKDIR /workspace

# Helpful defaults for reproducible, less chatty nix
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TZ=UTC

# No default entrypoint/command; docker compose will run one-off build commands
