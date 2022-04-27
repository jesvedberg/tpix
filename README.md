# tpix - a simple terminal image viewer using the kitty graphics protocol

`tpix` is a simple terminal image viewer written in [Nim](https://nim-lang.org/). It is compatible with terminal emulators that supports the [kitty graphics protocol](https://sw.kovidgoyal.net/kitty/graphics-protocol/) and uses the [Pixie](https://github.com/treeform/pixie) graphics library to read and render images. `tpix` is available as a statically linked single binary that is easy to deploy on remote systems where the user does not have root privileges.

`tpix` can view the following image formats: PNG, JPG, GIF (animated GIFs not supported), BMP, QOI, PPM and SVG (currently only limited support).

`tpix` has so far only been compiled on x86_64 Linux and it has been tested with [Kitty](https://sw.kovidgoyal.net/kitty/) and [Wezterm](https://wezfurlong.org/wezterm/). Viewing images in Wezterm is slightly buggy at the moment and only one image will be shown at the time. Neither Kitty nor WezTerm currently supports showing images when using terminal multiplexers, such as tmux or screen.

![tpix screenshot](docs/tpix_screenshot.png)

### Background

As a bioinformatician, I am often working on remote servers and clusters where I don't have root access. Sometimes when analyzing data I want to generate quick plots, and viewing these plots directly in the terminal over SSH is a nice workflow. I previously had a Mac and used iTerm2, which can show images by using a simple bash script that can easily be installed on any system. Recently I moved to a Linux laptop, where I've been using the Kitty terminal emulator. Kitty has support for viewing images in the terminal and also requires a program to be installed on the computer that wraps the image data in a format that Kitty can understand. Unlike in the case of iTerm2, I have not been able to find such a program that can easily be installed on remote systems without root access. I therefor decided to write my own solution, where I wanted to create a single dependency-free binary that can easily be copied and run from any modern Linux system. For this purpose I picked the Nim language, as it is a compiled language that makes it easy to generate statically linked binaries.

### Installation

**WARNING: This README file is still a work in progress and the installation instructions are still incomplete.**

A Linux 64-bit binary version that has been statically linked using musl is available at the release page. (Incomplete)

To compile tpix from source make sure you have the Nim compiler installed, together with the Nim libraries Pixie and Docopt. For a static build, [musl](https://musl.libc.org/) is also required. Clone this GitHub project and enter the directory. The build a dynamically linked executable use the following command:

```
nim build
```

and to build a statically linked version:

```
nim build_static
```

### Usage

By default `tpix` will show images that are smaller than the width of the terminal at their native size, and resize larger images to fit the terminal.

```
tpix image.jpg
```

Width and height can also be set manually, and resizing of large images can be turned off. `tpix` can also read image data from STDIN. Note that the image aspect ratio is preserved if only width or height is specified, but not if both of them are specified at the same time.

```
cat image.jpg | tpix
```

Full help message:

```
Usage:
  tpix [options] [FILE]

Options:
  -h --help             Show help message.
  --version             Show version.
  -n --noresize         Disable automatic resizing.
  -W --width WIDTH      Specify image width.
  -H --height HEIGHT    Specify image height.
  -b --background       Add white background if image is transparent.
  -p --printname        Print file name.
  -f --fullwidth        Resize image to fill terminal width.
```
