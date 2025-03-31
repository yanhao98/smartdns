#####
# 🐳
#####
FROM ubuntu:24.10

ARG TARGETARCH

RUN apt -qq update && apt -qq install -y openssl && \
    apt -qq clean && rm -rf /var/lib/apt/lists/*

COPY webui-dist/ /usr/share/smartdns/www

COPY smartdns-files-${TARGETARCH}/smartdns /usr/sbin/smartdns
COPY smartdns-files-${TARGETARCH}/libsmartdns_ui.so /usr/lib/libsmartdns_ui.so
RUN chmod +x /usr/sbin/smartdns && /usr/sbin/smartdns -v

EXPOSE 53/udp
# webui
EXPOSE 6080/tcp

ENTRYPOINT [ "/usr/sbin/smartdns" ]
CMD ["-f", "-x"]