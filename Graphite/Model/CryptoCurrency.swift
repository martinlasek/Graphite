//
//  CryptoCurrency.swift
//  Graphite
//
//  Created by Martin Lasek on 9/1/22.
//

enum CryptoCurrency {
    case sol
    case usdc
    case usdt

    var address: String {
        switch self {
        case .sol:
            return "So11111111111111111111111111111111111111112"
        case .usdc:
            return "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB"
        case .usdt:
            return "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v"
        }
    }

    var decimals: Double {
        switch self {
        case .sol:
            return 1_000_000_000
        case .usdc, .usdt:
            return 1_000_000
        }
    }
}
