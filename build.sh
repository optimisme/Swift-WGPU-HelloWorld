#!/bin/bash

# Reset the terminal
reset

# Clean the Swift build environment
swift package clean


# Build the project with Swift
# swift build --target WgpuTriangle

export RUST_BACKTRACE=1

swift run WgpuTriangle

