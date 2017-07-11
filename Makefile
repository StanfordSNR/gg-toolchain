#!/usr/bin/make -f

SRCDIR=$(shell pwd)
NCPU=$(shell nproc)
GG_ROOT=$(HOME)/.gg

export PATH := $(SRCDIR)/inst/bin:$(PATH)
export LD_LIBRARY_PATH := $(SRCDIR)/inst/lib:$(SRCDIR)/inst/x86_64-linux-musl/lib64

.PHONY: fetch-submodules create-folders gnu-to-gg-gcc gg-gcc gg-binutils \
	create-binutils-symlinks install

all: gg-binutils gg-gcc

fetch-submodules:
	git submodule init
	mkdir -p $(shell git rev-parse --git-dir)/modules

	git clone --depth 1 --branch gcc-7_1_0-release \
		--separate-git-dir $(shell git rev-parse --git-dir)/modules/gcc \
		https://github.com/gcc-mirror/gcc

	git clone --depth 1 --branch binutils-2_28 \
		--separate-git-dir $(shell git rev-parse --git-dir)/modules/binutils-gdb \
		git://sourceware.org/git/binutils-gdb.git

	git clone --depth 1 --branch gg
		--separate-git-dir $(shell git rev-parse --git-dir)/modules/libgg \
		https://github.com/stanfordsnr/libgg

	cd gcc && ./contrib/download_prerequisites

create-folders:
	mkdir -p build
	mkdir -p inst/bin

.ONESHELL:
SHELL = /bin/bash
.SHELLFLAGS = -e
libgg: fetch-submodules create-folders
	mkdir -p build/libgg
	pushd build/libgg
	../../libgg/configure --prefix=$(SRCDIR)/inst --syslibdir=$(SRCDIR)/inst/lib
	make -j$(NCPU)
	make install
	popd

create-binutils-symlinks: create-folders
	ln -sf /usr/bin/x86_64-linux-gnu-strip inst/bin/x86_64-linux-musl-strip
	ln -sf /usr/bin/x86_64-linux-gnu-ranlib inst/bin/x86_64-linux-musl-ranlib
	ln -sf /usr/bin/x86_64-linux-gnu-nm inst/bin/x86_64-linux-musl-nm
	ln -sf /usr/bin/x86_64-linux-gnu-ld inst/bin/x86_64-linux-musl-ld
	ln -sf /usr/bin/x86_64-linux-gnu-as inst/bin/x86_64-linux-musl-as
	ln -sf /usr/bin/x86_64-linux-gnu-ar inst/bin/x86_64-linux-musl-ar

.ONESHELL:
SHELL = /bin/bash
.SHELLFLAGS = -e
gnu-to-gg-gcc: libgg create-binutils-symlinks
	mkdir -p build/gnu-to-gg-gcc
	pushd build/gnu-to-gg-gcc
	../../gcc/configure --enable-languages=c,c++ --prefix=$(SRCDIR)/inst \
		--disable-multilib --disable-libsanitizer --disable-bootstrap --disable-nls \
		--program-prefix="gnu-to-gg-" --with-sysroot=$(SRCDIR)/inst \
		--with-native-system-header-dir=/include --build=x86_64-linux-gnu \
		--host=x86_64-linux-gnu --target=x86_64-linux-musl --enable-checking=release
	make -j$(NCPU)
	make install
	popd

.ONESHELL:
SHELL = /bin/bash
.SHELLFLAGS = -e
gg-binutils: gnu-to-gg-gcc
	mkdir -p build/gg-binutils
	pushd build/gg-binutils
		../../binutils-gdb/configure --prefix=$(SRCDIR)/inst --disable-bootstrap \
		--disable-werror --disable-nls --build=x86_64-linux-musl \
		--host=x86_64-linux-musl --target=x86_64-linux-gnu --program-prefix="gg-" \
		--with-sysroot=/ \
		CC="gnu-to-gg-gcc -Wl,-I$(SRCDIR)/inst/lib/libc.so" \
		CXX="gnu-to-gg-g++ -Wl,-I$(SRCDIR)/inst/lib/libc.so"
	make configure-host
	make LDFLAGS=-all-static -j$(NCPU)
	make install
	popd

.ONESHELL:
SHELL = /bin/bash
.SHELLFLAGS = -e
gg-gcc: gnu-to-gg-gcc
	mkdir -p build/gg-gcc
	pushd build/gg-gcc
	../../gcc/configure --enable-languages=c,c++ --prefix=$(SRCDIR)/inst \
		--with-boot-ldflags=-static --with-stage1-ldflags=-static \
		--disable-multilib --disable-bootstrap --disable-nls --program-prefix="gg-" \
		--with-sysroot=/ --build=x86_64-linux-musl --host=x86_64-linux-musl \
		--target=x86_64-linux-gnu --enable-checking=release \
		CC="gnu-to-gg-gcc -Wl,-I$(SRCDIR)/inst/lib/libc.so" \
		CXX="gnu-to-gg-g++ -Wl,-I$(SRCDIR)/inst/lib/libc.so"
	make -j$(NCPU)
	make install-strip
	popd

install:
	mkdir -p $(GG_ROOT)/exe/bin
	cp $(SRCDIR)/inst/bin/gg-gcc $(GG_ROOT)/exe/bin/gcc
	cp $(SRCDIR)/inst/libexec/gcc/x86_64-linux-gnu/7.1.0/cc1 $(GG_ROOT)/exe/bin/cc1
	cp $(SRCDIR)/inst/bin/gg-as $(GG_ROOT)/exe/bin/as

S3_ROOT=s3://gg-us-west-2/bin

update-s3:
	aws s3 cp $(SRCDIR)/inst/bin/gg-gcc $(S3_ROOT)/gcc
	aws s3 cp $(SRCDIR)/inst/libexec/gcc/x86_64-linux-gnu/7.1.0/cc1 $(S3_ROOT)/cc1
	aws s3 cp $(SRCDIR)/inst/bin/gg-as $(S3_ROOT)/as
