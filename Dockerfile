FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

ARG BINUTILS_VERSION=2.36
ARG GCC_VERSION=11.1.0
ARG TARGET=mipsel-none-elf

ENV MIPSEL /usr/local/cross-mipsel-none-elf
ENV PATH $PATH:${MIPSEL}/bin

RUN apt-get update && apt-get install -y build-essential wget xz-utils file \
    zlib1g-dev tar autoconf automake texinfo libmpc-dev libmpfr-dev libgmp-dev && apt-get clean

RUN wget -q -O binutils.tar.xz https://ftp.gnu.org/pub/gnu/binutils/binutils-2.36.tar.xz && \
    wget -q -O gcc.tar.xz https://ftp.gnu.org/pub/gnu/gcc/gcc-11.1.0/gcc-11.1.0.tar.xz && \
    tar -xf binutils.tar.xz && tar xf gcc.tar.xz

RUN mkdir binutils_mipsel && cd binutils_mipsel && \
    ../binutils-${BINUTILS_VERSION}/configure --prefix=${MIPSEL} --target=${TARGET} \
    --disable-docs --disable-nls --with-float=soft && \
    make && make install-strip

RUN mkdir gcc_mipsel && cd gcc_mipsel && \
    ../gcc-${GCC_VERSION}/configure --prefix=${MIPSEL} --target=${TARGET} \
    --disable-docs --disable-nls --disable-libada --disable-libssp --disable-libquadmath --disable-libstdc++-v3 \
    --with-float=soft --enable-languages=c,c++ --with-gnu-as --with-gnu-ld && \
    make && make install-strip


