import Foundation

class RequestData<T> {
    var pointer: UnsafeMutablePointer<T?>
    private var semaphore: DispatchSemaphore

    init(pointer: UnsafeMutablePointer<T?>) {
        self.pointer = pointer
        self.semaphore = DispatchSemaphore(value: 0)
    }

    func wait() {
        semaphore.wait()
    }

    func resumeSignal() {
        semaphore.signal()
    }

    func getRawPointer() -> UnsafeMutableRawPointer {
        return UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
    }
}

func getUtf8String(from swiftString: String) -> UnsafePointer<CChar>? {
    return swiftString.withCString { cString in
        if let copiedCString = strdup(cString) {
            return UnsafePointer(copiedCString)
        } else {
            return nil
        }
    }
}

func getStringFromUtf8(from cString: UnsafePointer<CChar>) -> String? {
    return String(validatingUTF8: cString)
}

func readFile(named filePath: String) -> String? {

    guard let bundlePath = Bundle.main.resourcePath else {
        fatalError("Could not access bundle.")
    }

    do {
        var foundContent: String? = nil
        let fileManager = FileManager.default
        let contents = try fileManager.contentsOfDirectory(atPath: bundlePath)
        let filteredContents = contents.filter { item in
            item.hasSuffix(".bundle") || item.hasSuffix(".resources")
        }

        for bundleName in filteredContents {
            let fullPath = "\(bundlePath)/\(bundleName)/\(filePath)"
            if FileManager.default.fileExists(atPath: fullPath) {
                do {
                    foundContent = try String(contentsOfFile: fullPath, encoding: .utf8)
                    break
                } catch {
                    print("Error llegint el fitxer: \(error.localizedDescription)")
                }
            }
        }

        if let content = foundContent {
            return content
        } else {
            fatalError("File not found: \(filePath)")
        }
    } catch {
        fatalError("Could not read path: \(error.localizedDescription)")
    }
}

func listBundle(directory: String) {

    guard let resourcePath = Bundle.main.resourcePath else {
        print("Could not access bundle.")
        return
    }
    
    let directoryURL = URL(fileURLWithPath: resourcePath).appendingPathComponent(directory)
    
    do {
        let fileManager = FileManager.default
        let contents = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil, options: [])
        
        if contents.isEmpty {
            print("Folder '\(directory)' is empty.")
        } else {
            print("Folder '\(directory)' contains:")
            for item in contents {
                if item.hasDirectoryPath {
                    print("[C] \(item.lastPathComponent)/")
                } else {
                    print("[F] \(item.lastPathComponent)")
                }
            }
        }
    } catch {
        fatalError("Error reading folder '\(directory)': \(error)")
    }
}

