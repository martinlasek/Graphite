//
//  InMemoryAccountStorage.swift
//  Graphite
//
//  Created by Martin Lasek on 8/21/22.
//

import Solana

final class InMemoryAccountStorage: SolanaAccountStorage {
  private var _account: Account?

  func save(_ account: Account) -> Result<Void, Error> {
    _account = account
    return .success(())
  }

  var account: Result<Account, Error> {
    if let account = _account {
      return .success(account)
    }
    return .failure(SolanaError.unauthorized)
  }

  func clear() -> Result<Void, Error> {
    _account = nil
    return .success(())
  }
}
