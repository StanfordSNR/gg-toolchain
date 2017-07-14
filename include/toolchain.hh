#ifndef TOOLCHAIN_HH
#define TOOLCHAIN_HH

#include <unordered_map>
#include <string>

struct ToolchainProgram
{
  std::string path;
  std::string hash;
};

const ToolchainProgram & toolchain_program( const std::string & name )
{
  static const std::unordered_map<std::string, ToolchainProgram> programs = {
    { "strip", { "/home/sadjad/projects/gg-toolchain/bin/strip", "5ea6bc38f28bbd181fa3320a34f87eb2b8873dd27cd7bb978b5dc043b8370bbc" } },
    { "ar", { "/home/sadjad/projects/gg-toolchain/bin/ar", "74fea84ffcd0966d41b58cfaf06325a106998689a0594ec48d4efb3e0590a66c" } },
    { "ld", { "/home/sadjad/projects/gg-toolchain/bin/ld", "e15c10912363ce49f5a76272815ae253e5db6330783ca03c8321e177f44dcd40" } },
    { "ranlib", { "/home/sadjad/projects/gg-toolchain/bin/ranlib", "629ebcdf164667bd6641741360ff0477ef54beee241d26b61cb5ba660a289dc3" } },
    { "gcc", { "/home/sadjad/projects/gg-toolchain/bin/gcc", "ecf2e881316597d21f39381bce0338017c207895f0a428eb849c768782a58a17" } },
    { "as", { "/home/sadjad/projects/gg-toolchain/bin/as", "d7755c414c9b2f09410b5cf32a11aec4e25b1b4664ba29f158881b39396cace7" } },
    { "nm", { "/home/sadjad/projects/gg-toolchain/bin/nm", "4a17ade62890043f100d1d1970caebb3edc885be1fc627f5537589ca70d836eb" } },
    { "cc1", { "/home/sadjad/projects/gg-toolchain/bin/cc1", "58a6ef82495b5fce9f3d5d6e08c1a2cb2782f5f501b04ff296e2b0326c63ac23" } },
  };

  return programs.at( name );
}

#endif /* TOOLCHAIN_HH */
