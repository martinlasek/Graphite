//
//  QuoteRequest.swift
//  Graphite
//
//  Created by Martin Lasek on 8/23/22.
//

import Foundation

struct QuoteRequest: RequestGenerator {
    private let quoteUrlString = "https://quote-api.jup.ag/v1/quote"

    let inputMint: CryptoCurrency.Address
    let outputMint: CryptoCurrency.Address
    let inputAmount: CryptoCurrency
    let slippage: Slippage

    func createRequest() -> URLRequest? {
        guard var urlComponents = URLComponents(string: quoteUrlString) else {
            printError(self, "Could not create URLComponents with url: \(quoteUrlString)")
            return nil
        }

        let amountString = String(describing: inputAmount.unitRepresentation)
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
