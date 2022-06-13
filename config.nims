#
# NimScript build file for tpix
#

--d:pixieUseStb
--mm:arc

task build, "Build tpix":
  exec "nim -d:release c tpix.nim"

task build_debug, "Build tpix in debug mode":
  exec "nim c tpix.nim"

task build_static, "Build tpix as a static binary using musl":
  exec "nim --gcc.exe:musl-gcc --gcc.linkerexe:musl-gcc --passL:-static --passC:-flto -d:release c tpix.nim"

task xcompile_macos, "Cross compile intel MacOS binary using zig":
  exec "nim c --cpu:arm64 --cc:clang --clang.exe=\"./zigcc.sh\" --clang.linkerexe=\"./zigcc.sh\" --passC:\"-target x86_64-macos\" --passL:\"-target x86_64-macos\" -d:release -o:tpix_macos tpix.nim"

task xcompile_arm64, "Cross compile arm64 binary using zig":
  exec "nim c --cpu:arm64 --cc:clang --clang.exe=\"./zigcc.sh\" --clang.linkerexe=\"./zigcc.sh\" --passC:\"-target aarch64-linux-musl\" --passL:\"-target aarch64-linux-musl\" --passC:-flto -d:release -o:tpix_arm64 tpix.nim"
