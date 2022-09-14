//
//  CoinListManager.swift
//  Graphite
//
//  Created by Daniel Stewart on 9/13/22.
//

import Foundation

class CoinListManager {

    var listOfCoins: [CryptoCurrency.CryptoInfo] {
        var coins = [CryptoCurrency.CryptoInfo]()
        do {
            if let dataFromJsonString = coinList.data(using: .utf8) {
                coins = try JSONDecoder().decode([CryptoCurrency.CryptoInfo].self, from: dataFromJsonString)
            }
        } catch {
            fatalError("Failed to initialize Data with provided URL")
        }

        return coins
    }
}
