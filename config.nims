#
# NimScript build file for tpix
#

--d:pixieUseStb
--mm:arc

task build, "Build tpix":
  exec "nim -d:release c tpix.nim"

task build_debug, "Build tpix in debug mode":
  exec "nim c tpix.nim"
