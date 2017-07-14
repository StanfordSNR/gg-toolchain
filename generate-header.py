#!/usr/bin/env python2

from __future__ import print_function

import os
import sys
import hashlib

BINDIR = os.path.join(os.getcwd(), 'bin')

def sha256_checksum(filename, block_size=65536):
    sha256 = hashlib.sha256()

    with open(filename, 'rb') as f:
        for block in iter(lambda: f.read(block_size), b''):
            sha256.update(block)

    return sha256.hexdigest()

print("""\
#ifndef TOOLCHAIN_HH
#define TOOLCHAIN_HH
""")

print("#include <unordered_map>")
print("#include <string>")

print()

print("""\
const std::string & toolchain_program( const std::string & name )
{
  static const std::unordered_map<std::string, std::string> programs = {""")

for exe in os.listdir(BINDIR):
    exe_path = os.path.join(BINDIR, exe)
    exe_hash = sha256_checksum(exe_path)
    print(" " * 4, end='')
    print('{{ "{exe}", "{hash}" }},'.format(exe=exe, hash=exe_hash))

print("  };\n")
print("  return programs.at( name );")
print("}\n")

print("#endif /* TOOLCHAIN_HH */")
