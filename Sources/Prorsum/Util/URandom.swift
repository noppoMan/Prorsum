#if os(Linux) || os(FreeBSD)
    import Glibc
#else
    import Darwin
#endif

/**
 URandom represents a file connection to /dev/urandom on Unix systems.
 /dev/urandom is a cryptographically secure random generator provided by the OS.
 */
public final class URandom {
    private let file = fopen("/dev/urandom", "r")
    
    /// Initialize URandom
    public init() {}
    
    deinit {
        fclose(file)
    }
    
    private func read(numBytes: Int) -> [Int8] {
        // Initialize an empty array with numBytes+1 for null terminated string
        var bytes = [Int8](repeating: 0, count: numBytes + 1)
        fgets(&bytes, Int32(numBytes + 1), file)
        bytes.removeLast()
        return bytes
    }
    
    /// Get a byte array of random UInt8s
    public func bytes(_ num: Int) -> [UInt8] {
        return read(numBytes: num).map({ UInt8(bitPattern: $0) })
    }
}
