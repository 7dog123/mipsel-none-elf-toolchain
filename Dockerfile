FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

ENV MIPSEL /usr/local/cross-mipsel-none-elf
ENV PATH $PATH:${MIPSEL}/bin

RUN apt-get update && apt-get install -y build-essential wget xz-utils \
    zlib1g-dev tar autoconf automake && apt-get clean

RUN chmod 755 toolchain.sh && ./toolchain.sh
