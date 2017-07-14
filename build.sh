#!/bin/bash -xe

SRCDIR=`pwd`
NCPU=`nproc`

mkdir -p build
mkdir -p deps
mkdir -p inst

# build and install libgg
mkdir -p build/libgg
pushd build/libgg
../../libgg/configure --prefix=${SRCDIR}/deps --syslibdir=${SRCDIR}/deps/lib
make -j${NCPU}
make install
popd

# install minimal binutils symlinks
ln -sf /usr/bin/x86_64-linux-gnu-strip deps/bin/x86_64-linux-musl-strip
ln -sf /usr/bin/x86_64-linux-gnu-ranlib deps/bin/x86_64-linux-musl-ranlib
ln -sf /usr/bin/x86_64-linux-gnu-nm deps/bin/x86_64-linux-musl-nm
ln -sf /usr/bin/x86_64-linux-gnu-ld deps/bin/x86_64-linux-musl-ld
ln -sf /usr/bin/x86_64-linux-gnu-as deps/bin/x86_64-linux-musl-as
ln -sf /usr/bin/x86_64-linux-gnu-ar deps/bin/x86_64-linux-musl-ar

export PATH=${SRCDIR}/deps/bin:$PATH
export LD_LIBRARY_PATH=${SRCDIR}/deps/lib:${SRCDIR}/deps/x86_64-linux-musl/lib64

# build and install gnu-to-gg cross-compiler
mkdir -p build/gnu-to-gg-gcc
pushd build/gnu-to-gg-gcc
../../gcc/configure --enable-languages=c,c++ --prefix=${SRCDIR}/deps --disable-multilib --disable-libsanitizer --disable-bootstrap --disable-nls --program-prefix="gnu-to-gg-" --with-sysroot=${SRCDIR}/deps --with-native-system-header-dir=/include --build=x86_64-linux-gnu --host=x86_64-linux-gnu --target=x86_64-linux-musl --enable-checking=release
make -j${NCPU}
make install
popd

# build and install gg-gcc
mkdir -p build/gg-gcc
pushd build/gg-gcc
../../gcc/configure --enable-languages=c,c++ --prefix=/usr --disable-multilib --disable-bootstrap --disable-nls --program-prefix="gg-" --with-sysroot=/ --build=x86_64-linux-musl --host=x86_64-linux-musl --target=x86_64-linux-gnu --enable-checking=release CC="gnu-to-gg-gcc -Wl,-I${SRCDIR}/deps/lib/libc.so" CXX="gnu-to-gg-g++ -Wl,-I${SRCDIR}/deps/lib/libc.so"
make -j${NCPU}
make DESTDIR=${SRCDIR}/inst install
popd

# build and install gg-binutils
mkdir -p build/gg-binutils
pushd build/gg-binutils
../../binutils-gdb/configure --prefix=/usr --disable-bootstrap --disable-werror --disable-nls --build=x86_64-linux-musl --host=x86_64-linux-musl --target=x86_64-linux-gnu --program-prefix="gg-" --disable-shared CC="gnu-to-gg-gcc -Wl,-I$(SRCDIR)/deps/lib/libc.so" CXX="gnu-to-gg-g++ -Wl,-I$(SRCDIR)/deps/lib/libc.so"
make configure-host
make LDFLAGS="-Wl,-static" -j${NCPU}
make DESTDIR=${SRCDIR}/inst install
popd
