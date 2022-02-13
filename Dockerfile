FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

ARG BINUTILS_VERSION=2.36
ARG GCC_VERSION=11.1.0
ARG TARGET=mipsel-none-elf

ENV MIPSEL /usr/local/cross-mipsel-none-elf
ENV PATH $PATH:${MIPSEL}/bin 

RUN apt-get update --quiet && apt-get install --quiet -y build-essential wget xz-utils zlib1g-dev tar autoconf automake && \
    apt-get clean

RUN wget -q -O binutils.tar.xz https://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VERSION}.tar.xz && \
    wget -q -O gcc.tar.xz https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.xz && \
    tar xf binutils.tar.xz && tar xf gcc.tar.xz && rm -rf *xz && cd gcc-${GCC_VERSION} && ./contrib/download_prerequisites

RUN mkdir binutils_mipsel && cd binutils_mipsel && \
    ../binutils-${BINUTILS_VERSION}/configure --quiet --prefix=${MIPSEL} --target=${GCC_TARGET} \
    --disable-docs --disable-nls --with-float=soft && \
    make --quiet -j2 && make install-strip

RUN mkdir gcc_mipsel && cd gcc_mipsel && \
    ../gcc-${{ env.GCC_VERSION }}/configure --quiet --prefix=${MIPSEL} --target=${GCC_TARGET} \
    --disable-docs --disable-nls --disable-libada --disable-libssp --disable-libquadmath --disable-libstdc++-v3 \
    --with-float=soft --enable-languages=c,c++ --with-gnu-as --with-gnu-ld && \
    make --quiet -j2 && make install-strip
