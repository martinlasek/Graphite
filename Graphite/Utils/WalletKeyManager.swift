//
//  WalletKeyManager.swift
//  Graphite
//
//  Created by Martin Lasek on 8/21/22.
//

import Foundation
import SolanaSwift

struct WalletKeyManager {

    private enum Environment {
        static let privateKey = "PRIVATE_KEY"
        static let publicKey = "PUBLIC_KEY"
    }

    /// Retrieves the private key from the environment variable.
    /// The private key format is expected to look like: "[215,16,80,64,]"
    static func getPrivateKey() -> [UInt8]? {
        guard var privateKey = ProcessInfo.processInfo.environment[Environment.privateKey] else {
            printError(self, "Missing environment variable: \(Environment.privateKey)")
            return nil
        }

        privateKey.removeAll(where: { $0 == "[" || $0 == "]"})

        let privateKeyList: [UInt8] = privateKey.split(separator: ",").compactMap { UInt8($0.trimmingCharacters(in: CharacterSet.whitespaces)) }
        return privateKeyList
    }

    /// Returns the public key as a String.
    static func getPublicKeyString() -> String? {
        guard let publicKey = ProcessInfo.processInfo.environment[Environment.publicKey] else {
            printError(self, "Missing environment variable: \(Environment.publicKey)")
            return nil
        }

        return publicKey
    }

    /// Returns the public key as an object of `PublicKey`.
    static func getPublicKey() -> PublicKey? {
        guard let publicKey = try? PublicKey(string: getPublicKeyString()) else {
            return nil
        }

        return publicKey
    }
}
