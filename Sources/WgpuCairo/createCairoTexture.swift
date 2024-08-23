import Foundation
import SDL2
import wgpu
import Cairo

func createCairoTexture(device: WGPUDevice, queue: WGPUQueue, width: Int, height: Int) -> WGPUTexture {

    // Crear la superfície Cairo
    let surface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, Int32(width), Int32(height))
    let cr = cairo_create(surface)

    // Cairo drawing
    cairo_set_source_rgb(cr, 0.0, 1.0, 0.0) // Verd
    cairo_paint(cr)

    // Dibuixar la línia vermella de punta a punta
    cairo_set_source_rgb(cr, 1.0, 0.0, 0.0)
    cairo_move_to(cr, 0, 0)
    cairo_line_to(cr, Double(width), Double(height))
    cairo_set_line_width(cr, 5.0)
    cairo_stroke(cr)

    cairo_set_source_rgb(cr, 0.0, 0.0, 0.0) // Negre
    cairo_select_font_face(cr, "Sans", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD)
    cairo_set_font_size(cr, 48)
    cairo_move_to(cr, 50, 100) 
    cairo_show_text(cr, "Hello WGPU")

    let status = cairo_status(cr)
    if status != CAIRO_STATUS_SUCCESS {
        print("Error drawing text: \(cairo_status_to_string(status)!)")
    }

    cairo_destroy(cr)

    // Obtenir les dades de la superfície
    let data = cairo_image_surface_get_data(surface)
    let stride = cairo_image_surface_get_stride(surface)
    let bufferSize = stride * Int32(height)

    // Crear una textura WGPU
    var textureDescriptor = WGPUTextureDescriptor(
        nextInChain: nil,
        label: nil,
        usage: WGPUTextureUsage_CopyDst.rawValue | WGPUTextureUsage_TextureBinding.rawValue,
        dimension: WGPUTextureDimension_2D,
        size: WGPUExtent3D(width: UInt32(width), height: UInt32(height), depthOrArrayLayers: 1),
        format: WGPUTextureFormat_BGRA8Unorm,
        mipLevelCount: 1,
        sampleCount: 1,
        viewFormatCount: 0,
        viewFormats: nil
    )
    let texture = wgpuDeviceCreateTexture(device, &textureDescriptor)
    
    // Transferir les dades a la textura WGPU
    var textureCopy = WGPUImageCopyTexture(
        nextInChain: nil,  // Afegir nil per a nextInChain
        texture: texture,
        mipLevel: 0,
        origin: WGPUOrigin3D(x: 0, y: 0, z: 0),
        aspect: WGPUTextureAspect_All
    )

    var dataLayout = WGPUTextureDataLayout(
        nextInChain: nil,  // Afegir nil per a nextInChain
        offset: 0,
        bytesPerRow: UInt32(stride),
        rowsPerImage: UInt32(height)
    )

    var extent = WGPUExtent3D(width: UInt32(width), height: UInt32(height), depthOrArrayLayers: 1)
    
    wgpuQueueWriteTexture(queue, &textureCopy, data, Int(bufferSize), &dataLayout, &extent)

    // Alliberar la superfície Cairo
    cairo_surface_destroy(surface)
    
    guard let texture = texture else {
        fatalError("Failed to create texture")
    }
    return texture
}
