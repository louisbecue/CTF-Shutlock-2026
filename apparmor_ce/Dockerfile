FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV container=docker

COPY apparmor/              /tmp/apparmor/
COPY scripts/scanner.sh     /tmp/scanner.sh
COPY scripts/firstboot.sh   /tmp/firstboot.sh
COPY scripts/entrypoint.sh  /tmp/entrypoint.sh
COPY setup.sh               /root/setup.sh

RUN chmod +x /root/setup.sh /tmp/scanner.sh /tmp/firstboot.sh /tmp/entrypoint.sh && \
    /root/setup.sh && \
    cp /tmp/entrypoint.sh /usr/local/bin/entrypoint.sh && \
    chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 22

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
