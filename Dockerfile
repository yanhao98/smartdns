##########
# https://github.com/pymumu/smartdns/blob/master/Dockerfile
# [SmartDNS UI界面体验](https://github.com/pymumu/smartdns/issues/1917)
#  https://github.com/dalamudx/smartdns/blob/master/Dockerfile
#  https://hub.docker.com/r/dalamudx/smartdns
##########
# plugin /usr/lib/libsmartdns_ui.so
# smartdns-ui.www-root /usr/share/smartdns/www
# smartdns-ui.ip http://0.0.0.0:6080
# data-dir /etc/smartdns
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
    clang-dev llvm-dev

# 设置libclang路径环境变量
ENV LIBCLANG_PATH=/usr/lib

# 从指定目录拷贝 WebUI 文件
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