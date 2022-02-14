# syntax=docker/dockerfile:1

# Stage 1 - Build the toolchain
FROM ubuntu:20.04

ARG MIPSEL=/cross-mipsel-none-elf
ENV MIPSEL=${MIPSEL}

# install dependencies
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive TZ=US/Central \
    apt-get install -yq --no-install-recommends wget bzip2 \
    build-essential apt-utils autoconf automake zlib1g-dev \
    bison flex texinfo file ca-certificates libelf-dev
RUN apt-get clean

# Build
COPY ./toolchain.sh /tmp/toolchain.sh
WORKDIR /tmp
RUN ./toolchain.sh

# Strip executables
RUN find ${MIPSEL}/bin -type f | xargs strip
RUN strip ${MIPSEL}/libexec/gcc/mipsel-none-elf/11.2.0/plugin/gengtype
RUN strip ${MIPSEL}/libexec/gcc/mipsel-none-elf/11.2.0/liblto_plugin.so
RUN strip ${MIPSEL}/libexec/gcc/mipsel-none-elf/11.2.0/lto-wrapper
RUN strip ${MIPSEL}/libexec/gcc/mipsel-none-elf/11.2.0/collect2
RUN strip ${MIPSEL}/libexec/gcc/mipsel-none-elf/11.2.0/cc1plus
RUN strip ${MIPSEL}/libexec/gcc/mipsel-none-elf/11.2.0/cc1
RUN strip ${MIPSEL}/libexec/gcc/mipsel-none-elf/11.2.0/install-tools/fixincl
RUN strip ${MIPSEL}/libexec/gcc/mipsel-none-elf/11.2.0/lto1
RUN rm -rf ${MIPSEL}/share/locale/*

# Stage 2 - Prepare minimal image
FROM ubuntu:20.04
ARG MIPSEL=/cross-mipsel-none-elf
ENV MIPSEL=${MIPSEL}
ENV PATH="${MIPSEL}/bin:$PATH"

COPY --from=0 ${MIPSEL} ${MIPSEL}
RUN apt-get update && \
    apt-get install -yq --no-install-recommends \
    gcc g++ make && \
    apt-get clean && \
    apt autoremove -yq
