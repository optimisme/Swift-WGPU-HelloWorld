import Foundation
import SDL2
import SwiftWgpuTools

func initWgpu() -> WGPUInstance {
    // Create WGPU instance
    var extras = WGPUInstanceExtras(
        chain: WGPUChainedStruct(next: nil, sType: BACKEND_CHAIN),
        backends: WGPUInstanceBackendFlags(BACKEND_FLAGS),
        flags: 0,
        dx12ShaderCompiler: WGPUDx12Compiler_Dxc,
        gles3MinorVersion: WGPUGles3MinorVersion_Automatic,
        dxilPath: nil,
        dxcPath: nil
    )

    var descriptor = withUnsafePointer(to: &extras.chain) { chainPointer in WGPUInstanceDescriptor(nextInChain: chainPointer) }
    guard let instance = withUnsafePointer(to: &descriptor, { wgpuCreateInstance($0) }) else {
        fatalError("Could not initialize WGPU instance")
    }

    print("Available adapters:")
    
    let backendFlags: WGPUInstanceBackendFlags = WGPUInstanceBackendFlags(BACKEND_FLAGS)
    var enumerateOptions = WGPUInstanceEnumerateAdapterOptions(nextInChain: nil, backends: backendFlags)
    let adapterCount = wgpuInstanceEnumerateAdapters(instance, &enumerateOptions, nil)
    var adapters: [WGPUAdapter?] = Array(repeating: nil, count: Int(adapterCount))
    let bufferPointer = adapters.withUnsafeMutableBufferPointer { $0 }
    wgpuInstanceEnumerateAdapters(instance, &enumerateOptions, bufferPointer.baseAddress)

    for adapter in adapters {
        if let adapter = adapter {
            var properties = WGPUAdapterProperties()
            wgpuAdapterGetProperties(adapter, &properties)
            print("   \(String(cString: properties.name))")
        }
    }

    return instance
}