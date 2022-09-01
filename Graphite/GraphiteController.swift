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
            inputAmount: .full(1),
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

        self.outputQuoteResult(for: quoteSOLResponse, and: quoteUSDTResponse)

        // MARK: - Swap

        let swapRequest = SwapRequest(dataResponse: dataSolResponse, userPublicKey: "E4NyQ8tdBWigdZ42uwzknDCL2uf8NfF8u6WKZY7k16qA")

        let swapResponse = await JupiterApi.fetchSwap(for: swapRequest)

        guard case .success(let swapModel) = swapResponse else {
            return
        }

        print("🔄 SwapTranswer:\t \(String(describing: swapModel.swapTransaction ?? ""))")
    }

    private static func outputQuoteResult(for inputQuote: QuoteResponse, and outputQuote: QuoteResponse) {
        guard
            let inputMarketResponse = inputQuote.data.first?.marketInfos.first,
            let outputMarketResponse = outputQuote.data.first?.marketInfos.first
        else {
            return
        }

        let fullSol = Double(outputMarketResponse.outAmount) / CryptoCurrency.sol.decimals

        let inAmount = CryptoAmount.unit(inputMarketResponse.inAmount)
        print("⬆️ INPUT:\t \(inAmount.getFullAmount(for: .sol)) SOL / DEX: \(inputMarketResponse.label ?? "")")
        print("⬇️ OUTPUT:\t \(fullSol) SOL / DEX: \(outputMarketResponse.label ?? "")")

        if fullSol >= 1 {
            let profit = fullSol-1
            print("🤑 \(String(format: "%.9f", profit))")
        } else {
            let loss = 1-fullSol
            print("🥵 \(String(format: "%.9f", loss))")
        }
    }
}
