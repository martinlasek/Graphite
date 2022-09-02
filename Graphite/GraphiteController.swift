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

        // MARK: - Quote for SOL worth in USDT (e.g. 1 SOL => 33 USDT)

        let quoteRequestUSDT = QuoteRequest(
            inputMint: .sol,
            outputMint: .usdt,
            inputAmount: .full(5),
            slippage: .percent(0)
        )

        let fetchSOLQuoteResponse = await JupiterApi.fetchQuote(for: quoteRequestUSDT)

        guard
            case .success(let quoteSOLResponse) = fetchSOLQuoteResponse,
            let dataSolResponse = quoteSOLResponse.data.first
        else {
            return
        }

        // MARK: - Quote for USDT worth in SOL (e.g. 33 USDT => 1.001489444 SOL)

        let quoteRequestSOL = QuoteRequest(
            inputMint: .usdt,
            outputMint: .sol,
            inputAmount: .unit(dataSolResponse.outAmount),
            slippage: .percent(0)
        )

        let fetchUSDTQuoteResponse = await JupiterApi.fetchQuote(for: quoteRequestSOL)

        guard
            case .success(let quoteUSDTResponse) = fetchUSDTQuoteResponse
        else {
            return
        }

        self.determineProfitOrLoss(using: quoteSOLResponse, and: quoteUSDTResponse)

        // MARK: - Swap

        let swapRequest = SwapRequest(dataResponse: dataSolResponse, userPublicKey: "E4NyQ8tdBWigdZ42uwzknDCL2uf8NfF8u6WKZY7k16qA")
        let swapResponse = await JupiterApi.fetchSwap(for: swapRequest)

        guard case .success(let swapModel) = swapResponse else {
            return
        }

        print("🔨 SetupTransaction: \(swapModel.setupTransaction ?? "")")
        print("🔄 SwapTransaction:\t \(swapModel.swapTransaction ?? "")")
        print("🧹 CleanupTransaction:\t \(swapModel.cleanupTransaction ?? "")")

    }

    /// Logs the input amount and output amount for a swap and also prints profitability.
    private static func determineProfitOrLoss(using inputQuote: QuoteResponse, and outputQuote: QuoteResponse) {
        guard
            let inputMarketResponse = inputQuote.data.first?.marketInfos.first,
            let outputMarketResponse = outputQuote.data.first?.marketInfos.first
        else {
            return
        }

        let inAmount = CryptoAmount.unit(inputMarketResponse.inAmount).getFullAmount(for: .sol)
        let outAmount = CryptoAmount.unit(outputMarketResponse.outAmount).getFullAmount(for: .sol)

        print("\n-----")
        print("⬆️ INPUT:\t \(inAmount) SOL \t\t\t DEX: \(inputMarketResponse.label ?? "")")
        print("⬇️ OUTPUT:\t \(outAmount) SOL \t DEX: \(outputMarketResponse.label ?? "")")

        if outAmount >= inAmount {
            let diff = outAmount - inAmount
            print("🤑 PROFIT:\t \(String(format: "%.9f", diff))")
        } else {
            let diff = inAmount - outAmount
            print("🥵 LOSS:\t \(String(format: "%.9f", diff))")
        }
        print("-----\n")
    }
}
