OPENSSL_VER=3.0.16
mkdir -p /tmp/build/openssl
cd /tmp/build/openssl
curl -sSL https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VER}/openssl-${OPENSSL_VER}.tar.gz | tar --strip-components=1 -zx
export CC=aarch64-linux-gnu-gcc
./Configure --prefix=/tmp/opt/build no-tests linux-aarch64
make all -j$(nproc)
make install_sw

export CC=aarch64-linux-gnu-gcc
export CFLAGS="-I /tmp/opt/build/include"
export LDFLAGS="-L /tmp/opt/build/lib -L /tmp/opt/build/lib64"
sh ./package/build-pkg.sh --platform linux --arch arm64 --cross-tool aarch64-linux-gnu- --static

# 正常编译，不使用静态链接，启用UI插件
# 确保先安装 pkg-config 和 cargo
if ! command -v cargo &> /dev/null; then
  apt update && apt install -y pkg-config
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
  rustup target add aarch64-unknown-linux-gnu
fi

# 为 Cargo 创建交叉编译配置
mkdir -p ~/.cargo
cat > ~/.cargo/config.toml << EOF
[target.aarch64-unknown-linux-gnu]
linker = "aarch64-linux-gnu-gcc"

[build]
target = "aarch64-unknown-linux-gnu"
EOF

# 安装必要的交叉编译依赖
apt install -y gcc-aarch64-linux-gnu g++-aarch64-linux-gnu
# 安装 bindgen 所需的 libclang 依赖
apt install -y libclang-dev llvm-dev clang

export LIBCLANG_PATH=$(dirname $(find /usr -name libclang.so* | head -n 1))

# 准备环境变量用于 Rust 交叉编译
export CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER=aarch64-linux-gnu-gcc
export CC_aarch64_unknown_linux_gnu=aarch64-linux-gnu-gcc
export CXX_aarch64_unknown_linux_gnu=aarch64-linux-gnu-g++
export PKG_CONFIG_ALLOW_CROSS=1

# 编译带 UI 的版本
make all WITH_UI=1

# mkdir -p ./release/var/log ./release/run ./release/usr/lib/smartdns
# make install DESTDIR=./release
