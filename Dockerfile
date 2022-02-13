FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

ARG BINUTILS_VERSION=2.36
ARG GCC_VERSION=11.1.0
ARG TARGET=mipsel-none-elf

ENV MIPSEL /usr/local/cross-mipsel-none-elf
ENV PATH $PATH:${MIPSEL}/bin

RUN apt-get update && apt-get install -y build-essential wget xz-utils file \
    zlib1g-dev tar autoconf automake texinfo && apt-get clean

RUN wget -q -O binutils.tar.xz https://ftp.gnu.org/pub/gnu/binutils/binutils-2.36.tar.xz && \
    wget -q -O gcc.tar.xz https://ftp.gnu.org/pub/gnu/gcc/gcc-11.1.0/gcc-11.1.0.tar.xz && \
    tar -xf binutils.tar.xz && tar xf gcc.tar.xz

RUN mkdir binutils_mipsel && cd binutils_mipsel && \
    ../binutils-${BINUTILS_VERSION}/configure --prefix=${MIPSEL} --target=${TARGET} \
    --disable-docs --disable-nls --with-float=soft && \
    make -j $PROC_NR && make install-strip

RUN wget https://ftp.gnu.org/gnu/gmp/gmp-6.2.0.tar.bz2 \
    https://ftp.gnu.org/gnu/mpc/mpc-1.2.1.tar.gz \
    https://ftp.gnu.org/gnu/mpfr/mpfr-4.1.0.tar.bz2 && \
    mkdir -pv gcc-${GCC_VERSION}/{gmp,mpfr,mpc} && \
    tar -xf gmp-6.2.0.tar.bz2 -C gcc-${GCC_VERSION}/gmp && \
    tar -xf mpc-1.2.1.tar.gz -C gcc-${GCC_VERSION}/mpc && \
    tar -xf mpfr-4.1.0.tar.bz2 -C gcc-${GCC_VERSION}/mpfr && rm -rf *tar*

RUN mkdir gcc_mipsel && cd gcc_mipsel && \
    ../gcc-${GCC_VERSION}/configure --prefix=${MIPSEL} --target=${TARGET} \
    --disable-docs --disable-nls --disable-libada --disable-libssp --disable-libquadmath --disable-libstdc++-v3 \
    --with-float=soft --enable-languages=c,c++ --with-gnu-as --with-gnu-ld && \
    make -j $PROC_NR && make install-strip


