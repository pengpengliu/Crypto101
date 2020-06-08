import OpenSSL
import Foundation

public enum Hash {
    public static func sha1(_ data: Data) -> Data {
        var result = [UInt8](repeating: 0, count: Int(SHA_DIGEST_LENGTH))
        data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
            SHA1(ptr.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                 data.count,
                 &result)
            return
        }
        return Data(result)
    }
    
    public static func sha256(_ data: Data) -> Data {
        var result = [UInt8](repeating: 0, count: Int(SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
            SHA256(ptr.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                   data.count,
                   &result)
            return
        }
        return Data(result)
    }
    
    public static func ripemd160(_ data: Data) -> Data {
        var result = [UInt8](repeating: 0, count: Int(RIPEMD160_DIGEST_LENGTH))
        data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
            RIPEMD160(ptr.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                      data.count,
                      &result)
            return
        }
        return Data(result)
    }
    
    static func sha256ripemd160(_ data: Data) -> Data {
        return ripemd160(sha256(data))
    }
    
    public static func hmacsha512(_ data: Data, key: Data) -> Data {
        var length = UInt32(SHA512_DIGEST_LENGTH)
        var result = Data(count: Int(length))
        
        data.withUnsafeBytes { (dataPtr: UnsafeRawBufferPointer) in
            key.withUnsafeBytes { (keyPtr: UnsafeRawBufferPointer) in
                result.withUnsafeMutableBytes { (resultPtr: UnsafeMutableRawBufferPointer) in
                    HMAC(EVP_sha512(),
                         keyPtr.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                         Int32(key.count),
                         dataPtr.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                         data.count,
                         resultPtr.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                         &length)
                    return
                }
            }
        }
        return result
    }
}

extension Data {
    var hex: String {
        return reduce("") { $0 + String(format: "%02x", $1) }
    }
}
