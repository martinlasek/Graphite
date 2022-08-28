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

    print("⬆️ INPUT 1 SOL")

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

            print("⬇️ OUTPUT \(Double(dataResponse.outAmount) / solUnit) SOL")
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

if let urlRequest = quoteRequestSOL.createRequest() {
    Api.send(request: urlRequest) { (result: Result<QuoteResponse, ApiError>) in
        switch result {
        case .success(let model):
            handleSuccess(model: model)
        case .failure(let error):
            print("\(error.localizedDescription)")
        }
    }
}



//func findCheapestSwap(in quote: QuoteResponse) {
//    guard let dataList = quote.data else {
//        return
//    }
//
//    // 1. find highest USDC output for SOL input
//    // 2. find highest SOL output for USDC input
//    // 3. check if USDC output from 2. is higher than USDC input from 1.
//
//    dataList.forEach { dataResponse in
//        dataResponse.inAmount // SOL
//        dataResponse.outAmount // USDT
//
//    }
//}

// Keeps the programm running.
RunLoop.main.run()
