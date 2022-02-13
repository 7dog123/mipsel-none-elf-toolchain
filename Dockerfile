FROM ubuntu:20.04

ARG BINUTILS_VERSION=2.36
ARG GCC_VERSION=11.1.0
ARG TARGET=mipsel-none-elf
ARG PROC_NR=$(getconf _NPROCESSORS_ONLN)

ENV MIPSEL /usr/local/cross-mipsel-none-elf
ENV PATH $PATH:${MIPSEL}/bin 

RUN apt-get update && apt-get install -y build-essential wget xz-utils zlib1g-dev tar autoconf automake && \
    apt-get clean

RUN wget -q -O binutils.tar.xz ftp://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VERSION}.tar.xz && \
    wget -q -O gcc.tar.xz https://ftp.gnu.org/gnu/gcc/${GCC_VERSION}/${GCC_VERSION}.tar.xz && \
    tar xf binutils.tar.xz && tar xf gcc.tar.xz && rm -rf *xz && cd gcc-${GCC_VERSION} && \
    ./contrib/download_prerequisites

RUN mkdir binutils_mipsel && cd binutils_mipsel && \
    ../binutils-${BINUTILS_VERSION}/configure --prefix=${MIPSEL} --target=${GCC_TARGET} \
    --disable-docs --disable-nls --with-float=soft && \
    make -j $PROC_NR && make install-strip

RUN mkdir gcc_mipsel && cd gcc_mipsel && \
    ../gcc-${{ env.GCC_VERSION }}/configure --prefix=${MIPSEL} --target=${GCC_TARGET} \
    --disable-docs --disable-nls --disable-libada --disable-libssp --disable-libquadmath --disable-libstdc++-v3 \
    --with-float=soft --enable-languages=c,c++ --with-gnu-as --with-gnu-ld && \
    make -j $PROC_NR && make install-strip
