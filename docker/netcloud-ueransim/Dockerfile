FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y git make gcc g++ cmake libsctp-dev lksctp-tools iproute2 iputils-ping net-tools tcpdump ca-certificates iperf3 && git clone https://github.com/aligungr/UERANSIM.git /opt/UERANSIM && cd /opt/UERANSIM && make && mkdir -p /opt/netcloud && apt-get clean && rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]
