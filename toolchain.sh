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
BINUTILS="ftp://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VER}.tar.bz2"
GCC="ftp://ftp.gnu.org/gnu/gcc/gcc-${GCC_VER}/gcc-${GCC_VER=}.tar.gz"

mkdir -pv {stamps,tarballs}

if [ ! -f stamps/binutils-download ]; then
  wget "${BINUTILS}" -O "tarballs/$(basename ${BINUTILS})"
  touch stamps/binutils-download
fi

if [ ! -f stamps/binutils-extract ]; then
  mkdir -pv binutils-{build,source}
  tar -xf tarballs/$(basename ${BINUTILS}) -C binutils-source --strip 1
  touch stamps/binutils-extract
fi

if [ ! -f stamps/binutils-configure ]; then
  pushd binutils-build
  ../binutils-${BINUTILS_VER}/configure --quiet \
  --prefix=${MIPSEL} --target=${TARGET} \
  --disable-docs --disable-nls --with-float=soft
  popd

  touch stamps/binutils-configure
fi

if [ ! -f stamps/binutils-build ]; then
  pushd binutils-build
  make --quiet -j${numproc}
  popd

  touch stamps/binutils-build
fi

if [ ! -f stamps/binutils-install ]; then
  pushd binutils-build
  make --quiet -j${numproc} install-strip
  popd

  touch stamps/binutils-install
fi

if [ ! -f stamps/gcc-download ]; then
  wget "${GCC}" -O "tarballs/$(basename ${GCC})"
  touch stamps/gcc-download
fi

if [ ! -f stamps/gcc-extract ]; then
  mkdir -pv gcc-{build,source}
  tar -xf tarballs/$(basename ${GCC}) -C gcc-source --strip 1
  touch stamps/gcc-extract
fi

if [ ! -f stamps/gcc-configure ]; then
  pushd gcc-build
  ../gcc-${GCC_VER}/configure --quiet --prefix=${MIPSEL} \
  --target=${TARGET} --disable-docs --disable-nls \
  --disable-libada --disable-libssp --disable-libquadmath \
  --disable-libstdc++-v3 --with-float=soft \
  --enable-languages=c,c++ --with-gnu-as --with-gnu-ld
  popd

  touch stamps/gcc-configure
fi

if [ ! -f stamps/gcc-build ]; then
  pushd gcc-build
  make --quiet -j${numproc}
  popd

  touch stamps/gcc-build
fi

if [ ! -f stamps/gcc-install ]; then
  pushd gcc-build
  make install-strip
  popd

  touch stamps/gcc-install
fi

rm -rf "${SCRIPT_DIR}"/../tools/tarballs
rm -rf "${SCRIPT_DIR}"/../tools/*-source
rm -rf "${SCRIPT_DIR}"/../tools/*-build
rm -rf "${SCRIPT_DIR}"/../tools/stamps
exit 0
