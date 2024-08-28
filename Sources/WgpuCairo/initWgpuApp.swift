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

    // Request a device and queue from the adapter
    var requiredFeatures: [WGPUFeatureName] = []
    requiredFeatures.append(WGPUFeatureName_DepthClipControl)
    requiredFeatures.append(WGPUFeatureName_TextureCompressionBC)
    requiredFeatures.append(WGPUFeatureName(rawValue: WGPUNativeFeature_VertexWritableStorage.rawValue))

    var deviceDescriptor = WGPUDeviceDescriptor(
        nextInChain: nil,
        label: nil,
        requiredFeatureCount: requiredFeatures.count,
        requiredFeatures: requiredFeatures.withUnsafeBufferPointer { $0.baseAddress },
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

    return (device, queue!)
}

func requestAdapterCallback(status: WGPURequestAdapterStatus, requestedElement: WGPUAdapter?, message: UnsafePointer<CChar>?, userData: UnsafeMutableRawPointer?) {
    
    if let userData = userData {
        let requestData = Unmanaged<RequestData<WGPUAdapter>>.fromOpaque(userData).takeUnretainedValue()

        if status == WGPURequestAdapterStatus_Success {
            if let pointee = requestedElement {
                requestData.pointer.pointee = pointee
            } else {
                fatalError("Adapter request failed: Adapter is nil")
            }
        } else {
            let errorMessage = message != nil ? String(cString: message!) : "Unknown error"
            fatalError("Adapter request failed: \(errorMessage)")
        }

        requestData.resumeSignal()
    } else {
        fatalError("Error: Adapter userData is nil")
    }
}

func requestDeviceCallback(status: WGPURequestDeviceStatus, requestedElement: WGPUDevice?, message: UnsafePointer<CChar>?, userData: UnsafeMutableRawPointer?) {

    if let userData = userData {
        let requestData = Unmanaged<RequestData<WGPUDevice>>.fromOpaque(userData).takeUnretainedValue()

        if status == WGPURequestDeviceStatus_Success {
            if let pointee = requestedElement {
                requestData.pointer.pointee = pointee
            } else {
                fatalError("Device request failed: Device is nil")
            }
        } else {
            let errorMessage = message != nil ? String(cString: message!) : "Unknown error"
            fatalError("Device request failed: \(errorMessage)")
        }

        requestData.resumeSignal()
    } else {
        fatalError("Error: Device userData is nil")
    }
}