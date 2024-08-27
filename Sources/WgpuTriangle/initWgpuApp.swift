import Foundation
import SwiftWgpuTools

func initWgpuApp(instance: WGPUInstance) -> (device: WGPUDevice, queue: WGPUQueue) {
    // Get an adapter
    var options = WGPURequestAdapterOptions(
        nextInChain: nil,
        compatibleSurface: nil,
        powerPreference: WGPUPowerPreference_HighPerformance,
        backendType: WGPUBackendType_Undefined,
        forceFallbackAdapter: WGPUBool(0)
    )

    var adapter: WGPUAdapter? = nil
    let adapterRD = RequestData(pointer: &adapter)
    wgpuInstanceRequestAdapter(instance, &options, requestAdapterCallback, adapterRD.getRawPointer())
    adapterRD.wait()

    guard let adapter = adapter else {
        fatalError("Failed to get WGPU adapter")
    }

    var properties = WGPUAdapterProperties()
    wgpuAdapterGetProperties(adapter, &properties)
    print("Selected adapter:")
    print("   Adapter Name: \(String(cString: properties.name))")
    print("   Vendor ID: \(properties.vendorID)")
    print("   Device ID: \(properties.deviceID)")
    print("   Backend Type: \(properties.backendType.rawValue)")

    listSupportedFeatures(adapter: adapter)

    // Request a device and queue from the adapter
    var deviceDescriptor = WGPUDeviceDescriptor(
        nextInChain: nil,
        label: nil,
        requiredFeatureCount: 0,
        requiredFeatures: nil,
        requiredLimits: nil,
        defaultQueue: WGPUQueueDescriptor(nextInChain: nil, label: nil),
        deviceLostCallback: nil,
        deviceLostUserdata: nil
    )

    var device: WGPUDevice? = nil
    let deviceRD = RequestData(pointer: &device)
    wgpuAdapterRequestDevice(adapter, &deviceDescriptor, requestDeviceCallback, deviceRD.getRawPointer())
    deviceRD.wait()

    guard let device = device else {
        fatalError("Failed to create WGPU device")
    }

    let queue = wgpuDeviceGetQueue(device)

    print("   Instance: \(instance)")
    print("   Device: \(device)")
    print("   Queue: \(queue!)")

    return (device, queue!)
}

func requestAdapterCallback(status: WGPURequestAdapterStatus, requestedElement: WGPUAdapter?, message: UnsafePointer<CChar>?, userData: UnsafeMutableRawPointer?) {
    print("Adapter callback executed with status: \(status.rawValue)")
    
    if let userData = userData {
        let requestData = Unmanaged<RequestData<WGPUAdapter>>.fromOpaque(userData).takeUnretainedValue()

        if status == WGPURequestAdapterStatus_Success {
            if let pointee = requestedElement {
                requestData.pointer.pointee = pointee
            } else {
                print("Adapter request failed: Adapter is nil")
            }
        } else {
            let errorMessage = message != nil ? String(cString: message!) : "Unknown error"
            print("Adapter request failed: \(errorMessage)")
        }

        print("Adapter Semaphore signal")
        requestData.resumeSignal()
    } else {
        print("Error: userData is nil")
    }
}

func requestDeviceCallback(status: WGPURequestDeviceStatus, requestedElement: WGPUDevice?, message: UnsafePointer<CChar>?, userData: UnsafeMutableRawPointer?) {
    print("Device callback executed with status: \(status.rawValue)")

    if let userData = userData {
        let requestData = Unmanaged<RequestData<WGPUDevice>>.fromOpaque(userData).takeUnretainedValue()

        if status == WGPURequestDeviceStatus_Success {
            if let pointee = requestedElement {
                requestData.pointer.pointee = pointee
            } else {
                print("Adapter request failed: Adapter is nil")
            }
        } else {
            let errorMessage = message != nil ? String(cString: message!) : "Unknown error"
            print("Adapter request failed: \(errorMessage)")
        }

        print("Device Semaphore signal")
        requestData.resumeSignal()
    } else {
        print("Error: userData is nil")
    }
}



// Function to list supported features
func listSupportedFeatures(adapter: WGPUAdapter) {

    var featuresCount: size_t = wgpuAdapterEnumerateFeatures(adapter, nil) // nil returns the size
    var featuresArray = [WGPUFeatureName](repeating: WGPUFeatureName_Undefined, count: Int(featuresCount))
    wgpuAdapterEnumerateFeatures(adapter, &featuresArray)

    // Example output to display supported features
    print("Supported Features:")
    for feature in featuresArray {
        switch feature {
        case WGPUFeatureName_Undefined:
            print(" * Undefined")
        case WGPUFeatureName_DepthClipControl:
            print(" * DepthClipControl")
        case WGPUFeatureName_TimestampQuery:
            print(" * TimestampQuery")
        case WGPUFeatureName_TextureCompressionBC:
            print(" * TextureCompressionBC")
        case WGPUFeatureName_TextureCompressionETC2:
            print(" * TextureCompressionETC2")
        case WGPUFeatureName_TextureCompressionASTC:
            print(" * TextureCompressionASTC")
        case WGPUFeatureName_IndirectFirstInstance:
            print(" * IndirectFirstInstance")
        case WGPUFeatureName_ShaderF16:
            print(" * ShaderF16")
        case WGPUFeatureName_RG11B10UfloatRenderable:
            print(" * RG11B10UfloatRenderable")
        case WGPUFeatureName_BGRA8UnormStorage:
            print(" * BGRA8UnormStorage")
        case WGPUFeatureName_Float32Filterable:
            print(" * Float32Filterable")
        default:
            print(" - Other feature: \(String(format: "0x%08X", feature.rawValue))") // Show in hex
        }
    }
}

func listSupportedNativeFeatures(adapter: WGPUAdapter) {

    //let featuresCount: size_t = wgpuAdapterEnumerateFeatures(adapter, nil) // nil returns the size
    //var featuresArray = [WGPUNativeFeature](repeating: WGPUNativeFeature_Force32, count: Int(featuresCount))
    //wgpuAdapterEnumerateFeatures(adapter, &featuresArray)
/*
    // Example output to display supported features
    print("Supported Features:")
    for feature in featuresArray {
        switch feature {
        case WGPUNativeFeature_PushConstants:
            print(" * WGPUNativeFeature_PushConstants")
        case WGPUNativeFeature_TextureAdapterSpecificFormatFeatures:
            print(" * WGPUNativeFeature_TextureAdapterSpecificFormatFeatures")
        case WGPUNativeFeature_MultiDrawIndirect:
            print(" * WGPUNativeFeature_MultiDrawIndirect")
        case WGPUNativeFeature_MultiDrawIndirectCount:
            print(" * WGPUNativeFeature_MultiDrawIndirectCount")
        case WGPUNativeFeature_VertexWritableStorage:
            print(" * WGPUNativeFeature_VertexWritableStorage")
        case WGPUNativeFeature_TextureBindingArray:
            print(" * WGPUNativeFeature_TextureBindingArray")
        case WGPUNativeFeature_SampledTextureAndStorageBufferArrayNonUniformIndexing:
            print(" * WGPUNativeFeature_SampledTextureAndStorageBufferArrayNonUniformIndexing")
        case WGPUNativeFeature_PipelineStatisticsQuery:
            print(" * WGPUNativeFeature_PipelineStatisticsQuery")
        case WGPUNativeFeature_StorageResourceBindingArray:
            print(" * WGPUNativeFeature_StorageResourceBindingArray")
        case WGPUNativeFeature_PartiallyBoundBindingArray:
            print(" * WGPUNativeFeature_PartiallyBoundBindingArray")
        default:
            print(" * Other feature: \(feature)")
        }
    }*/
}