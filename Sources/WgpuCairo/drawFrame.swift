import Foundation
import SDL2
import SwiftWgpuTools

func drawFrame(surface: WGPUSurface, device: WGPUDevice, queue: WGPUQueue, config: WGPUSurfaceConfiguration, renderPipeline: WGPURenderPipeline, bindGroup: WGPUBindGroup) {

    var surfaceTexture = WGPUSurfaceTexture()
    wgpuSurfaceGetCurrentTexture(surface, &surfaceTexture)
    
    if surfaceTexture.texture == nil {
        print("Failed to acquire next surface texture!")
        return
    }

    let view = wgpuTextureCreateView(surfaceTexture.texture, nil)
    var encoderDescriptor = WGPUCommandEncoderDescriptor(nextInChain: nil, label: nil)

    var colorAttachment = WGPURenderPassColorAttachment(
        nextInChain: nil,
        view: view,
        resolveTarget: nil,
        loadOp: WGPULoadOp_Clear,
        storeOp: WGPUStoreOp_Store,
        clearValue: WGPUColor(r: 0.0, g: 0.0, b: 1.0, a: 1.0)
    )

    let colorAttachmentPointer = withUnsafePointer(to: &colorAttachment) { $0 }

    var renderPassDescriptor = WGPURenderPassDescriptor(
        nextInChain: nil,
        label: nil,
        colorAttachmentCount: 1,
        colorAttachments: colorAttachmentPointer,
        depthStencilAttachment: nil,
        occlusionQuerySet: nil,
        timestampWrites: nil
    )

    let encoder = wgpuDeviceCreateCommandEncoder(device, &encoderDescriptor)

    let renderPass = wgpuCommandEncoderBeginRenderPass(encoder, &renderPassDescriptor)
    wgpuRenderPassEncoderSetPipeline(renderPass, renderPipeline)
    wgpuRenderPassEncoderSetBindGroup(renderPass, 0, bindGroup, 0, nil) // Associar la textura i el sampler
    wgpuRenderPassEncoderDraw(renderPass, 6, 1, 0, 0) // Dibuixa 6 vèrtexs (dos triangles)
    wgpuRenderPassEncoderEnd(renderPass)

    var commandBuffer = wgpuCommandEncoderFinish(encoder, nil)
    wgpuQueueSubmit(queue, 1, &commandBuffer)
    wgpuSurfacePresent(surface)
}


