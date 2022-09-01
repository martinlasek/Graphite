//
//  SwapRequest.swift
//  Graphite
//
//  Created by Daniel Stewart on 8/27/22.
//

import Foundation

struct SwapRequest: RequestGenerator {
    private let swapUrlString = "https://quote-api.jup.ag/v1/swap"

    private let quoteResponse: QuoteResponse
    private let publicKey: String
    private let wrapUnwrapSOL: Bool
    private let feeAccount: String?

    init(quoteResponse: QuoteResponse, publicKey: String, wrapUnwrapSOL: Bool = true, feeAccount: String? = nil) {
        self.quoteResponse = quoteResponse
        self.publicKey = publicKey
        self.wrapUnwrapSOL = wrapUnwrapSOL
        self.feeAccount = feeAccount
    }

    func createRequest() -> URLRequest? {
        guard let urlComponents = URLComponents(string: swapUrlString) else {
            printError(self, "Could not create URLComponents with url: \(swapUrlString)")
            return nil
        }

        guard let url = urlComponents.url else {
            printError(self, "Could not get url from urlComponents: \(urlComponents.debugDescription)")
            return nil
        }

        guard
            let postBody = PostBody(
                quote: quoteResponse,
                userPublicKey: self.publicKey,
                wrapUnwrapSOL: self.wrapUnwrapSOL,
                feeAccount: self.feeAccount
            )
        else {
            return nil
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = try? JSONEncoder().encode(postBody)
        return urlRequest
    }
}

// MARK: - POST Body

extension SwapRequest {

    struct PostBody {
        /// Route provided in the `QuoteResponse.MarketInfoResponse`
        var route: RouteRequest
        /// The public key to be used for the swap
        var userPublicKey: String
        /// Auto wrap and unwrap SOL. Default is `true`
        var wrapUnwrapSOL: Bool
        /// Fee Account is optional. feeBps must have been passed in `QuoteRequest`.
        /// This is the ATA account for the output token where the fee will be sent to. If you are swapping from SOL->USDC then this would be the USDC ATA you want to collect the fee.
        var feeAccount: String?

        init?(quote: QuoteResponse, userPublicKey: String, wrapUnwrapSOL: Bool = true, feeAccount: String? = nil) {
            guard
                let quote = quote.data?[0]
            else {
                printError(Error.self, "Could not create POST body from QuoteResponse")
                return nil
            }

            self.route = RouteRequest(inAmount: quote.inAmount, outAmount: quote.outAmount, priceImpactPct: quote.priceImpactPct, marketInfo: quote.marketInfos)
            self.userPublicKey = userPublicKey
            self.wrapUnwrapSOL = wrapUnwrapSOL
            self.feeAccount = feeAccount
        }
    }
}

// MARK: - CodingKeys

extension SwapRequest.PostBody: Encodable {
    enum CodingKeys: String, CodingKey {
        case route = "route"
        case userPublicKey = "userPublicKey"
        case wrapUnwrapSOL = "wrapUnwrapSOL"
        case feeAccount = "fee_account_public_key"
    }
}
