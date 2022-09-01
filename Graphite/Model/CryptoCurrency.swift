//
//  CryptoCurrency.swift
//  Graphite
//
//  Created by Martin Lasek on 9/1/22.
//

enum CryptoCurrency {
    enum Address: String {
        case sol = "So11111111111111111111111111111111111111112"
        case usdc = "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v"
        case usdt = "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB"
    }

    enum Precision {
        case unit(Int)
        case full(Double)
    }

    case sol(Precision)
    case usdc(Precision)
    case usdt(Precision)

    /// Returns the unit representation for a crypto currency.
    /// For example for `1 SOL` it returns `1_000_000_000` or for `1 USDT` it returns `1_000_000`.
    var unitRepresentation: Int {
        switch self {
        case .sol(let precision):

            switch precision {
            case .full(let amount):
                // 1 SOL = 1 Billion Lamports
                return Int(amount * 1_000_000_000)
            case .unit(let amount):
                return amount
            }

        case .usdc(let precision):
            switch precision {
            case .full(let amount):
                // 1 USDC = 1 Million units
                return Int(amount * 1_000_000)
            case .unit(let amount):
                return amount
            }

        case .usdt(let precision):
            switch precision {
            case .full(let amount):
                // 1 USDT = 1 Million units
                return Int(amount * 1_000_000)
            case .unit(let amount):
                return amount
            }
        }
    }
}
