# Swift WGPU HelloWorld

This project demonstrates how to use WGPU in an SDL2 window from Swift. 

It works on macOS and Linux. 

The WGPU backend works on macOS with Metal and on Linux with Vulkan. For this reason, the dependencies are different.

## Install dependencies

### Linux
```bash
```

### macOS
```bash
brew install cairo
brew install sdl2
```

## How to run the project
```bash
./build.sh
```

## About WGPU binaries 

WGPU binaries are found in the **Frameworks** folder and have been downloaded from:

[WGPU v0.19.4.1](https://github.com/gfx-rs/wgpu-native/releases)