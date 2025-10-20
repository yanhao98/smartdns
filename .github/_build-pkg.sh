#!/bin/bash
sudo apt -qq update
sudo apt -qq install -y gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu
sudo apt -qq install -y build-essential perl libfindbin-libs-perl

OPENSSL_VER=3.0.16
# OPENSSL_TARGET=linux-x86_64
OPENSSL_TARGET=linux-aarch64
OPENSSL_DIR=/tmp/openssl/${OPENSSL_TARGET}
OPENSSL_BUILD_DIR=/tmp/build-openssl

# CROSS_PREFIX=x86_64-linux-gnu-
CROSS_PREFIX=aarch64-linux-gnu-
# PKG_ARCH=amd64 # x86_64
PKG_ARCH=arm64 # aarch64

mkdir -p $OPENSSL_BUILD_DIR
OPENSSL_URL="https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VER}/openssl-${OPENSSL_VER}.tar.gz"
curl -sSL $OPENSSL_URL | tar --strip-components=1 -zx -C $OPENSSL_BUILD_DIR

(
  cd $OPENSSL_BUILD_DIR
  make clean
  make distclean

  CONFIGURE_ARGS=(
    "--prefix=$OPENSSL_DIR"
    "--cross-compile-prefix=$CROSS_PREFIX" # export CC=${CROSS_PREFIX}gcc
    "no-shared"
    "no-tests"
    "${OPENSSL_TARGET}"
  )
  ./Configure ${CONFIGURE_ARGS[@]}

  # 构建并安装
  MAKE_ARGS=()
  # MAKE_ARGS+=("--silent")
  make ${MAKE_ARGS[@]} all -j$(nproc)
  make ${MAKE_ARGS[@]} install_sw
  sudo apt -qq install -y file
  file ${OPENSSL_DIR}/bin/openssl
)

export CFLAGS="-I /tmp/openssl/${OPENSSL_TARGET}/include"
export LDFLAGS="-L /tmp/openssl/${OPENSSL_TARGET}/lib -L /tmp/openssl/${OPENSSL_TARGET}/lib64"
BUILD_PKG_ARGS=()
BUILD_PKG_ARGS+=("--platform linux")
BUILD_PKG_ARGS+=("--arch $PKG_ARCH")
BUILD_PKG_ARGS+=("--cross-tool $CROSS_PREFIX")
echo "BUILD_PKG_ARGS=${BUILD_PKG_ARGS[@]}"
sh ./package/build-pkg.sh ${BUILD_PKG_ARGS[@]}
file src/smartdns

du -sh src/smartdns
