import Foundation
import OpenSSL
import secp256k1

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
    
    public static func sha256ripemd160(_ data: Data) -> Data {
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

public enum ECC {
    public enum EllipticCurve {
        case secp256k1
    }
    
    public struct Key {
        public let curve: EllipticCurve
        public let priv: [UInt8]
        public var pub: [UInt8]
        
        public init(priv: [UInt8], curve: EllipticCurve = .secp256k1) {
            self.curve = curve
            self.priv = priv
            self.pub = Array(Key.computePublicKey(fromPrivateKey: Data(priv), compression: true))
        }
        
        private static func computePublicKey(fromPrivateKey privateKey: Data, compression: Bool) -> Data {
            let ctx = BN_CTX_new()
            defer {
                BN_CTX_free(ctx)
            }
            let key = EC_KEY_new_by_curve_name(NID_secp256k1)
            defer {
                EC_KEY_free(key)
            }
            let group = EC_KEY_get0_group(key)
            
            
            let prv = BN_new()
            defer {
                BN_free(prv)
            }
            privateKey.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
                BN_bin2bn(
                    ptr.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                    Int32(privateKey.count),
                    prv
                )
                return
            }
            
            let pub = EC_POINT_new(group)
            defer {
                EC_POINT_free(pub)
            }
            EC_POINT_mul(group, pub, prv, nil, nil, ctx)
            EC_KEY_set_private_key(key, prv)
            EC_KEY_set_public_key(key, pub)
            
            if compression {
                EC_KEY_set_conv_form(key, POINT_CONVERSION_COMPRESSED)
                var ptr: UnsafeMutablePointer<UInt8>? = nil
                let length = i2o_ECPublicKey(key, &ptr)
                return Data(bytes: ptr!, count: Int(length))
            } else {
                var result = [UInt8](repeating: 0, count: 65)
                let n = BN_new()
                defer {
                    BN_free(n)
                }
                EC_POINT_point2bn(group, pub, POINT_CONVERSION_UNCOMPRESSED, n, ctx)
                BN_bn2bin(n, &result)
                return Data(result)
            }
        }
    }
}
