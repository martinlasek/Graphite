//
//  JupiterApi.swift
//  Graphite
//
//  Created by Martin Lasek on 8/31/22.
//

import Foundation

protocol RequestGenerator {
    func createRequest() -> URLRequest?
}

struct JupiterApi {
    static func fetchQuote(for request: RequestGenerator) async -> Result<QuoteResponse, ApiError> {

        guard let urlRequest = request.createRequest() else {
            return .failure(.error("could not create request"))
        }

        return await Api.sendAsync(request: urlRequest)
    }

    static func fetchSwap(for request: RequestGenerator) async -> Result<SwapResponse, ApiError> {

        guard let urlRequest = request.createRequest() else {
            return .failure(.error("could not create request"))
        }

        return await Api.sendAsync(request: urlRequest)
    }
}
