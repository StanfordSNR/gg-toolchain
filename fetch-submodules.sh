#!/bin/sh -xe

git submodule init gcc
mkdir -p $(git rev-parse --git-dir)/modules
git clone --depth 1 --branch gcc-6_3_0-release --separate-git-dir $(git rev-parse --git-dir)/modules/gcc https://github.com/gcc-mirror/gcc gcc
