//
//  QuoteRequest.swift
//  Graphite
//
//  Created by Martin Lasek on 8/23/22.
//

import Foundation

struct QuoteRequest: RequestGenerator {
    private let quoteUrlString = "https://quote-api.jup.ag/v1/quote"

    let inputMint: CryptoCurrency
    let outputMint: CryptoCurrency
    let inputAmount: CryptoAmount
    let slippage: Slippage
    let publicKey: String
    let onlyDirectRoutes: Bool

    func createRequest() -> URLRequest? {
        guard var urlComponents = URLComponents(string: quoteUrlString) else {
            printError(self, "Could not create URLComponents with url: \(quoteUrlString)")
            return nil
        }

        let amountString = String(describing: inputAmount.getUnitAmount(for: inputMint))
        let slippageString = String(describing: slippage.value)

        let queryItems = [
            URLQueryItem(name: "inputMint", value: inputMint.info.address),
            URLQueryItem(name: "outputMint", value: outputMint.info.address),
            URLQueryItem(name: "amount", value: amountString),
            URLQueryItem(name: "slippage", value: slippageString),
            URLQueryItem(name: "userPublicKey", value: publicKey),
            URLQueryItem(name: "onlyDirectRoutes", value: String(onlyDirectRoutes))
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
