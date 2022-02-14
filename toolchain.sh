#!/bin/bash

# Before calling this script, make sure you have GMP, MPFR and TexInfo
# packages installed in your system.  On a Debian-based system this is
# achieved by typing the following commands:
#
# sudo apt-get install libmpfr-dev
# sudo apt-get install texinfo
# sudo apt-get install libmpc-dev

# Exit on error
set -e

# Set MIPSEL before calling the script to change the default installation directory path
INSTALL_PATH="${MIPSEL:-/usr/local/}"

# Set target for toolchain
TARGET=mipsel-none-elf

# Determine how many parallel Make jobs to run based on CPU count
JOBS="${JOBS:-`getconf _NPROCESSORS_ONLN`}"
JOBS="${JOBS:-1}" # If getconf returned nothing, default to 1

# Dependency source libs (Versions)
BINUTILS_V=2.36
GCC_V=11.1.0

# Check if a command-line tool is available: status 0 means "yes"; status 1 means "no"
command_exists () {
  (command -v "$1" >/dev/null 2>&1)
  return $?
}

# Download the file URL using wget or curl (depending on which is installed)
download () {
  if   command_exists wget ; then wget -q -c  "$1"
  elif command_exists curl ; then curl --silent -LO "$1"
  else
    echo "Install `wget` or `curl` to download toolchain sources" 1>&2
    return 1
  fi
}

# Dependency source: Download stage
test -f "binutils-$BINUTILS_V.tar.gz" || download "https://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS_V.tar.gz"
test -f "gcc-$GCC_V.tar.gz"           || download "https://ftp.gnu.org/gnu/gcc/gcc-$GCC_V/gcc-$GCC_V.tar.gz"

# Dependency source: Extract stage
test -d "binutils-$BINUTILS_V" || tar -xzf "binutils-$BINUTILS_V.tar.gz"
test -d "gcc-$GCC_V"           || tar -xzf "gcc-$GCC_V.tar.gz"

pushd "gcc-$GCC_V"
./contrib/download_prerequisites 1>/dev/null 2>&1
popd

# Compile binutils
mkdir binutils_mips
pushd binutils_mips
../"binutils-$BINUTILS_V"/configure --quiet \
  --prefix="$INSTALL_PATH" \
  --target=${TARGET} --disable-docs --disable-nls \
  --with-float=soft
make --quiet -j "$JOBS"
make --quiet -j "$JOBS"  install-strip
popd

# Compile GCC for MIPSEL
mkdir gcc_mips
pushd gcc_mips
../"gcc-$GCC_V"/configure --quiet \
  --prefix="$INSTALL_PATH" --target=${TARGET} \
  --disable-docs --disable-nls --disable-libada \
  --disable-libssp --disable-libquadmath \
  --disable-libstdc++-v3 --with-float=soft \
  --enable-languages="c,c++" --with-gnu-as --with-gnu-ld
make --quiet -j "$JOBS"
make --quiet -j "$JOBS" install-strip
popd

rm -rf binutils-$BINUTILS_V binutils-$BINUTILS_V.tar.gz \
       gcc-$GCC_V gcc-$GCC_V.tar.gz
