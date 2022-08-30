//
//  main.swift
//  Graphite
//
//  Created by Martin Lasek on 8/20/22.
//

import Foundation

func handleSuccess(model: QuoteResponse) {

    guard let dataResponse = model.data?.first else {
        return
    }

    print("⬆️ INPUT: 1 SOL / DEX: \(dataResponse.marketInfos.first?.label ?? "")")

    let solUnit: Double = 1_000_000_000

    let quoteRequestUSDT = QuoteRequest(
        inputMint: .usdt,
        outputMint: .sol,
        amount: .usdt(.unit(dataResponse.outAmount)),
        slippage: .percent(0)
    )

    guard let urlRequest = quoteRequestUSDT.createRequest() else {
        return
    }

    Api.send(request: urlRequest) { (result: Result<QuoteResponse, ApiError>) in
        switch result {
        case .success(let model):
            guard let dataResponse = model.data?.first else {
                return
            }

            let fullSol = Double(dataResponse.outAmount) / solUnit
            print("⬇️ OUTPUT: \(fullSol) SOL / DEX: \(dataResponse.marketInfos.first?.label ?? "")")

            if fullSol >= 1 {
                let profit = fullSol-1
                print("🤑 \(String(format: "%.9f", profit))")
            } else {
                let loss = 1-fullSol

                print("🥵 \(String(format: "%.9f", loss))")
            }

        case .failure(let error):
            print("\(error.localizedDescription)")
        }
    }
}

let quoteRequestSOL = QuoteRequest(
    inputMint: .sol,
    outputMint: .usdt,
    amount: .sol(.full(1)),
    slippage: .percent(0)
)

var swapRequest = SwapRequest(publicKey: "E4NyQ8tdBWigdZ42uwzknDCL2uf8NfF8u6WKZY7k16qA")

if let urlRequest = quoteRequestSOL.createRequest() {
    Api.send(request: urlRequest) { (result: Result<QuoteResponse, ApiError>) in
        switch result {
        case .success(let model):
            handleSuccess(model: model)
            swapRequest.quote = model
            swapRequest.handleSuccess(with: model)
        case .failure(let error):
            print("\(error.localizedDescription)")
        }
    }
}


// Keeps the programm running.
RunLoop.main.run()
