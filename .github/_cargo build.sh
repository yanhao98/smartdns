#!/bin/bash
sudo apt -qq update
sudo apt -qq install -y build-essential
# sudo apt -qq install -y gcc-x86-64-linux-gnu g++-x86-64-linux-gnu
sudo apt -qq install -y gcc-aarch64-linux-gnu g++-aarch64-linux-gnu
sudo apt -qq install -y llvm clang libclang-dev

# Check if rustup is already installed
if ! command -v rustup &>/dev/null; then
  echo "Rust not found, installing..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
else
  echo "Rust is already installed"
fi
# Ensure cargo environment is sourced
. "$HOME/.cargo/env"

(
  cd plugin/smartdns-ui
  # rm -r target
  CARGO_LINKER=x86_64-linux-gnu-gcc
  CARGO_TARGET="x86_64-unknown-linux-gnu"
  # CARGO_LINKER=aarch64-linux-gnu-gcc
  # CARGO_TARGET="aarch64-unknown-linux-gnu"

  rustup target add $CARGO_TARGET

  CARGO_RUSTFLAGS=()
  CARGO_RUSTFLAGS+=("-C linker=$CARGO_LINKER")
  CARGO_BUILD_ARGS=()
  CARGO_BUILD_ARGS+=("--target $CARGO_TARGET")
  CARGO_BUILD_ARGS+=("--features build-release")
  if [ "${OPTIMIZE_SIZE:-0}" = "1" ]; then
    CARGO_BUILD_ARGS+=("--profile release-optmize-size")
  else
    CARGO_BUILD_ARGS+=("--release")
  fi
  RUSTFLAGS="${CARGO_RUSTFLAGS[@]}" cargo build ${CARGO_BUILD_ARGS[@]}

  if [ "${OPTIMIZE_SIZE:-0}" = "1" ]; then
    du -sh target/$CARGO_TARGET/release-optmize-size/libsmartdns_ui.so
  else
    du -sh target/$CARGO_TARGET/release/libsmartdns_ui.so
  fi
)
