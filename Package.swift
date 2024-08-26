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
#if os(Linux)
dependencies.append("X11")
#endif

var linkedLibraries: [LinkerSetting] = [
    .linkedLibrary("cairo"),
    .linkedLibrary("SDL2")
]
#if os(Linux)
linkedLibraries.append(.linkedLibrary("X11"))
#endif

var linkerSettings: [LinkerSetting] = []
#if os(macOS)
linkerSettings.append(contentsOf: [
    .unsafeFlags(["-L/opt/homebrew/lib"]),
    .unsafeFlags(["-Xlinker", "-rpath", "-Xlinker", wgpuBasePath + "/wgpu-macos-aarch64-release"]),
    .linkedLibrary("wgpu_native")
])
#endif

// Define the targets array
var targets: [Target] = [
    .executableTarget(
        name: "WgpuTriangle",
        dependencies: dependencies,
        path: "Sources/WgpuTriangle",
        linkerSettings: linkedLibraries + linkerSettings
    ),
    .executableTarget(
        name: "WgpuCairo",
        dependencies: dependencies,
        path: "Sources/WgpuCairo",
        resources: [
            .copy("Assets/")
        ],
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

#if os(Linux)
targets.append(Target.systemLibrary(
    name: "Vulkan",
    path: vulkanPath,
    pkgConfig: "vulkan",
    providers: [
        .apt(["libvulkan-dev", "libvulkan1"])
    ]
))
targets.append(Target.systemLibrary(
    name: "X11",
    path: "Sources/Libs/X11/Linux",
    pkgConfig: "x11",
    providers: [
        .apt(["libx11-dev"])
    ]
))
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
        .package(url: "https://github.com/optimisme/SwiftWgpuTools.git", .upToNextMajor(from: "0.0.2"))
    ],
    targets: targets
)
