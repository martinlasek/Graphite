//
//  main.swift
//  Graphite
//
//  Created by Martin Lasek on 8/20/22.
//

import Foundation

let quoteRequest = QuoteRequest(
    inputMint: .sol,
    outputMint: .usdc,
    amount: .sol(1),
    slippage: .percent(0.5)
)

var swapRequest = SwapRequest(publicKey: "E4NyQ8tdBWigdZ42uwzknDCL2uf8NfF8u6WKZY7k16qA")

if let urlRequest = quoteRequest.createRequest() {
    Api.send(request: urlRequest) { (result: Result<QuoteResponse, ApiError>) in
        switch result {
        case .success(let model):

            swapRequest.quote = model
            swapRequest.handleSuccess(with: model)
        case .failure(let error):
            print("\(error.localizedDescription)")
        }
    }
}


// Keeps the programm running.
RunLoop.main.run()
