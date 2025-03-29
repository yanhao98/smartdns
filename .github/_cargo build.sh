sudo apt update
sudo apt install -y build-essential
sudo apt install -y gcc-x86-64-linux-gnu g++-x86-64-linux-gnu
sudo apt install -y llvm clang libclang-dev

# Check if rustup is already installed
if ! command -v rustup &> /dev/null; then
  echo "Rust not found, installing..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
else
  echo "Rust is already installed"
fi
# Ensure cargo environment is sourced
. "$HOME/.cargo/env"

cd plugin/smartdns-ui
rm -r target

rustup target add x86_64-unknown-linux-gnu
CARGO_RUSTFLAGS=()
CARGO_RUSTFLAGS+=("-C linker=x86_64-linux-gnu-gcc")
CARGO_BUILD_ARGS=()
CARGO_BUILD_ARGS+=("--target x86_64-unknown-linux-gnu")
CARGO_BUILD_ARGS+=("--features build-release")
if [ "${OPTIMIZE_SIZE:-0}" = "1" ]; then
  CARGO_BUILD_ARGS+=("--profile release-optmize-size")
else
  CARGO_BUILD_ARGS+=("--release")
fi
RUSTFLAGS="${CARGO_RUSTFLAGS[@]}" cargo build ${CARGO_BUILD_ARGS[@]}

if [ "${OPTIMIZE_SIZE:-0}" = "1" ]; then
  du -sh target/x86_64-unknown-linux-gnu/release-optmize-size/libsmartdns_ui.so
else
  du -sh target/x86_64-unknown-linux-gnu/release/libsmartdns_ui.so
fi
