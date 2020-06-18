FROM docker.io/ubuntu:18.04

RUN apt-get update
RUN apt-get install curl software-properties-common -y

RUN add-apt-repository ppa:longsleep/golang-backports \
  && apt-get update \
  && apt-get install golang-go gcc git bzr jq pkg-config mesa-opencl-icd ocl-icd-opencl-dev cargo llvm clang opencl-headers wget -y

RUN curl -sSf https://sh.rustup.rs | sh -s -- -y
RUN echo "export PATH=~/.cargo/bin:$PATH" >> ~/.bashrc

RUN mkdir -p /storage \
  && mkdir -p /storage/lotuswork/lotusstorage \
  && mkdir -p /storage/lotuswork/lotus \
  && mkdir -p /storage/lotuswork/lotusworker \
  && mkdir -p /storage/filecoin-proof-parameters \
  && mkdir -p /storage/lotuswork/tmpdir

ENV LOTUS_STORAGE_PATH /storage/lotuswork/lotusstorage
ENV LOTUS_PATH /storage/lotuswork/lotus
ENV WORKER_PATH /storage/lotuswork/lotusworker
ENV FIL_PROOFS_PARAMETER_CACHE /storage/filecoin-proof-parameters
ENV IPFS_GATEWAY https://proof-parameters.s3.cn-south-1.jdcloud-oss.com/ipfs/
ENV TMPDIR /storage/lotuswork/tmpdir


RUN git clone https://github.com/filecoin-project/lotus.git &&\
    cd lotus &&\
    make clean all &&\
    make install &&\
    make build bench

#VOLUME ["/home","/root","/var"]


# API port
EXPOSE 1234/tcp

# P2P port
EXPOSE 1347/tcp

# API port
EXPOSE 2345/tcp

# API port
EXPOSE 3456/tcp



RUN sed -i "s/archive.ubuntu.com/mirrors.aliyun.com/g" /etc/apt/sources.list \
  && sed -i "s/security.ubuntu.com/mirrors.aliyun.com/g" /etc/apt/sources.list \
  && rm -f /etc/apt/sources.list.d/*

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

WORKDIR /storage

#ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/bash"]
