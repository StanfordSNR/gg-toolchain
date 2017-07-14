#!/bin/bash -xe

SRCDIR=`pwd`
DESTDIR=${SRCDIR}/bin
INSTDIR=${SRCDIR}/inst/usr/bin
INCLUDEDIR=${SRCDIR}/include
GCC_INSTDIR=${SRCDIR}/inst/usr/libexec/gcc/x86_64-linux-gnu/7.1.0

mkdir -p ${DESTDIR}

for exe in gcc ld as ar ranlib nm strip as
do
  cp ${INSTDIR}/gg-${exe} ${DESTDIR}/${exe}
done

for exe in cc1
do
  cp ${GCC_INSTDIR}/${exe} ${DESTDIR}/${exe}
done

mkdir -p ${INCLUDEDIR}
./generate-header.py >${INCLUDEDIR}/toolchain.hh
