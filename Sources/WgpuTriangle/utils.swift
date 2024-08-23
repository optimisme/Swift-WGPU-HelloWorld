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