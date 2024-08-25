// swift-tools-version: 5.10
import PackageDescription

let wgpuBasePath = ".build/checkouts/SwiftWgpuTools/Sources/Libs/Wgpu/"

#if os(macOS)
let cairoPath = "Sources/Libs/Cairo/macOS"
let sdl2Path = "Sources/Libs/SDL2/macOS"
#elseif os(Linux)
let cairoPath = "Sources/Libs/Cairo/Linux"
let sdl2Path = "Sources/Libs/SDL2/Linux"
#endif

var dependencies: [Target.Dependency] = ["Cairo", "SDL2", "SwiftWgpuTools"]
var linkedLibraries: [LinkerSetting] = [
    .linkedLibrary("cairo"),
    .linkedLibrary("SDL2")
]

var swiftSettings: [SwiftSetting] = []
var linkerSettings: [LinkerSetting] = []

#if os(macOS)
let wgpuLibPath = wgpuBasePath + "/wgpu-macos-aarch64-release"
swiftSettings.append(.unsafeFlags(["-I/opt/homebrew/include/SDL2"]))
swiftSettings.append(.unsafeFlags(["-I" + wgpuLibPath + "/include"]))
linkerSettings.append(contentsOf: [
    .unsafeFlags(["-L/opt/homebrew/lib"]),
    .unsafeFlags(["-L" + wgpuLibPath]),
    .unsafeFlags(["-Xlinker", "-rpath", "-Xlinker", wgpuLibPath]),
    .linkedLibrary("wgpu_native")
])
#endif

#if os(Linux)
let wgpuLibPath = wgpuBasePath + "/wgpu-linux-x86_64-release"
swiftSettings.append(.unsafeFlags(["-I/usr/include/SDL2"]))
swiftSettings.append(.unsafeFlags(["-I" + wgpuLibPath + "/include"]))
linkerSettings.append(contentsOf: [
    .unsafeFlags(["-L/usr/lib"]),
    .unsafeFlags(["-L/usr/lib/x86_64-linux-gnu"]),
    .unsafeFlags(["-L" + wgpuLibPath]),
    .unsafeFlags(["-Xlinker", "-rpath", "-Xlinker", wgpuLibPath]),
    .linkedLibrary("wgpu_native")
])
dependencies.append("X11")
linkedLibraries.append(.linkedLibrary("X11"))
#endif

// Define the targets array
let targets: [Target] = [
    .executableTarget(
        name: "WgpuTriangle",
        dependencies: dependencies,
        path: "Sources/WgpuTriangle",
        swiftSettings: swiftSettings,
        linkerSettings: linkedLibraries + linkerSettings
    ),
    .executableTarget(
        name: "WgpuCairo",
        dependencies: dependencies,
        path: "Sources/WgpuCairo",
        resources: [
            .copy("Assets/")
        ],
        swiftSettings: swiftSettings,
        linkerSettings: linkedLibraries + linkerSettings
    ),
    .systemLibrary(
        name: "Cairo",
        path: cairoPath,
        pkgConfig: "cairo",
        providers: [
            .brew(["cairo"]),
            .apt(["libcairo2-dev"])
        ]
    ),
    .systemLibrary(
        name: "SDL2",
        path: sdl2Path,
        pkgConfig: "sdl2",
        providers: [
            .brew(["sdl2"]),
            .apt(["libsdl2-dev"])
        ]
    )
]

// Conditionally add X11 target for Linux
#if os(Linux)
let x11Target = Target.systemLibrary(
    name: "X11",
    path: "Sources/Libs/X11/Linux",
    pkgConfig: "x11",
    providers: [
        .apt(["libx11-dev"])
    ]
)
let finalTargets = targets + [x11Target]
#else
let finalTargets = targets
#endif

let package = Package(
    name: "WgpuHelloWorld",
    products: [
        .executable(
            name: "WgpuCairo",
            targets: ["WgpuCairo"]
        ),
        .executable(
            name: "WgpuTriangle",
            targets: ["WgpuTriangle"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/optimisme/SwiftWgpuTools.git", .upToNextMajor(from: "0.0.1"))
    ],
    targets: finalTargets
)
