import Foundation
import SDL2
import wgpu

func createRenderPipeline(device: WGPUDevice) -> WGPURenderPipeline {
    // WGSL shader source
    let vertexShaderSource = """
    @vertex
    fn vs_main(@builtin(vertex_index) in_vertex_index: u32) -> @builtin(position) vec4<f32> {
        let x = f32(i32(in_vertex_index) - 1);
        let y = f32(i32(in_vertex_index & 1u) * 2 - 1);
        return vec4<f32>(x, y, 0.0, 1.0);
    }
    """

    let fragmentShaderSource = """
    @fragment
    fn fs_main() -> @location(0) vec4<f32> {
        return vec4<f32>(1.0, 0.0, 0.0, 1.0);
    }
    """

    // Create shader modules
    let vertexShaderModule = createShaderModule(device: device, source: vertexShaderSource)
    let fragmentShaderModule = createShaderModule(device: device, source: fragmentShaderSource)

    // Set up the vertex state
    let entryPoint = getUtf8String(from: "vs_main")
    let vertexState = WGPUVertexState(
        nextInChain: nil,
        module: vertexShaderModule,
        entryPoint: entryPoint,
        constantCount: 0,
        constants: nil,
        bufferCount: 0,
        buffers: nil
    )

    // Set up the fragment state
    var colorTargetState = WGPUColorTargetState(
        nextInChain: nil,
        format: WGPUTextureFormat_BGRA8Unorm,
        blend: nil,
        writeMask: WGPUColorWriteMask_All.rawValue
    )
    let colorTargetStatePtr = withUnsafePointer(to: &colorTargetState) { $0 }
    let entryPointFragment = getUtf8String(from: "fs_main")
    var fragmentState = WGPUFragmentState(
        nextInChain: nil,
        module: fragmentShaderModule,
        entryPoint: entryPointFragment,
        constantCount: 0,
        constants: nil,
        targetCount: 1,
        targets: colorTargetStatePtr
    )

    let labelPtr = getUtf8String(from: "Simple Render Pipeline")
    let fragmentStatePtr: UnsafePointer<WGPUFragmentState>? = withUnsafePointer(to: &fragmentState) { $0 }
    var primitiveState = WGPUPrimitiveState(
        nextInChain: nil, 
        topology: WGPUPrimitiveTopology_TriangleList,
        stripIndexFormat: WGPUIndexFormat_Undefined,
        frontFace: WGPUFrontFace_CCW,
        cullMode: WGPUCullMode_None
    )
    let primitiveStatePtr = withUnsafePointer(to: &primitiveState) { $0 }
    var multisampleState = WGPUMultisampleState(
        nextInChain: nil, 
        count: 1,
        mask: ~0,
        alphaToCoverageEnabled: WGPUBool(false ? 1 : 0) 
    )
    let multisampleStatePtr = withUnsafePointer(to: &multisampleState) { $0 }
    var pipelineDescriptor = WGPURenderPipelineDescriptor(
        nextInChain: nil,
        label: labelPtr,
        layout: nil,
        vertex: vertexState,
        primitive: primitiveStatePtr.pointee,
        depthStencil: nil,
        multisample: multisampleStatePtr.pointee,
        fragment: fragmentStatePtr // Pass the pointer directly
    )

    return wgpuDeviceCreateRenderPipeline(device, &pipelineDescriptor)

}

func createShaderModule(device: WGPUDevice, source: String) -> WGPUShaderModule {
    let shaderSource = source.utf8CString
    let sourcePtr = shaderSource.withUnsafeBufferPointer { buffer in
        buffer.baseAddress
    }

    var sourceDescriptor = WGPUShaderModuleWGSLDescriptor(
        chain: WGPUChainedStruct(
            next: nil,
            sType: WGPUSType_ShaderModuleWGSLDescriptor
        ),
        code: sourcePtr
    )

    var descriptor = WGPUShaderModuleDescriptor(
        nextInChain: withUnsafePointer(to: &sourceDescriptor.chain) { $0 },
        label: nil,
        hintCount: 0,    // Set hintCount to 0
        hints: nil       // Set hints to nil
    )

    return wgpuDeviceCreateShaderModule(device, &descriptor)
}

