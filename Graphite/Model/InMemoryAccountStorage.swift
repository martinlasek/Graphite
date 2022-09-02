//
//  InMemoryAccountStorage.swift
//  Graphite
//
//  Created by Martin Lasek on 9/1/22.
//

import SolanaSwift

final class InMemoryAccountStorageNEW: SolanaAccountStorage {
    private var _account: SolanaSwift.Account?
    func save(_ account: SolanaSwift.Account) throws {
        _account = account
    }

    var account: SolanaSwift.Account? {
        _account
    }
}
