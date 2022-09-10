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
    case none

    var symbol: String {
        switch self {
        case .sol:
            return "SOL"
        case .usdc:
            return "USDC"
        case .usdt:
            return "USDT"
        case .none:
            return ""
        }
    }

    // Initialize by token address.
    init(with address: String) {
        switch address {
        case CryptoCurrency.sol.address:
            self = .sol
        case CryptoCurrency.usdc.address:
            self = .usdc
        case CryptoCurrency.usdt.address:
            self = .usdt
        default:
            self = .none
        }
    }

    var address: String {
        switch self {
        case .sol:
            return "So11111111111111111111111111111111111111112"
        case .usdc:
            return "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v"
        case .usdt:
            return "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB"
        case .none:
            return ""
        }
    }

    var decimals: Double {
        switch self {
        case .sol:
            return 1_000_000_000
        case .usdc, .usdt:
            return 1_000_000
        case .none:
            return 0.0
        }
    }
}
