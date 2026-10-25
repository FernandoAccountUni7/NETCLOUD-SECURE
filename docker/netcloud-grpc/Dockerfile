FROM python:3.12-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash \
        iproute2 \
        iputils-ping \
        procps \
        net-tools \
        curl \
        wget \
        ca-certificates \
        dnsutils \
        openssh-client \
        tcpdump \
        traceroute \
        netcat-openbsd \
        lsof \
        jq && \
    rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir \
        grpcio \
        grpcio-tools \
        psutil

RUN mkdir -p /opt/netcloud

CMD ["/bin/bash"]
