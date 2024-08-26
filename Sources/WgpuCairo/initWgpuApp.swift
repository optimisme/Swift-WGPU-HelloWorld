import Foundation
import SDL2
import SwiftWgpuTools

func initWgpuApp(instance: OpaquePointer) -> (device: WGPUDevice, queue: WGPUQueue) {
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