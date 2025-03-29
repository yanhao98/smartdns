#!/bin/bash

OPENSSL_VER=3.0.16
OPENSSL_DIR=/tmp/openssl/linux-x86_64
OPENSSL_TARGET=linux-x86_64
OPENSSL_BUILD_DIR=/tmp/build-openssl

mkdir -p $OPENSSL_BUILD_DIR
OPENSSL_URL="https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VER}/openssl-${OPENSSL_VER}.tar.gz"
curl -sSL $OPENSSL_URL | tar --strip-components=1 -zx -C $OPENSSL_BUILD_DIR

(
  cd $OPENSSL_BUILD_DIR && \
  ./Configure --prefix=${OPENSSL_DIR} no-tests ${OPENSSL_TARGET} && \
  # 构建并安装
  make --silent all -j$(nproc) && \
  make --silent install_sw
)

export CFLAGS="-I /tmp/openssl/${OPENSSL_TARGET}/include"
export LDFLAGS="-L /tmp/openssl/${OPENSSL_TARGET}/lib -L /tmp/openssl/${OPENSSL_TARGET}/lib64"
sh ./package/build-pkg.sh --platform linux --arch amd64 --cross-tool x86_64-linux-gnu-

du -sh src/smartdns