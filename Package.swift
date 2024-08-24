// swift-tools-version: 5.10
import PackageDescription

let cairoPath: String
let sdl2Path: String
let vulkanPath: String?

#if os(macOS)
cairoPath = "Sources/Libs/Cairo/macOS"
sdl2Path = "Sources/Libs/SDL2/macOS"
vulkanPath = nil // Not used on macOS
#elseif os(Linux)
cairoPath = "Sources/Libs/Cairo/Linux"
sdl2Path = "Sources/Libs/SDL2/Linux"
vulkanPath = "Sources/Libs/Vulkan/Linux"
#endif

var dependencies: [Target.Dependency] = ["Cairo", "SDL2", "SwiftWgpuTools"]
var linkedLibraries: [LinkerSetting] = [
    .linkedLibrary("cairo"),
    .linkedLibrary("SDL2")
]

var swiftSettings: [SwiftSetting] = []
var linkerSettings: [LinkerSetting] = []

#if os(macOS)
swiftSettings.append(.unsafeFlags(["-I/opt/homebrew/include/SDL2"]))
swiftSettings.append(.unsafeFlags(["-I" + ".build/checkouts/SwiftWgpuTools/Sources/Libs/Wgpu/wgpu-macos-aarch64-release/include"]))
let wgpuLibPath = ".build/checkouts/SwiftWgpuTools/Sources/Libs/Wgpu/wgpu-macos-aarch64-release"
linkerSettings.append(contentsOf: [
    .unsafeFlags(["-L/opt/homebrew/lib"]),
    .unsafeFlags(["-L" + wgpuLibPath]),
    .unsafeFlags(["-Xlinker", "-rpath", "-Xlinker", wgpuLibPath]),
    .linkedLibrary("wgpu_native")
])
#endif

#if os(Linux)
swiftSettings.append(.unsafeFlags(["-I/usr/include/SDL2"]))
swiftSettings.append(.unsafeFlags(["-I/usr/include/vulkan"]))
swiftSettings.append(.unsafeFlags(["-I" + ".build/checkouts/SwiftWgpuTools/Sources/Libs/Wgpu/wgpu-linux-x86_64-release/include"]))
let wgpuLibPath = ".build/checkouts/SwiftWgpuTools/Sources/Libs/Wgpu/wgpu-linux-x86_64-release"
linkerSettings.append(contentsOf: [
    .unsafeFlags(["-L/usr/lib"]),
    .unsafeFlags(["-L/usr/lib/x86_64-linux-gnu"]),
    .unsafeFlags(["-L" + wgpuLibPath]),
    .unsafeFlags(["-Xlinker", "-rpath", "-Xlinker", wgpuLibPath]),
    .linkedLibrary("wgpu_native")
])
dependencies.append("Vulkan")
dependencies.append("X11")
linkedLibraries.append(.linkedLibrary("vulkan"))
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

// Conditionally add Vulkan target for Linux
#if os(Linux)
let vulkanTarget = Target.systemLibrary(
    name: "Vulkan",
    path: vulkanPath!,
    pkgConfig: "vulkan",
    providers: [
        .apt(["libvulkan-dev", "libvulkan1"])
    ]
)
let x11Target = Target.systemLibrary(
    name: "X11",
    path: "Sources/Libs/X11/Linux",
    pkgConfig: "x11",
    providers: [
        .apt(["libx11-dev"])
    ]
)
let finalTargets = targets + [vulkanTarget, x11Target]
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
        .package(url: "https://github.com/optimisme/SwiftWgpuTools.git", branch:"main")
    ],
    targets: finalTargets
)
