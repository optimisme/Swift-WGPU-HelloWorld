import Foundation
import SDL2
import SwiftWgpuTools

func initWgpuWindow(device: WGPUDevice, window: OpaquePointer, instance: OpaquePointer) -> (surface: WGPUSurface, config: WGPUSurfaceConfiguration) {
    // Get a surface
    guard let surface = getWgpuSurface(instance: instance, window: window) else {
        fatalError("Failed to create WGPU surface")
    }

    // Get window size & scaleFactor
    var drawableSize = (width: Int32(0), height: Int32(0))
    SDL_GL_GetDrawableSize(window, &drawableSize.width, &drawableSize.height)
    drawableSize.width = max(drawableSize.width, 1)
    drawableSize.height = max(drawableSize.height, 1)

    var logicalSize = (width: Int32(0), height: Int32(0))
    SDL_GetWindowSize(window, &logicalSize.width, &logicalSize.height)
    logicalSize.width = max(logicalSize.width, 1)
    logicalSize.height = max(logicalSize.height, 1)

    let scaleFactor = Double(drawableSize.width) / Double(logicalSize.width)

    // Configure the surface
    var surfaceConfig = WGPUSurfaceConfiguration(
        nextInChain: nil,
        device: device,
        format: WGPUTextureFormat_BGRA8Unorm,
        usage: WGPUTextureUsage_RenderAttachment.rawValue,
        viewFormatCount: 0,
        viewFormats: nil,
        alphaMode: WGPUCompositeAlphaMode_Auto,
        width: UInt32(Double(logicalSize.width) * scaleFactor),
        height: UInt32(Double(logicalSize.height) * scaleFactor),
        presentMode: WGPUPresentMode_Fifo
    )

    // Configure the surface
    wgpuSurfaceConfigure(surface, &surfaceConfig)

    return (surface, surfaceConfig)
}
