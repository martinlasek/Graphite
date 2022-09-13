//
//  CryptoCurrency.swift
//  Graphite
//
//  Created by Martin Lasek on 9/1/22.
//

import Foundation

enum CryptoCurrency {
    case btc
    case eth
    case sol
    case atlas
    case fida
    case mango
    case orca
    case oxy
    case polis
    case prt
    case ray
    case rin
    case slim
    case srm
    case step
    case usdc
    case usdt

    case unsupported(String)

    // Initialize by token address.
    init(with address: String) {
        switch address {
        case CryptoCurrency.btc.info.address:
            self = .btc
        case CryptoCurrency.eth.info.address:
            self = .eth
        case CryptoCurrency.sol.info.address:
            self = .sol
        case CryptoCurrency.atlas.info.address:
            self = .atlas
        case CryptoCurrency.fida.info.address:
            self = .fida
        case CryptoCurrency.mango.info.address:
            self = .mango
        case CryptoCurrency.orca.info.address:
            self = .orca
        case CryptoCurrency.oxy.info.address:
            self = .oxy
        case CryptoCurrency.polis.info.address:
            self = .polis
        case CryptoCurrency.prt.info.address:
            self = .prt
        case CryptoCurrency.ray.info.address:
            self = .ray
        case CryptoCurrency.rin.info.address:
            self = .rin
        case CryptoCurrency.slim.info.address:
            self = .slim
        case CryptoCurrency.srm.info.address:
            self = .srm
        case CryptoCurrency.step.info.address:
            self = .step
        case CryptoCurrency.usdc.info.address:
            self = .usdc
        case CryptoCurrency.usdt.info.address:
            self = .usdt

        default:
            self = .unsupported(address)
        }
    }
}

extension CryptoCurrency {
    struct CryptoInfo: Decodable {
        let chainId: Int
        let address: String
        let symbol: String
        let name: String
        let decimals: Int
    }

    var info: CryptoInfo {
        switch self {
        case .btc:
            return CryptoInfo(
                chainId: 101,
                address: "9n4nbM75f5Ui33ZbPYXn59EwSgE8CGsHtAeTH5YFeJ9E",
                symbol: "BTC",
                name: "Wrapped Bitcoin (Sollet)",
                decimals: 6
            )

        case .eth:
            return CryptoInfo(
                chainId: 101,
                address: "7vfCXTUXx5WJV5JADk17DUJ4ksgau7utNKj4b963voxs",
                symbol: "ETH",
                name: "Ether (Portal)",
                decimals: 8
            )
        case .atlas:
            return CryptoInfo(
                chainId: 101,
                address: "ATLASXmbPQxBUYbxPsV97usA3fPQYEqzQBUHgiFCUsXx",
                symbol: "ATLAS",
                name: "Star Atlas",
                decimals: 9
            )
        case .fida:
            return CryptoInfo(
                chainId: 101,
                address: "EchesyfXePKdLtoiZSL8pBe8Myagyy8ZRqsACNCFGnvp",
                symbol: "FIDA",
                name: "Bonfida",
                decimals: 6
            )
        case .mango:
            return CryptoInfo(
                chainId: 101,
                address: "7vfCXTUXx5WJV5JADk17DUJ4ksgau7utNKj4b963voxs",
                symbol: "MNGO",
                name: "Mango",
                decimals: 6
            )
        case .orca:
            return CryptoInfo(
                chainId: 101,
                address: "orcaEKTdK7LKz57vaAYr9QeNsVEPfiu6QeMU1kektZE",
                symbol: "ORCA",
                name: "Orca",
                decimals: 6
            )
        case .oxy:
            return CryptoInfo(
                chainId: 101,
                address: "z3dn17yLaGMKffVogeFHQ9zWVcXgqgf3PQnDsNs2g6M",
                symbol: "OXY",
                name: "Oxygen Protocol",
                decimals: 6
            )
        case .polis:
            return CryptoInfo(
                chainId: 101,
                address: "poLisWXnNRwC6oBu1vHiuKQzFjGL4XDSu4g9qjz9qVk",
                symbol: "POLIS",
                name: "Star Atlas DAO",
                decimals: 8
            )
        case .prt:
            return CryptoInfo(
                chainId: 101,
                address: "PRT88RkA4Kg5z7pKnezeNH4mafTvtQdfFgpQTGRjz44",
                symbol: "PRT",
                name: "Parrot Protocol",
                decimals: 6
            )
        case .ray:
            return CryptoInfo(
                chainId: 101,
                address: "4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R",
                symbol: "RAY",
                name: "Raydium",
                decimals: 6
            )
        case .rin:
            return CryptoInfo(
                chainId: 101,
                address: "E5ndSkaB17Dm7CsD22dvcjfrYSDLCxFcMd6z8ddCk5wp",
                symbol: "RIN",
                name: "Aldrin",
                decimals: 9
            )
        case .slim:
            return CryptoInfo(
                chainId: 101,
                address: "xxxxa1sKNGwFtw2kFn8XauW9xq8hBZ5kVtcSesTT9fW",
                symbol: "SLIM",
                name: "Solanium",
                decimals: 6
            )
        case .sol:
            return CryptoInfo(
                chainId: 101,
                address: "So11111111111111111111111111111111111111112",
                symbol: "SOL",
                name: "Wrapped SOL",
                decimals: 9
            )
        case .srm:
            return CryptoInfo(
                chainId: 103,
                address: "SRMuApVNdxXokk5GT7XD5cUUgXMBCoAz2LHeuAoKWRt",
                symbol: "SRM",
                name: "Serum",
                decimals: 6
            )
        case .step:
            return CryptoInfo(
                chainId: 103,
                address: "StepAscQoEioFxxWGnh2sLBDFp9d8rvKz2Yp39iDpyT",
                symbol: "STEP",
                name: "Step",
                decimals: 9
            )
        case .usdc:
            return CryptoInfo(
                chainId: 101,
                address: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
                symbol: "USDC",
                name: "USD Coin",
                decimals: 6
            )
        case .usdt:
            return CryptoInfo(
                chainId: 101,
                address: "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB",
                symbol: "USDT",
                name: "USDT",
                decimals: 6
            )

        case .unsupported(let address):
            return CryptoInfo(
                chainId: 0,
                address: address,
                symbol: "unknown",
                name: "unknown",
                decimals: 0
            )
        }
    }
}
