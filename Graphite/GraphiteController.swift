//
//  GraphiteController.swift
//  Graphite
//
//  Created by Martin Lasek on 8/20/22.
//

import Foundation

@main
struct GraphiteController {

    /// The entry point of the application.
    static func main() async throws {

        // MARK: - Quote

        let quoteRequestSOL = QuoteRequest(
            inputMint: .sol,
            outputMint: .usdt,
            inputAmount: .sol(.full(1)),
            slippage: .percent(0)
        )

        let fetchSOLQuoteResponse = await JupiterApi.fetchQuote(for: quoteRequestSOL)

        guard
            case .success(let quoteSOLResponse) = fetchSOLQuoteResponse,
            let dataSolResponse = quoteSOLResponse.data.first
        else {
            return
        }

        let quoteRequestUSDT = QuoteRequest(
            inputMint: .usdt,
            outputMint: .sol,
            inputAmount: .usdt(.unit(dataSolResponse.outAmount)),
            slippage: .percent(0)
        )

        let quoteUSDTResponse = await JupiterApi.fetchQuote(for: quoteRequestUSDT)

        guard
            case .success(let modelUSDT) = quoteUSDTResponse,
            let dataUSDTResponse = modelUSDT.data.first
        else {
            return
        }

        let solUnit: Double = 1_000_000_000
        let fullSol = Double(dataUSDTResponse.outAmount) / solUnit

        print("⬆️ INPUT:\t 1 SOL / DEX: \(dataSolResponse.marketInfos.first?.label ?? "")")
        print("⬇️ OUTPUT:\t \(fullSol) SOL / DEX: \(dataUSDTResponse.marketInfos.first?.label ?? "")")

        if fullSol >= 1 {
            let profit = fullSol-1
            print("🤑 \(String(format: "%.9f", profit))")
        } else {
            let loss = 1-fullSol
            print("🥵 \(String(format: "%.9f", loss))")
        }

        // MARK: - Swap

        let swapRequest = SwapRequest(dataResponse: dataSolResponse, userPublicKey: "E4NyQ8tdBWigdZ42uwzknDCL2uf8NfF8u6WKZY7k16qA")

        let swapResponse = await JupiterApi.fetchSwap(for: swapRequest)

        guard case .success(let swapModel) = swapResponse else {
            return
        }

        print("🔄 SwapTranswer:\t \(String(describing: swapModel.swapTransaction)) SOL / DEX: \(dataUSDTResponse.marketInfos.first?.label ?? "")")

    }

    private static func fetchBestSwap(for input: CryptoCurrency, and output: CryptoCurrency) async {
        
    }
}
