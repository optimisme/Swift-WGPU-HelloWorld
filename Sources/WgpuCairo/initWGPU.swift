import Foundation
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

    return instance
}