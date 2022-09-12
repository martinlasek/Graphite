//
//  CryptoCurrency.swift
//  Graphite
//
//  Created by Martin Lasek on 9/1/22.
//

enum CryptoCurrency {
    case btc
    case eth
    case sol
    case oxy
    case ray
    case usdc
    case usdt

    case unsupported(String)

    // Initialize by token address.
    init(with address: String) {
        switch address {
        case CryptoCurrency.oxy.info.address:
            self = .oxy
        case CryptoCurrency.sol.info.address:
            self = .sol
        case CryptoCurrency.ray.info.address:
            self = .ray
        case CryptoCurrency.usdc.info.address:
            self = .usdc
        case CryptoCurrency.usdt.info.address:
            self = .usdt
        case CryptoCurrency.btc.info.address:
            self = .btc
        default:
            self = .unsupported(address)
        }
    }
}

extension CryptoCurrency {
    struct CryptoInfo {
        let chainId: Int
        let address: String
        let symbol: String
        let name: String
        let decimals: Int
        let logoUrlString: String
        let website: String
    }

    var info: CryptoInfo {
        switch self {
        case .oxy:
            return CryptoInfo(
                chainId: 101,
                address: "z3dn17yLaGMKffVogeFHQ9zWVcXgqgf3PQnDsNs2g6M",
                symbol: "OXY",
                name: "Oxygen Protocol",
                decimals: 1_000_000,
                logoUrlString: "https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/z3dn17yLaGMKffVogeFHQ9zWVcXgqgf3PQnDsNs2g6M/logo.svg",
                website: "https://www.oxygen.org/"
            )
        case .ray:
            return CryptoInfo(
                chainId: 101,
                address: "4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R",
                symbol: "RAY",
                name: "Raydium",
                decimals: 1_000_000,
                logoUrlString: "https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R/logo.png",
                website: "https://raydium.io/"
            )
        case .sol:
            return CryptoInfo(
                chainId: 101,
                address: "So11111111111111111111111111111111111111112",
                symbol: "SOL",
                name: "Wrapped SOL",
                decimals: 1_000_000_000,
                logoUrlString: "https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/So11111111111111111111111111111111111111112/logo.png",
                website: "https://solana.com/"
            )
        case .usdc:
            return CryptoInfo(
                chainId: 101,
                address: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
                symbol: "USDC",
                name: "USD Coin",
                decimals: 1_000_000,
                logoUrlString: "https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v/logo.png",
                website: "https://www.centre.io/"
            )
        case .usdt:
            return CryptoInfo(
                chainId: 101,
                address: "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB",
                symbol: "USDT",
                name: "USDT",
                decimals: 1_000_000,
                logoUrlString: "https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB/logo.svg",
                website: "https://tether.to/"
            )
        case .btc:
            return CryptoInfo(
                chainId: 101,
                address: "9n4nbM75f5Ui33ZbPYXn59EwSgE8CGsHtAeTH5YFeJ9E",
                symbol: "BTC",
                name: "Wrapped Bitcoin (Sollet)",
                decimals: 1_000_000,
                logoUrlString: "https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/9n4nbM75f5Ui33ZbPYXn59EwSgE8CGsHtAeTH5YFeJ9E/logo.png",
                website: "https://bitcoin.org/"
            )

        case .eth:
            return CryptoInfo(
                chainId: 101,
                address: "7vfCXTUXx5WJV5JADk17DUJ4ksgau7utNKj4b963voxs",
                symbol: "ETH",
                name: "Ether (Portal)",
                decimals: 100_000_000,
                logoUrlString: "https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/7vfCXTUXx5WJV5JADk17DUJ4ksgau7utNKj4b963voxs/logo.png",
                website: "https://ethereum.org/en/"
            )
        case .unsupported(let address):
            return CryptoInfo(
                chainId: 0,
                address: address,
                symbol: "unknown",
                name: "unknown",
                decimals: 0,
                logoUrlString: "unknown",
                website: "unknown"
            )
        }
    }
}
