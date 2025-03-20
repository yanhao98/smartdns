##########
# https://github.com/pymumu/smartdns/blob/master/Dockerfile
# [SmartDNS UI界面体验](https://github.com/pymumu/smartdns/issues/1917)
#  https://github.com/dalamudx/smartdns
#  https://hub.docker.com/r/dalamudx/smartdns
##########
# UI配置
# data-dir /etc/smartdns/db                    #数据库存放目录，可自行指定
# smartdns-ui.www-root /var/www                #UI目录，固定，不要修改
# plugin /usr/lib/smartdns/libsmartdns_ui.so   #插件路径，固定，不要修改
##########
# docker build --build-arg WEBUI_WWW_DIR=doc . -t smartdns-local
##########

FROM alpine:latest AS smartdns-builder
LABEL previous-stage=smartdns-builder

# 安装构建依赖
ARG OPENSSL_VER=3.0.16
ARG WITH_UI=1
ARG WEBUI_WWW_DIR=webui-www

RUN apk add --no-cache \
    gcc g++ make musl-dev bash perl curl linux-headers \
    pkgconfig \
    # Rust支持UI插件构建
    rust cargo \
    # 添加libclang和LLVM相关依赖
    clang-dev llvm-dev \
    # 其他可能需要的依赖
    git

# 设置libclang路径环境变量
ENV LIBCLANG_PATH=/usr/lib

# 构建OpenSSL
RUN mkdir -p /build/openssl && \
    cd /build/openssl && \
    curl -sSL https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VER}/openssl-${OPENSSL_VER}.tar.gz | tar --strip-components=1 -zx && \
    \
    if [ "$(uname -m)" = "aarch64" ]; then \
        ./config --prefix=/opt/build no-tests -mno-outline-atomics > /dev/null; \
    else \ 
        ./config --prefix=/opt/build no-tests > /dev/null; \
    fi && \
    make -s all -j$(nproc) && make -s install_sw && \
    cd / && rm -rf /build

# 直接从指定目录拷贝 WebUI 文件
RUN mkdir -p /release/var/www/
COPY ${WEBUI_WWW_DIR}/ /release/var/www/

# 构建smartdns
COPY . /build/smartdns/
RUN cd /build/smartdns && \
    export CFLAGS="-I /opt/build/include" && \
    export LDFLAGS="-L /opt/build/lib -L /opt/build/lib64" && \
    # 正常编译，不使用静态链接，启用UI插件
    make all WITH_UI=${WITH_UI} && \
    mkdir -p /release/var/log /release/run /release/usr/lib/smartdns && \
    make install DESTDIR=/release && \
    cd / && rm -rf /build

# 使用Alpine作为最终基础镜像
FROM alpine:latest
# 安装运行时必要的库
RUN apk add --no-cache libgcc libstdc++

COPY --from=smartdns-builder /release/ /
EXPOSE 53/udp
VOLUME ["/etc/smartdns/"]

CMD ["/usr/sbin/smartdns", "-f", "-x"]