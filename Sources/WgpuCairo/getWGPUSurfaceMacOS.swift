#if os(macOS)
import Foundation
import Cocoa
import Foundation
import QuartzCore
import SDL2
import SwiftWgpuTools

let BACKEND_CHAIN = WGPUSType_SurfaceDescriptorFromMetalLayer
let BACKEND_FLAGS = WGPUInstanceBackend_Metal.rawValue

func getWgpuSurface(instance: WGPUInstance, window: OpaquePointer) -> WGPUSurface? {
    var windowWMInfo = SDL_SysWMinfo()

    // Obtenim la informació de la finestra SDL
    windowWMInfo.version.major = Uint8(SDL_MAJOR_VERSION)
    windowWMInfo.version.minor = Uint8(SDL_MINOR_VERSION)
    windowWMInfo.version.patch = Uint8(SDL_PATCHLEVEL)

    SDL_GetWindowWMInfo(window, &windowWMInfo)

    guard let nsWindow = windowWMInfo.info.cocoa.window?.takeUnretainedValue() else {
        return nil
    }

    nsWindow.contentView?.wantsLayer = true
    let metalLayer = CAMetalLayer()
    nsWindow.contentView?.layer = metalLayer

    var metalLayerDesc = WGPUSurfaceDescriptorFromMetalLayer(
        chain: WGPUChainedStruct(next: nil, sType: WGPUSType_SurfaceDescriptorFromMetalLayer),
        layer: Unmanaged.passUnretained(metalLayer).toOpaque()
    )

    return withUnsafePointer(to: &metalLayerDesc.chain) { chainPtr in
        var surfaceDesc = WGPUSurfaceDescriptor(
            nextInChain: chainPtr,
            label: nil
        )
        return wgpuInstanceCreateSurface(instance, &surfaceDesc)
    }
}

#endif