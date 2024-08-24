#if os(Linux)
import Foundation
import SDL2
import SwiftWgpuTools
import X11

let BACKEND_CHAIN = WGPUSType_SurfaceDescriptorFromXlibWindow
let BACKEND_FLAGS = WGPUInstanceBackend_Vulkan.rawValue

func getWGPUSurface(instance: WGPUInstance, window: OpaquePointer) -> WGPUSurface? {
    var windowWMInfo = SDL_SysWMinfo()

    // Obtenim la informació de la finestra SDL
    windowWMInfo.version.major = Uint8(SDL_MAJOR_VERSION)
    windowWMInfo.version.minor = Uint8(SDL_MINOR_VERSION)
    windowWMInfo.version.patch = Uint8(SDL_PATCHLEVEL)

    SDL_GetWindowWMInfo(window, &windowWMInfo)

    // Verifiquem que el sistema de finestres és X11
    guard let display = windowWMInfo.info.x11.display else {
        fatalError("No s'ha pogut obtenir el display de X11")
    }

    let window = windowWMInfo.info.x11.window

    // Creem la descripció de la superfície Xlib
    var xlibSurfaceDesc = WGPUSurfaceDescriptorFromXlibWindow(
        chain: WGPUChainedStruct(next: nil, sType: WGPUSType_SurfaceDescriptorFromXlibWindow),
        display: UnsafeMutableRawPointer(display),
        window: UInt64(window) // Convertim a UInt64
    )

    // Creem la superfície utilitzant el descritor
    return withUnsafePointer(to: &xlibSurfaceDesc.chain) { chainPtr in
        var surfaceDesc = WGPUSurfaceDescriptor(
            nextInChain: chainPtr, // Utilitzem el punter a la cadena
            label: nil
        )
        return wgpuInstanceCreateSurface(instance, &surfaceDesc)
    }
}
#endif