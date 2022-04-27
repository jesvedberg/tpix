#
# NimScript build file for tpix
#

--define:pixieUseStb

if defined(release) or defined(danger):
  --opt:speed

task build, "build tpix":
  exec "nim -d:release -d:pixieUseStb --opt:speed c tpix.nim"

task build_static, "build tpix as a static binary using musl":
  exec "nim --gcc.exe:musl-gcc --gcc.linkerexe:musl-gcc --passL:-static -d:release c tpix.nim"

task build_macos, "Build macos binary using zig":
  exec "nim c --cpu:arm64 --cc:clang --clang.exe=\"./zigcc.sh\" --clang.linkerexe=\"./zigcc.sh\" --passC:\"-target x86_64-macos\" --passL:\"-target x86_64-macos\" -d:release --opt:speed -o:tpix_macos -d:pixieUseStb tpix.nim"

task build_arm64, "Build arm64 binary using zig":
  exec "nim c --cpu:arm64 --cc:clang --clang.exe=\"./zigcc.sh\" --clang.linkerexe=\"./zigcc.sh\" --passC:\"-target aarch64-linux-musl\" --passL:\"-target aarch64-linux-musl\" -d:release --opt:speed -o:tpix_arm64 -d:pixieUseStb tpix.nim"