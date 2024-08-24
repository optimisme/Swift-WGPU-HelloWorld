# Swift WGPU HelloWorld

This project demonstrates how to use WGPU in an SDL2 window from Swift. 

It works on macOS and Linux. 

The WGPU backend works on macOS with Metal and on Linux with Vulkan. For this reason, the dependencies are different.

## Install dependencies

### Linux
```bash
sudo apt-get install \
  libx11-dev \
  libcairo2-dev \
  libsdl2-dev \
  libvulkan-dev \
  libvulkan1
```

### macOS
```bash
brew install cairo sdl2
```

## How to run the example

Simple triangle (WgpuTriangle):
```bash
./buildTriangle.sh
```

Two triangles filled with one texture from a Cairo drawing (WgpuCairo):
```bash
./buildCairo.sh
```

## About WGPU binaries 

WGPU binaries are found in the **WGPU** folder and have been downloaded from:

[WGPU v0.19.4.1](https://github.com/gfx-rs/wgpu-native/releases)

## Screen capture of WgpuCairo

<img title="Screen capture of WgpuCairo" alt="Screen capture of WgpuCairo" src="./Images/captureWgpuCairo.png" style="max-width: 500px">
