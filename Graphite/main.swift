//
//  main.swift
//  Graphite
//
//  Created by Martin Lasek on 8/20/22.
//

import Solana
import Foundation

let accountStorage = InMemoryAccountStorage()
let network = NetworkingRouter(endpoint: .mainnetBetaSolana)
var solana: Solana?

func getAccountInfo() {

  guard let secretKey = PrivateKeyManager.getPrivateKey() else {
    return
  }

  guard let account = Account(secretKey: Data(secretKey)) else {
    print("❌ Account creation failed.")
    return
  }

  let _ = accountStorage.save(account)

  solana = Solana(router: network, accountStorage: accountStorage)

  solana?.api.getAccountInfo(
    account: account.publicKey.base58EncodedString,
    decodedTo: AccountInfo.self
  ) { result in
    switch result {
    case .success(let bufferInfoAccountInfo):
      print("✅ got account \(bufferInfoAccountInfo.owner)")
    case .failure(let error):
      print("❌ Error: \(error.localizedDescription)")
    }
  }
}

getAccountInfo()

// Keeps the programm running.
RunLoop.main.run()
