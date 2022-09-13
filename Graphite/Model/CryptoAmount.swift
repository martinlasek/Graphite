//
//  CryptoAmount.swift
//  Graphite
//
//  Created by Martin Lasek on 9/1/22.
//

import Foundation

enum CryptoAmount {

    /// An real world representation like 1 or 2.50
    case full(Double)

    /// A unit representation like 1_000_000 (for a `full` 1 USDT)
    case unit(Int)

    func getUnitAmount(for cryptoCurrency: CryptoCurrency) -> Int {
        switch self {
        case .full(let amount):
            return Int(amount * calculate(with: cryptoCurrency.info.decimals))
        case .unit(let amount):
            return amount
        }
    }

    func getFullAmount(for cryptoCurrency: CryptoCurrency) -> Double {
        switch self {
        case .full(let amount):
            return amount
        case .unit(let amount):
            return Double(amount) / calculate(with: cryptoCurrency.info.decimals)
        }
    }

    private func calculate(with exponent: Int) -> Double {
        let exponentValue = pow(10, exponent) as NSNumber
        return exponentValue.doubleValue
    }
}
