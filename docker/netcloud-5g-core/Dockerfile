FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y software-properties-common ca-certificates curl gnupg iproute2 iputils-ping net-tools tcpdump && add-apt-repository -y ppa:open5gs/latest && curl -fsSL https://pgp.mongodb.com/server-8.0.asc | gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/8.0 multiverse" > /etc/apt/sources.list.d/mongodb-org-8.0.list && apt-get update && apt-get install -y mongodb-org open5gs && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/netcloud /var/log/open5gs /data/db

CMD ["/bin/bash"]
