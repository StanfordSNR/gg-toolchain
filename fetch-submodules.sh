#!/bin/sh -xe

git submodule init
mkdir -p $(git rev-parse --git-dir)/modules

# shallow clone of gcc at tag gcc-7_1_0-release
git clone --depth 1 --branch gcc-7_1_0-release --separate-git-dir $(git rev-parse --git-dir)/modules/gcc https://github.com/gcc-mirror/gcc

# shallow clone of musl at tag v1.1.16
git clone --depth 1 --branch v1.1.16 --separate-git-dir $(git rev-parse --git-dir)/modules/musl git://git.musl-libc.org/musl
