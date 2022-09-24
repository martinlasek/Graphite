//
//  CoinListManager.swift
//  Graphite
//
//  Created by Daniel Stewart on 9/13/22.
//

import Foundation

struct CoinListManager {

    var listOfCoins: [CryptoCurrency.CryptoInfo]?

    init() {
        let jsonData = readLocalJSONFile(forName: "jupiter-tokens")
        if let data = jsonData {
            listOfCoins = parse(jsonData: data)
        }
    }

    func isCoinKnown(address: String) -> Bool {
        guard let coins = listOfCoins else { return false }
        return coins.compactMap { $0.address }.contains(address)
    }
}
