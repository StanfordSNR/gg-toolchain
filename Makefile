#!/usr/bin/make -f

SRCDIR  := $(shell pwd)
NCPU    := $(shell nproc)
GG_ROOT := $(HOME)/.gg

BUILD_DIR = build
LIBGG_DIR = $(BUILD_DIR)/libgg
GNU_TO_GG_GCC_DIR = $(BUILD_DIR)/gnu-to-gg-gcc
GG_BINUTILS_DIR = $(BUILD_DIR)/gg-binutils
GG_GCC_DIR = $(BUILD_DIR)/gg-gcc

export PATH := $(SRCDIR)/inst/bin:$(PATH)
export LD_LIBRARY_PATH := $(SRCDIR)/inst/lib:$(SRCDIR)/inst/x86_64-linux-musl/lib64

.PHONY: fetch-submodules create-folders gnu-to-gg-gcc gg-gcc gg-binutils \
	create-binutils-symlinks install

all: gg-binutils gg-gcc

fetch-submodules:
	./fetch-submodules.sh

create-folders:
	mkdir -p build
	mkdir -p inst/bin

libgg: fetch-submodules create-folders
	mkdir -p $(LIBGG_DIR)
	cd $(LIBGG_DIR) && \
		../../libgg/configure --prefix=$(SRCDIR)/inst --syslibdir=$(SRCDIR)/inst/lib && \
		make -j$(NCPU) && make install

create-binutils-symlinks: create-folders
	ln -sf /usr/bin/x86_64-linux-gnu-strip inst/bin/x86_64-linux-musl-strip
	ln -sf /usr/bin/x86_64-linux-gnu-ranlib inst/bin/x86_64-linux-musl-ranlib
	ln -sf /usr/bin/x86_64-linux-gnu-nm inst/bin/x86_64-linux-musl-nm
	ln -sf /usr/bin/x86_64-linux-gnu-ld inst/bin/x86_64-linux-musl-ld
	ln -sf /usr/bin/x86_64-linux-gnu-as inst/bin/x86_64-linux-musl-as
	ln -sf /usr/bin/x86_64-linux-gnu-ar inst/bin/x86_64-linux-musl-ar

gnu-to-gg-gcc: libgg create-binutils-symlinks
	mkdir -p $(GNU_TO_GG_GCC_DIR)
	cd $(GNU_TO_GG_GCC_DIR) && \
		../../gcc/configure --enable-languages=c,c++ --prefix=$(SRCDIR)/inst \
			--disable-multilib --disable-libsanitizer --disable-bootstrap --disable-nls \
			--program-prefix="gnu-to-gg-" --with-sysroot=$(SRCDIR)/inst \
			--with-native-system-header-dir=/include --build=x86_64-linux-gnu \
			--host=x86_64-linux-gnu --target=x86_64-linux-musl --enable-checking=release && \
		make -j$(NCPU) && make install

gg-binutils: gnu-to-gg-gcc
	mkdir -p $(GG_BINUTILS_DIR)
	cd $(GG_BINUTILS_DIR) && \
		../../binutils-gdb/configure --prefix=$(SRCDIR)/inst --disable-bootstrap \
			--disable-werror --disable-nls --build=x86_64-linux-musl \
			--host=x86_64-linux-musl --target=x86_64-linux-gnu --program-prefix="gg-" \
			--disable-shared \
			CC="gnu-to-gg-gcc -Wl,-I$(SRCDIR)/inst/lib/libc.so" \
			CXX="gnu-to-gg-g++ -Wl,-I$(SRCDIR)/inst/lib/libc.so"
	cd $(GG_BINUTILS_DIR) && make configure-host -j$(NCPU)
	cd $(GG_BINUTILS_DIR) && make LDFLAGS="-Wl,-static" -j$(NCPU)
	cd $(GG_BINUTILS_DIR) && make install

gg-gcc: gnu-to-gg-gcc
	mkdir -p $(GG_GCC_DIR)
	cd $(GG_GCC_DIR) && \
		../../gcc/configure --enable-languages=c,c++ --prefix=$(SRCDIR)/inst \
			--with-boot-ldflags=-static --with-stage1-ldflags=-static \
			--disable-multilib --disable-bootstrap --disable-nls --program-prefix="gg-" \
			--with-sysroot=/ --build=x86_64-linux-musl --host=x86_64-linux-musl \
			--target=x86_64-linux-gnu --enable-checking=release \
			CC="gnu-to-gg-gcc -Wl,-I$(SRCDIR)/inst/lib/libc.so" \
			CXX="gnu-to-gg-g++ -Wl,-I$(SRCDIR)/inst/lib/libc.so" && \
		make -j$(NCPU) && make install-strip

install:
	mkdir -p $(GG_ROOT)/bin
	cp $(SRCDIR)/inst/bin/gg-gcc $(GG_ROOT)/bin/gcc
	cp $(SRCDIR)/inst/libexec/gcc/x86_64-linux-gnu/7.1.0/cc1 $(GG_ROOT)/bin/cc1
	cp $(SRCDIR)/inst/bin/gg-as $(GG_ROOT)/bin/as

S3_ROOT = s3://gg-us-west-2/bin

update-s3:
	aws s3 cp --acl public-read $(SRCDIR)/inst/bin/gg-gcc $(S3_ROOT)/gcc
	aws s3 cp --acl public-read $(SRCDIR)/inst/libexec/gcc/x86_64-linux-gnu/7.1.0/cc1 $(S3_ROOT)/cc1
	aws s3 cp --acl public-read $(SRCDIR)/inst/bin/gg-as $(S3_ROOT)/as
