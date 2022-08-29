//
//  SwapRequest.swift
//  Graphite
//
//  Created by Daniel Stewart on 8/27/22.
//

import Foundation

struct SwapRequest {
    private let swapUrlString = "https://quote-api.jup.ag/v1/swap"

    var quote: QuoteResponse?
    let publicKey: String
    let wrapUnwrapSOL: Bool
    let feeAccount: String?

    init(quote: QuoteResponse? = nil, publicKey: String, wrapUnwrapSOL: Bool = true, feeAccount: String? = nil) {
        self.quote = quote
        self.publicKey = publicKey
        self.wrapUnwrapSOL = wrapUnwrapSOL
        self.feeAccount = feeAccount
    }

    func createRequest(with quote: QuoteResponse?) -> URLRequest? {
        guard let urlComponents = URLComponents(string: swapUrlString) else {
            printError(self, "Could not create URLComponents with url: \(swapUrlString)")
            return nil
        }

        guard let url = urlComponents.url else {
            printError(self, "Could not get url from urlComponents: \(urlComponents.debugDescription)")
            return nil
        }

        guard
            let postBody = PostBody(quote: quote,
                                    userPublicKey: self.publicKey,
                                    wrapUnwrapSOL: self.wrapUnwrapSOL,
                                    feeAccount: self.feeAccount)
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

    func handleSuccess(with quote: QuoteResponse?) {
        guard
            let swapRequest = createRequest(with: quote)
        else {
            return
        }

        Api.send(request: swapRequest) { (result: Result<SwapResponse, ApiError>) in
            switch result {
            case .success(let model):
                print(model)
            case .failure(let error):
                print("\(error.localizedDescription)")
            }
        }
    }
}

//var request = URLRequest(url: url)
//request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//request.setValue("application/json", forHTTPHeaderField: "Accept")
//request.httpMethod = "POST"
//let parameters: [String: Any] = [
//    "id": 13,
//    "name": "Jack & Jill"
//]
//request.httpBody = parameters.percentEncoded()

// MARK: - POST Body

extension SwapRequest {

    struct PostBody {
        /// Route provided in the `QuoteResponse.MarketInfoResponse`
        var route: Route
        /// The public key to be used for the swap
        var userPublicKey: String
        /// Auto wrap and unwrap SOL. Default is `true`
        var wrapUnwrapSOL: Bool
        /// Fee Account is optional. feeBps must have been passed in `QuoteRequest`.
        /// This is the ATA account for the output token where the fee will be sent to. If you are swapping from SOL->USDC then this would be the USDC ATA you want to collect the fee.
        var feeAccount: String?

        init?(quote: QuoteResponse?, userPublicKey: String, wrapUnwrapSOL: Bool = true, feeAccount: String? = nil) {
            guard
                let quote = quote?.data?[0]
            else {
                printError(Error.self, "Could not create POST body from QuoteResponse")
                return nil
            }

            self.route = Route(inAmount: quote.inAmount, outAmount: quote.outAmount, priceImpactPct: quote.priceImpactPct, marketInfos: quote.marketInfos)
            self.userPublicKey = userPublicKey
            self.wrapUnwrapSOL = wrapUnwrapSOL
            self.feeAccount = feeAccount
        }
    }
}

// MARK: CodingKeys

extension SwapRequest.PostBody: Encodable {
    enum CodingKeys: String, CodingKey {
        case route = "route"
        case userPublicKey = "userPublicKey"
        case wrapUnwrapSOL = "wrapUnwrapSOL"
        case feeAccount = "fee_account_public_key"
    }
}
