//===----------------------------------------------------------------------===//
//
// This source file is part of the AWSSDKSwift open source project
//
// Copyright (c) 2017-2020 the AWSSDKSwift project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of AWSSDKSwift project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

// Replicating the CryptoKit framework interface for < macOS 10.15

#if !os(Linux)

import CommonCrypto
import protocol Foundation.DataProtocol

/// Protocol for Hashing function
public protocol HashFunction {
    /// associated digest object
    associatedtype Digest: AWSCrypto.Digest

    /// hash raw buffer
    static func hash(bufferPointer: UnsafeRawBufferPointer) -> Self.Digest

    /// initialization
    init()
    
    /// update hash function with data
    mutating func update(bufferPointer: UnsafeRawBufferPointer)
    /// finalize hash function and return digest
    mutating func finalize() -> Self.Digest
}

extension HashFunction {
    
    /// default version of hash which call init, update and finalize
    public static func hash(bufferPointer: UnsafeRawBufferPointer) -> Self.Digest {
        var function = Self()
        function.update(bufferPointer: bufferPointer)
        return function.finalize()
    }
    
    /// version of hash that takes data in any form that complies with DataProtocol
    public static func hash<D: DataProtocol>(data: D) -> Self.Digest {
        if let digest = data.withContiguousStorageIfAvailable({ bytes in
            return self.hash(bufferPointer: .init(bytes))
        }) {
            return digest
        } else {
            var buffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: data.count)
            data.copyBytes(to: buffer)
            defer { buffer.deallocate() }
            return self.hash(bufferPointer: .init(buffer))
        }
    }
    
    /// version of update that takes data in any form that complies with DataProtocol
    public mutating func update<D: DataProtocol>(data: D) {
        if let digest = data.withContiguousStorageIfAvailable({ bytes in
            return self.update(bufferPointer: .init(bytes))
        }) {
            return digest
        } else {
            var buffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: data.count)
            data.copyBytes(to: buffer)
            defer { buffer.deallocate() }
            self.update(bufferPointer: .init(buffer))
        }
    }
}

/// public protocol for Common Crypto hash functions
public protocol CCHashFunction: HashFunction {
    static var algorithm: CCHmacAlgorithm { get }
}


#endif
