//
//  QuoteRequest.swift
//  Graphite
//
//  Created by Martin Lasek on 8/23/22.
//

import Foundation

struct QuoteRequest {
    private let quoteUrlString = "https://quote-api.jup.ag/v1/quote"

    let inputMint: Mint
    let outputMint: Mint
    let amount: Amount
    let slippage: Slippage

    func createRequest() -> URLRequest? {
        guard var urlComponents = URLComponents(string: quoteUrlString) else {
            printError(self, "Could not create URLComponents with url: \(quoteUrlString)")
            return nil
        }

        let amountString = String(describing: amount.unitRepresentation)
        let slippageString = String(describing: slippage.value)

        let queryItems = [
            URLQueryItem(name: "inputMint", value: inputMint.rawValue),
            URLQueryItem(name: "outputMint", value: outputMint.rawValue),
            URLQueryItem(name: "amount", value: amountString),
            URLQueryItem(name: "slippage", value: slippageString)
        ]

        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            printError(self, "Could not get url from urlComponents: \(urlComponents.debugDescription)")
            return nil
        }

        return URLRequest(url: url)
    }
}

// MARK: - Mint

extension QuoteRequest {
    enum Mint: String {
        case sol = "So11111111111111111111111111111111111111112"
        case usdc = "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v"
        case usdt = "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB"
    }
}

// MARK: - Amount Conversioon

extension QuoteRequest {
    enum Amount {
        case sol(Int)
        case usdc(Int)
        case usdt(Int)

        var unitRepresentation: Int {
            switch self {
            case .sol(let amount):
                // 1 SOL = 1 Billion Lamports
                return amount * 1_000_000_000
            case .usdc(let amount):
                // 1 USDC = 1 Million units
                return amount * 1_000_000
            case .usdt(let amount):
                // 1 USDT = 1 Million units
                return amount * 1_000_000
            }
        }
    }
}

// MARK: - Slippage

extension QuoteRequest {
    enum Slippage {
        case percent(Float)

        var value: Float {
            switch self {
            case .percent(let value):
                return value
            }
        }
    }
}
