# tpix - a simple terminal image viewer using the kitty graphics protocol
# See https://sw.kovidgoyal.net/kitty/graphics-protocol/ for details

import
  termios,
  terminal,
  math,
  base64,
  strformat,
  strutils,
  pixie,
  docopt


const
  escStart = "\e_G"
  escEnd = "\e\\"
  chunkSize = 4096
  version = "1.0.1"


let doc = """
tpix - a simple terminal image viewer using the kitty graphics protocol

Usage:
  tpix [options] [FILE]...

Options:
  -h --help             Show help message.
  --version             Show version.
  -W --width WIDTH      Specify image width.
  -H --height HEIGHT    Specify image height.
  -f --fullwidth        Resize image to fill terminal width.
  -n --noresize         Disable automatic resizing.
  -b --background       Add white background if image is transparent.
  -p --printname        Print file name.
"""


proc terminalWidthPixels(istty = 0): int =
  var winSize: IOctl_WinSize
  if ioctl(cint(istty), TIOCGWINSZ, addr winsize) != -1:
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

proc resizeImage(img: var Image, args: Table[system.string, docopt.Value], termWidth: int) =
  var
    width = 0
    height = 0

  let resize =
    if args["--noresize"]: false
    else: true

  if args["--width"] and args["--height"]:
    try:
      width = parseInt($args["--width"])
      height = parseInt($args["--height"])
    except:
      quit("Error: WIDTH/HEIGHT not a valid integer.")
  elif args["--width"]:
    try:
      width = parseInt($args["--width"])
      height = round(img.height.float*(width/img.width)).int
    except:
      quit("Error: WIDTH not a valid integer.")
  elif args["--height"]:
    try:
      height = parseInt($args["--height"])
      width = round(img.width.float*(height/img.height)).int
    except:
      quit("Error: HEIGHT not a valid integer.")
  elif img.width > termWidth and resize:
    width = termWidth
    height = round(img.height.float*(termWidth/img.width)).int
  elif args["--fullwidth"]:
    width = termWidth
    height = round(img.height.float*(termWidth/img.width)).int
  
  if width != 0:
    img = img.resize(width, height)

proc addBackground(img: var Image) =
  let bgimg = newImage(img.width, img.height)
  bgimg.fill(rgba(255, 255, 255, 255))
  bgimg.draw(img)
  img = bgimg

proc renderImage(args: Table[system.string, docopt.Value], istty: int, filename = "") =
  var img =
    if istty == 1:
      try:
        decodeImage(stdin.readAll)
      except AssertionDefect:
        quit("Error reading from STDIN.")
    else:
      readImage(filename)
      
  let termWidth = terminalWidthPixels(istty)
  img.resizeImage(args, termWidth)

  if args["--background"]:
    img.addBackground()

  let
    imgStr = encode(encodeImage(img, PngFormat))
    imgLen = imgStr.len

  var payload = newStringOfCap(imgLen)

  if args["--printname"]:
    if istty == 1:
      echo "Image data from from stdin"
    else:
      echo filename

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


proc main() =
  let args = docopt(doc, version = fmt"tpix {version}")

  var istty = 0
  if not isatty(stdin):
    istty = 1
    if args["FILE"]:
      stderr.write("Warning: Input file specified when receiving data from STDIN.")
      stderr.write("Only data from STDIN is shown.")
    try:
      renderImage(args, istty)
    except:
      quit("Error reading from STDIN.")
  else:
    if not args["FILE"]:
      quit(doc)
    for filename in @(args["FILE"]): 
      try:
        renderImage(args, istty, filename)
      except:
        echo fmt"Error: {filename} can not be read."

main()
