#!/bin/sh
set -eu

getnumproc() {
which getconf >/dev/null 2>/dev/null && {
	getconf _NPROCESSORS_ONLN 2>/dev/null || getconf NPROCESSORS_ONLN 2>/dev/null || echo 1;
} || echo 1;
};

numproc=`getnumproc`

BINUTILS_VER=2.36
GCC_VER=11.1.0
TARGET=mipsel-none-elf

wget -q -O binutils.tar.xz https://ftp.gnu.org/pub/gnu/binutils/binutils-${BINUTILS_VER}.tar.xz

mkdir -pv binutils-{build,source}
tar -xf binutils.tar.xz -C binutils-source --strip 1

pushd binutils-build
  ../binutils-${BINUTILS_VER}/configure --quiet \
  --prefix=${MIPSEL} --target=${TARGET} \
  --disable-docs --disable-nls --with-float=soft
make --quiet -j${numproc}
pushd binutils-build
make --quiet -j${numproc} install-strip
pop

wget -q -O gcc.tar.xz https://ftp.gnu.org/pub/gnu/gcc/gcc-${GCC_VER}/gcc-${GCC_VER}.tar.xz

mkdir -pv gcc-{build,source}
tar -xf gcc.tar.xz -C gcc-source --strip 1

pushd gcc-source
./contrib/download_prerequisites
popd

pushd gcc-build
  ../gcc-${GCC_VER}/configure --quiet --prefix=${MIPSEL} \
  --target=${TARGET} --disable-docs --disable-nls \
  --disable-libada --disable-libssp --disable-libquadmath \
  --disable-libstdc++-v3 --with-float=soft \
  --enable-languages=c,c++ --with-gnu-as --with-gnu-ld
make --quiet -j${numproc}
make install-strip
popd

rm -rf *xz
rm -rf *-source
rm -rf *-build
exit 0
