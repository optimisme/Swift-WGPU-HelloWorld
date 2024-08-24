import Foundation
import SDL2
import SwiftWgpuTools

func main() {

    initSDL()

    let window = initWindow()
    let (surface, device, queue, config) = initWGPU(window: window)
    let renderPipeline = createRenderPipeline(device: device)

    mainLoop(window: window, surface: surface, device: device, queue: queue, config: config, renderPipeline: renderPipeline)

    cleanup(window: window)
}

func initSDL() {
    SDL_SetHint(SDL_HINT_VIDEO_HIGHDPI_DISABLED, "0")
    if SDL_Init(SDL_INIT_VIDEO) != 0 {
        fatalError("Could not initialize SDL! SDL_Error: \(String(cString: SDL_GetError()))")
    }
}

func initWindow() -> OpaquePointer {
    guard let window = SDL_CreateWindow(
        "SDL WGPU Test",
        Int32(SDL_WINDOWPOS_UNDEFINED_MASK),
        Int32(SDL_WINDOWPOS_UNDEFINED_MASK),
        800,
        600,
        SDL_WINDOW_ALLOW_HIGHDPI.rawValue | SDL_WINDOW_SHOWN.rawValue | SDL_WINDOW_RESIZABLE.rawValue
    ) else {
        SDL_Quit()
        fatalError("Window could not be created! SDL_Error: \(String(cString: SDL_GetError()))")
    }

    return window
}

func mainLoop(window: OpaquePointer, surface: WGPUSurface, device: WGPUDevice, queue: WGPUQueue, config: WGPUSurfaceConfiguration, renderPipeline: WGPURenderPipeline) {

    var config = config
    var size = (width: Int32(config.width), height: Int32(config.height))
    var event = SDL_Event()
    
    while true {
        while SDL_PollEvent(&event) != 0 {
            switch SDL_EventType(rawValue: event.type) {
            case SDL_WINDOWEVENT:
                if event.window.event == SDL_WINDOWEVENT_SIZE_CHANGED.rawValue {
                    size.width = max(event.window.data1, 1)
                    size.height = max(event.window.data2, 1)
                    config.width = UInt32(size.width)
                    config.height = UInt32(size.height)
                    wgpuSurfaceConfigure(surface, &config)
                    
                    // Force window redraw after window size changed
                    var exposeEvent = SDL_Event()
                    exposeEvent.type = SDL_WINDOWEVENT.rawValue
                    exposeEvent.window.windowID = SDL_GetWindowID(window)
                    exposeEvent.window.event = Uint8(SDL_WINDOWEVENT_EXPOSED.rawValue)
                    
                    SDL_PushEvent(&exposeEvent)
                }

            case SDL_QUIT:
                return
            default:
                break
            }
        }

        drawFrame(surface: surface, device: device, queue: queue, config: config, renderPipeline: renderPipeline)
    }
}

func cleanup(window: OpaquePointer) {
    // TODO clean up WGPU
    SDL_DestroyWindow(window)
    SDL_Quit()
}

main()