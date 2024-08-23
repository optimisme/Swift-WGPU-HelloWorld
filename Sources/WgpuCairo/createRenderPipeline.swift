import Foundation
import SDL2
import wgpu
import Cairo

func createRenderPipeline(device: WGPUDevice, texture: WGPUTexture) -> (WGPURenderPipeline, WGPUBindGroup) {

    let vertexShaderSource = readFile(named: "Assets/vertex_shader.wgsl")

    guard let vertexShaderSource = vertexShaderSource else {
        fatalError("Could not load vertex shader")
    }
    
    let fragmentShaderSource = readFile(named: "Assets/fragment_shader.wgsl")
    
    guard let fragmentShaderSource = fragmentShaderSource else {
        fatalError("Could not load fragment shader")
    }

    // Create shader modules
   // Create shader modules
    let vertexShaderModule = createShaderModule(device: device, source: vertexShaderSource)
    let fragmentShaderModule = createShaderModule(device: device, source: fragmentShaderSource)

    // Vertex state setup
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

    // Create blending state
    var blendState = WGPUBlendState(
        color: WGPUBlendComponent(
            operation: WGPUBlendOperation_Add,
            srcFactor: WGPUBlendFactor_SrcAlpha,
            dstFactor: WGPUBlendFactor_OneMinusSrcAlpha
        ),
        alpha: WGPUBlendComponent(
            operation: WGPUBlendOperation_Add,
            srcFactor: WGPUBlendFactor_One,
            dstFactor: WGPUBlendFactor_OneMinusSrcAlpha
        )
    )

    // Set up color target state with blending
    let colorTargetStatePtr = withUnsafePointer(to: &blendState) { $0 }
    let colorTargetState = WGPUColorTargetState(
        nextInChain: nil,
        format: WGPUTextureFormat_BGRA8Unorm,
        blend: colorTargetStatePtr,
        writeMask: WGPUColorWriteMask_All.rawValue
    )

    let colorTargetStates = [colorTargetState]
    let targetsPtr = colorTargetStates.withUnsafeBufferPointer { bufferPointer in
        bufferPointer.baseAddress
    }
    let entryPointFragment = getUtf8String(from: "fs_main")
    var fragmentState = WGPUFragmentState(
        nextInChain: nil,
        module: fragmentShaderModule,
        entryPoint: entryPointFragment,
        constantCount: 0,
        constants: nil,
        targetCount: 1,
        targets: targetsPtr 
    )

    // Pipeline descriptor
    let fragmentStatePtr = withUnsafePointer(to: &fragmentState) { $0 }
    var pipelineDescriptor = WGPURenderPipelineDescriptor(
        nextInChain: nil,
        label: getUtf8String(from: "Simple Render Pipeline"),
        layout: nil,
        vertex: vertexState,
        primitive: WGPUPrimitiveState(
            nextInChain: nil, 
            topology: WGPUPrimitiveTopology_TriangleList,
            stripIndexFormat: WGPUIndexFormat_Undefined,
            frontFace: WGPUFrontFace_CCW,
            cullMode: WGPUCullMode_None
        ),
        depthStencil: nil,
        multisample: WGPUMultisampleState(
            nextInChain: nil, 
            count: 1,
            mask: ~0,
            alphaToCoverageEnabled: WGPUBool(false ? 1 : 0) 
        ),
        fragment: fragmentStatePtr // Pass the address of fragment state
    )

    let renderPipeline = wgpuDeviceCreateRenderPipeline(device, &pipelineDescriptor)

    // Setup texture and sampler
    var textureViewDescriptor = WGPUTextureViewDescriptor(
        nextInChain: nil,
        label: nil,  // Passar nil si no es vol especificar cap etiqueta
        format: WGPUTextureFormat_BGRA8Unorm,
        dimension: WGPUTextureViewDimension_2D,
        baseMipLevel: 0,
        mipLevelCount: 1,
        baseArrayLayer: 0,
        arrayLayerCount: 1,
        aspect: WGPUTextureAspect_All
    )
    let textureView = wgpuTextureCreateView(texture, &textureViewDescriptor)
    
    var samplerDescriptor = WGPUSamplerDescriptor(
        nextInChain: nil,
        label: nil,  
        addressModeU: WGPUAddressMode_ClampToEdge,
        addressModeV: WGPUAddressMode_ClampToEdge,
        addressModeW: WGPUAddressMode_ClampToEdge,
        magFilter: WGPUFilterMode_Linear,
        minFilter: WGPUFilterMode_Linear,
        mipmapFilter: WGPUMipmapFilterMode_Linear, 
        lodMinClamp: 0.0,
        lodMaxClamp: 1.0,
        compare: WGPUCompareFunction_Undefined,  
        maxAnisotropy: 1
    )
    let sampler = wgpuDeviceCreateSampler(device, &samplerDescriptor)

    // Use withUnsafeBufferPointer to pass array bindings
    let bindings = [
        WGPUBindGroupEntry(
            nextInChain: nil,
            binding: 0,
            buffer: nil,
            offset: 0,
            size: 0,
            sampler: nil,
            textureView: textureView 
        ),
        WGPUBindGroupEntry(
            nextInChain: nil,
            binding: 1,
            buffer: nil,
            offset: 0,
            size: 0,
            sampler: sampler,
            textureView: nil
        )
    ]

    let bindGroup = bindings.withUnsafeBufferPointer { bufferPointer in
        var bindGroupDescriptor = WGPUBindGroupDescriptor(
            nextInChain: nil,
            label: nil,
            layout: wgpuRenderPipelineGetBindGroupLayout(renderPipeline, 0),
            entryCount: bufferPointer.count,
            entries: bufferPointer.baseAddress
        )
        return wgpuDeviceCreateBindGroup(device, &bindGroupDescriptor)
    }

    guard let renderPipeline = renderPipeline else {
        fatalError("Failed to create render pipeline")
    }

    guard let bindGroup = bindGroup else {
        fatalError("Failed to create bind group")
    }

    return (renderPipeline, bindGroup)

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