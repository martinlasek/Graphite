//
//  TransactionManager.swift
//  Graphite
//
//  Created by Martin Lasek on 9/8/22.
//

import SolanaSwift
import Foundation

struct TransactionManager {

    /// Creates a transaction, sets recent block hash, signs transaction and returns `PreparedTransaction`.
    static func createPreparedTransaction(with base64TransactionString: String, account: Account, and client: JSONRPCAPIClient) async throws -> PreparedTransaction {

        guard let data = Data(base64Encoded: base64TransactionString) else {
            throw SolanaError.unknown
        }

        let transaction = try Transaction.from(data: data)
        var preparedTX = PreparedTransaction(transaction: transaction, signers: [account], expectedFee: .zero)

        let recentBlockHash = try await client.getRecentBlockhash()

        preparedTX.transaction.recentBlockhash = recentBlockHash

        try preparedTX.sign()

        return preparedTX
    }
}
