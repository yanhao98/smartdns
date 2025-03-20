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

ARG WITH_UI=1
ARG WEBUI_WWW_DIR=./webui-www
ARG RELEASE_DIR=./release

# 从指定目录拷贝 WebUI 文件
RUN mkdir -p /rootfs/usr/share/smartdns/www
COPY ${WEBUI_WWW_DIR}/ /rootfs/usr/share/smartdns/www

# 拷贝smartdns
COPY ${RELEASE_DIR} /rootfs

# 使用Alpine作为最终基础镜像
FROM alpine:latest
# 安装运行时必要的库
RUN apk add --no-cache libgcc libstdc++

COPY --from=smartdns-builder /rootfs /
EXPOSE 53/udp
VOLUME ["/etc/smartdns/"]

CMD ["/usr/sbin/smartdns", "-f", "-x"]