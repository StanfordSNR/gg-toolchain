#!/bin/sh -xe

git submodule init
mkdir -p $(git rev-parse --git-dir)/modules

# shallow clone of gcc at tag gcc-7_1_0-release
git clone --depth 1 --branch gcc-7_1_0-release --separate-git-dir $(git rev-parse --git-dir)/modules/gcc https://github.com/gcc-mirror/gcc

# shallow clone of libgg (master)
git clone --depth 1 --branch master --separate-git-dir $(git rev-parse --git-dir)/modules/libgg https://github.com/stanfordsnr/libgg

# fetch gcc dependences
cd gcc && ./contrib/download_prerequisites
