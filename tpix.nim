# tpix - a simple terminal image viewer using the kitty graphics protocol
# See https://sw.kovidgoyal.net/kitty/graphics-protocol/ for details

import std / [
  termios,
  terminal,
  math,
  base64,
  strformat,
  strutils
],
  pixie,
  cligen


const
  escStart = "\e_G"
  escEnd = "\e\\"
  chunkSize = 4096

proc terminalWidthPixels(istty: bool): int =
  var winSize: IOctl_WinSize
  if ioctl(cint(not istty), TIOCGWINSZ, addr winsize) != -1:
    result = int(winsize.ws_xpixel)
  else:
    result = 0

proc add(result: var string, a: openArray[char]) =
  result.setLen result.len + a.len
  copyMem result[^a.len].addr, a[0].unsafeAddr, a.len

proc addChunk(result: var string, ctrlCode: string, imgData: openArray[char]) =
  result.add escStart
  result.add ctrlCode
  result.add imgData
  result.add escEnd

proc resizeImage(img: var Image, termWidth: int, noresize, fullwidth: bool, width, height: int) =
  var
    width = width
    height = height

  if width > 0 and height == 0:
    height = round(img.height.float*(width/img.width)).int
  elif height > 0 and width == 0:
    width = round(img.width.float*(height/img.height)).int
  elif img.width > termWidth and not noresize:
    width = termWidth
    height = round(img.height.float*(termWidth/img.width)).int
  elif fullwidth:
    width = termWidth
    height = round(img.height.float*(termWidth/img.width)).int

  if width != 0:
    img = img.resize(width, height)

proc addBackground(img: var Image) =
  let bgimg = newImage(img.width, img.height)
  bgimg.fill(rgba(255, 255, 255, 255))
  bgimg.draw(img)
  img = bgimg

proc renderImage(img: var Image) =
  let
    imgStr = encode(encodeImage(img, PngFormat))
    imgLen = imgStr.len

  var payload = newStringOfCap(imgLen)

  if imgLen <= chunkSize:
    var ctrlCode = "a=T,f=100;"
    payload.addChunk(ctrlCode, imgStr)
  else:
    var
      ctrlCode = "a=T,f=100,m=1;"
      chunk = chunkSize

    while chunk <= imgLen:
      if chunk == imgLen:
        break
      payload.addChunk(ctrlCode, imgStr.toOpenArray(chunk-chunkSize, chunk-1))
      ctrlCode = "m=1;"
      chunk += chunkSize

    ctrlCode = "m=0;"
    payload.addChunk(ctrlCode, imgStr.toOpenArray(chunk-chunkSize, imgLen-1))

  stdout.writeLine(payload)
  #stderr.write("Terminal width in pixels: ", terminalWidthPixels(istty), "\n")

proc processImage(img: var Image, background, noresize, fullwidth: bool,
  termWidth, width, height: int) =

  img.resizeImage(termWidth, noresize, fullwidth, width, height)
  if background:
    img.addBackground
  img.renderImage

proc tpix(
  files: seq[string],
  background = false, printname = false, noresize = false, fullwidth = false,
  width = 0, height = 0) =
  ## A simple terminal image viewer using the kitty graphics protocol

  let
    istty = stdin.isatty
    termWidth = terminalWidthPixels istty

  if not istty:
    if files.len > 0:
      stderr.write("Warning: Input file specified when receiving data from STDIN.\n")
      stderr.write("Only data from STDIN is shown.")
    try:
      if printname:
        echo "Data from STDIN."
      var image = stdin.readAll.decodeImage
      image.processImage(background, noresize, fullwidth, termWidth, width, height)
    except PixieError:
      quit("Error reading from STDIN.")
  else:
    if files.len == 0:
      quit("Provide 1 or more files as arguments or pipe image data to STDIN.")
    for filename in files:
      try:
        if printname:
          echo filename
        var image = filename.readImage
        image.processImage(background, noresize, fullwidth, termWidth, width, height)
      except PixieError:
        echo fmt"Error: {filename} can not be read."

clCfg.version = "1.0.1"
dispatch tpix,
  help = {
    "width": "Specify image width.",
    "height": "Specify image height.",
    "fullwidth": "Resize image to fill terminal width.",
    "noresize": "Disable automatic resizing.",
    "background": "Add white background if image is transparent.",
    "printname": "Print file name."
  }
