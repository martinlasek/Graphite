//
//  SwapRequest.swift
//  Graphite
//
//  Created by Daniel Stewart on 8/27/22.
//

import Foundation
import Solana

struct SwapRequest: Codable, RequestGenerator {
    private var swapUrlString = "https://quote-api.jup.ag/v1/swap"

    /// Route provided in the `QuoteResponse.MarketInfoResponse`
    var route: RouteRequest
    /// The public key to be used for the swap
    var userPublicKey: String
    /// Auto wrap and unwrap SOL. Default is `true`
    var wrapUnwrapSOL: Bool
    /// Fee Account is optional. feeBps must have been passed in `QuoteRequest`.
    /// This is the ATA account for the output token where the fee will be sent to. If you are swapping from SOL->USDC then this would be the USDC ATA you want to collect the fee.
    var feeAccount: String?

    init(dataResponse: QuoteResponse.DataResponse, userPublicKey: String, wrapUnwrapSOL: Bool = true, feeAccount: String? = nil) {
        self.route = RouteRequest(
            inAmount: dataResponse.inAmount,
            outAmount: dataResponse.outAmount,
            priceImpactPct: dataResponse.priceImpactPct,
            marketInfos: dataResponse.marketInfos
        )

        self.userPublicKey = userPublicKey
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

        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = try? JSONEncoder().encode(self)
        return urlRequest
    }
}
