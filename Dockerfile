FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

ENV MIPSEL /usr/local/cross-mipsel-none-elf
ENV PATH $PATH:${MIPSEL}/bin 

RUN mkdir -p /mipsel-none-elf-toolchain

COPY toolchain.sh /mipsel-none-elf-toolchain

WORKDIR . /mipsel-none-elf-toolchain

RUN apt-get update && apt-get install -y build-essential wget xz-utils \
    zlib1g-dev tar autoconf automake && \
    apt-get clean

RUN cd /mipsel-none-elf-toolchain && chmod 755 toolchain.sh && \
    ./toolchain.sh
