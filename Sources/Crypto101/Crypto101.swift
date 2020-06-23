import Foundation
import secp256k1
import CryptoSwift

public enum Hash {
    public static func sha1(_ data: Data) -> Data {
        return data.sha1()
    }
    
    public static func sha1(_ bytes: [UInt8]) -> [UInt8] {
        return bytes.sha1()
    }
    
    public static func sha256(_ data: Data) -> Data {
        return data.sha256()
    }
    
    public static func sha256(_ bytes: [UInt8]) -> [UInt8] {
        return bytes.sha256()
    }
    
    public static func ripemd160(_ data: Data) -> Data {
        return RIPEMD.digest(input: data as NSData) as Data
    }

    public static func sha256ripemd160(_ data: Data) -> Data {
        return ripemd160(sha256(data))
    }
    
    public static func hmacsha512(_ data: Data, key: Data) throws -> Data {
        return try Data(HMAC(key: key.bytes, variant: .sha256).authenticate(data.bytes))
    }
}

public enum ECC {
    public enum EllipticCurve {
        case secp256k1
    }
    
    public enum CryptoError: Error {
        case signFailed
        case noEnoughSpace
        case signatureParseFailed
        case publicKeyParseFailed
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
        
        public func sign(data: [UInt8]) throws -> [UInt8] {
            return Array(try Key.signMessage(Data(data), withPrivateKey: Data(priv)))
        }
        
        private static func computePublicKey(fromPrivateKey privateKey: Data, compression: Bool) -> Data {
            let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN) | UInt32(SECP256K1_CONTEXT_VERIFY))!

            // *** Generate public key ***
            let pubKey = malloc(MemoryLayout<secp256k1_pubkey>.size)!.assumingMemoryBound(to: secp256k1_pubkey.self)
            
            // Cleanup
            defer {
                free(pubKey)
            }
             
            var secret = privateKey.bytes
            _ = secp256k1_ec_pubkey_create(ctx, pubKey, &secret)
                        
            var length = compression ? 33 : 65
            var result = [UInt8](repeating: 0, count: length)
            _ = secp256k1_ec_pubkey_serialize(ctx, &result, &length, pubKey, UInt32(compression ? SECP256K1_EC_COMPRESSED : SECP256K1_EC_UNCOMPRESSED))
            // First byte is header byte 0x04
            if (!compression) { result.remove(at: 0) }
            return Data(result)
        }
        
        private static func signMessage(_ data: Data, withPrivateKey privateKey: Data) throws -> Data {
            let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN))!
            defer { secp256k1_context_destroy(ctx) }

            let signature = UnsafeMutablePointer<secp256k1_ecdsa_signature>.allocate(capacity: 1)
            defer { signature.deallocate() }
            let status = data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
                privateKey.withUnsafeBytes {
                    secp256k1_ecdsa_sign(
                        ctx,
                        signature,
                        ptr.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                        $0.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                        nil,
                        nil
                    )
                }
            }
            guard status == 1 else { throw CryptoError.signFailed }

            let normalizedsig = UnsafeMutablePointer<secp256k1_ecdsa_signature>.allocate(capacity: 1)
            defer { normalizedsig.deallocate() }
            secp256k1_ecdsa_signature_normalize(ctx, normalizedsig, signature)

            var length: size_t = 128
            var der = Data(count: length)
            guard der.withUnsafeMutableBytes({
                return secp256k1_ecdsa_signature_serialize_der(
                    ctx,
                    $0.bindMemory(to: UInt8.self).baseAddress.unsafelyUnwrapped,
                    &length,
                    normalizedsig
                ) }) == 1 else { throw CryptoError.noEnoughSpace }
            der.count = length

            return der
        }
    }
}
