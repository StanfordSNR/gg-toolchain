#!/bin/bash -xe

SRCDIR=`pwd`
NCPU=`nproc`

mkdir -p build
mkdir -p deps
mkdir -p inst

# build and install gg-gcc static
mkdir -p build/gg-gcc
pushd build/gg-gcc
rm -f gcc/xgcc gcc/xg++ gcc/cc1 gcc/cc1plus gcc/collect2
make -j${NCPU} LDFLAGS="-static"
make DESTDIR=${SRCDIR}/inst install
popd

# build and install gg-binutils
# XXX need to install static version of gg-binutils (minus gdb)
