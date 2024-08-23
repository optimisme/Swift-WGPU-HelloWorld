import Foundation

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

    guard let resourcePath = Bundle.main.resourcePath else {
        print("Could not access bundle.")
        return nil
    }

    let resourcesPath = resourcePath + "/" + bundleID + ".resources"

    guard let resourceBundle = Bundle(path: resourcesPath) else {
        print("Could not find resources bundle.")
        return nil
    }
    
    guard let fileURL = resourceBundle.url(forResource: filePath, withExtension: nil) else {
        print("File not found: \(filePath)")
        return nil
    }
    
    do {
        let fileContents = try String(contentsOf: fileURL, encoding: .utf8)
        return fileContents
    } catch {
        print("Failed to read file: \(error)")
        return nil
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
        print("Error reding folder '\(directory)': \(error)")
    }
}

