#FROM ubuntu:24.04
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV log_level_e2sim=info

# ----------------------------------
# 기본 패키지 설치
# ----------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential git cmake libsctp-dev autoconf automake libtool bison flex \
    libboost-all-dev g++ python3 python3-pip python3-venv pkg-config libeigen3-dev sqlite3 \
    openssh-server \
 && mkdir /var/run/sshd \
 && echo 'root:1234' | chpasswd \
 && sed -i 's/#\?PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config \
 && sed -i 's/#\?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# ----------------------------------
# E2SIM 설치
# ----------------------------------
RUN git clone https://github.com/jaewook2/e2sim_update.git /workspace/e2sim

RUN mkdir -p /workspace/e2sim/e2sim/build
WORKDIR /workspace/e2sim/e2sim/build
RUN cmake .. -DDEV_PKG=1 -DLOG_LEVEL=${log_level_e2sim} \
 && make package \
 && dpkg --install ./e2sim-dev_1.0.0_amd64.deb \
 && ldconfig

# ----------------------------------
# ns-3 + oran-interface 설치
# ----------------------------------
WORKDIR /workspace
RUN git clone https://github.com/jaewook2/ns3mmave_update.git /workspace/ns3-mmwave-oran \
 && git clone https://github.com/jaewook2/nsoran_update.git /workspace/ns3-mmwave-oran/contrib/oran-interface

WORKDIR /workspace/ns3-mmwave-oran
RUN ./ns3 configure --enable-examples --enable-tests && ./ns3 build

# ----------------------------------
# Default command
# ----------------------------------
EXPOSE 22
CMD service ssh start && /bin/bash
