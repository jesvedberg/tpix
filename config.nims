#
# NimScript build file for tpix
#

task build, "build tpix":
  exec "nim -d:release -d:pixieUseStb --opt:speed c tpix.nim"

task build_static, "build tpix":
  exec "nim --gcc.exe:musl-gcc --gcc.linkerexe:musl-gcc --passL:-static -d:release -d:pixieUseStb --opt:speed c tpix.nim"