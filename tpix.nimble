# Package
version       = "1.0.3"
author        = "Jesper Svedberg"
description   = "Simple terminal image viewer using the kitty graphics protocol"
license       = "MIT"
bin           = @["tpix"]

# Dependencies
requires "nim >= 1.4.8"
requires "pixie"
requires "cligen"

task build_static, "Build tpix as a static binary using musl":
  exec "nimble c --gcc.exe:musl-gcc --gcc.linkerexe:musl-gcc --passL:-static --passC:-flto -d:release tpix.nim"

task xcompile_macos, "Cross compile intel MacOS binary using zig":
  exec "nimble c --cpu:arm64 --cc:clang --clang.exe=\"./zigcc.sh\" --clang.linkerexe=\"./zigcc.sh\" --passC:\"-target x86_64-macos\" --passL:\"-target x86_64-macos\" -d:release -o:tpix_macos tpix.nim"

task xcompile_arm64, "Cross compile arm64 binary using zig":
  exec "nimble c --cpu:arm64 --cc:clang --clang.exe=\"./zigcc.sh\" --clang.linkerexe=\"./zigcc.sh\" --passC:\"-target aarch64-linux-musl\" --passL:\"-target aarch64-linux-musl\" --passC:-flto -d:release -o:tpix_arm64 tpix.nim"


task release_static_all, "Compile and tar.gz static binaries for all platforms":
  let linux_x86 = "tpix-" & version & "-x86_64-linux.tar.gz"
  let macos_x86 = "tpix-" & version & "-x86_64-macosx.tar.gz"
  let linux_arm64 = "tpix-" & version & "-arm64-linux.tar.gz"
  exec "nimble build_static"
  exec "tar -czf " & linux_x86 & " tpix"
  exec "nimble xcompile_macos"
  exec "tar --transform='s|tpix_macos|tpix|' -czf " & macos_x86 & " tpix_macos"
  exec "nimble xcompile_arm64"
  exec "tar --transform='s|tpix_arm64|tpix|' -czf " & linux_arm64 & " tpix_arm64"
  exec "mv " & linux_x86 & " " & macos_x86 & " " & linux_arm64 & " releases/"