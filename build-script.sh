#!/bin/bash -xe

SRCDIR=`pwd`
NCPU=$(dc -e "[`nproc`]sM 8d `nproc`<Mp")

mkdir -p build
mkdir -p inst

export PATH=${SRCDIR}/inst/bin:$PATH
export LD_LIBRARY_PATH=${SRCDIR}/inst/lib:${SRCDIR}/inst/x86_64-linux-musl/lib64

# build and install libgg
mkdir -p build/libgg
pushd build/libgg
../../libgg/configure --prefix=${SRCDIR}/inst --syslibdir=${SRCDIR}/inst/lib
make -j${NCPU}
make install
popd

# install minimal binutils symlinks
./make-binutils-symlinks.sh

# build and install gnu-to-gg cross-compiler
mkdir -p build/gnu-to-gg-gcc
pushd build/gnu-to-gg-gcc
../../gcc/configure --enable-languages=c,c++ --prefix=${SRCDIR}/inst --disable-multilib --disable-libsanitizer --disable-bootstrap --disable-nls --program-prefix="gnu-to-gg-" --with-sysroot=${SRCDIR}/inst --with-native-system-header-dir=/include --build=x86_64-linux-gnu --host=x86_64-linux-gnu --target=x86_64-linux-musl --enable-checking=release
make -j${NCPU}
make install
popd

# build and install gg-gcc
mkdir -p build/gg-gcc
pushd build/gg-gcc
../../gcc/configure --enable-languages=c,c++ --prefix=${SRCDIR}/inst --disable-multilib --disable-bootstrap --disable-nls --program-prefix="gg-" --with-sysroot=/ --build=x86_64-linux-musl --host=x86_64-linux-musl --target=x86_64-linux-gnu --enable-checking=release CC="gnu-to-gg-gcc -Wl,-I${SRCDIR}/inst/lib/libc.so" CXX="gnu-to-gg-g++ -Wl,-I${SRCDIR}/inst/lib/libc.so"
make -j${NCPU}
make install
popd
