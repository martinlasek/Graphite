//
//  GraphiteController.swift
//  Graphite
//
//  Created by Martin Lasek on 8/20/22.
//

import Foundation
import SolanaSwift

@main
struct GraphiteController {

    /// The entry point of the application.
    static func main() async throws {

        // MARK: - Quote for SOL worth in USDT (e.g. 1 SOL => 33 USDT)

        let quoteRequestUSDT = QuoteRequest(
            inputMint: .sol,
            outputMint: .usdt,
            inputAmount: .full(0.1),
            slippage: .percent(0)
        )

        let fetchSOLQuoteResponse = await JupiterApi.fetchQuote(for: quoteRequestUSDT)

        guard
            case .success(let quoteSOL2USDTResponse) = fetchSOLQuoteResponse,
            let data_SOL_2_USDT_Response = quoteSOL2USDTResponse.data.first
        else {
            return
        }

        // MARK: - Quote for USDT worth in SOL (e.g. 33 USDT => 1.001489444 SOL)

        let quoteRequestSOL = QuoteRequest(
            inputMint: .usdt,
            outputMint: .sol,
            inputAmount: .unit(data_SOL_2_USDT_Response.outAmount),
            slippage: .percent(0)
        )

        let fetchUSDTQuoteResponse = await JupiterApi.fetchQuote(for: quoteRequestSOL)

        guard
            case .success(let quoteUSDT2SOLResponse) = fetchUSDTQuoteResponse,
            let data_USDT_2_SOL_Response = quoteUSDT2SOLResponse.data.first
        else {
            return
        }

        let isProfitable = self.isProfitOrLoss(using: quoteSOL2USDTResponse, and: quoteUSDT2SOLResponse)

        // MARK: - Swap

        guard
            let swap_SOL_2_USDT_Response = await getSwapTransaction(for: data_SOL_2_USDT_Response),
            let swap_USDT_2_SOL_Response = await getSwapTransaction(for: data_USDT_2_SOL_Response)
        else {
            return
        }

        logSwapTransaction(swapResonse: swap_SOL_2_USDT_Response, comment: "SOL to USDT")
        logSwapTransaction(swapResonse: swap_USDT_2_SOL_Response, comment: "USDT to SOL")

        if isProfitable {
            // perform transaction
            await getSolanaBalance()
        }
    }

    private static func logSwapTransaction(swapResonse: SwapResponse, comment: String) {
        let maxChars = 100
        let setupTx = swapResonse.setupTransaction ?? ""
        let setupIdx = String.Index(utf16Offset: setupTx.count > maxChars ? maxChars : 0, in: setupTx)

        let swapTx = swapResonse.swapTransaction ?? ""
        let swapIdx = String.Index(utf16Offset: swapTx.count > maxChars ? maxChars : 0, in: swapTx)

        let cleanupTx = swapResonse.cleanupTransaction ?? ""
        let cleanupIdx = String.Index(utf16Offset: cleanupTx.count > maxChars ? maxChars : 0, in: cleanupTx)

        print("\n‼️ \(comment)")
        print("🔨 SetupTransaction: \(setupTx[..<setupIdx])..")
        print("🔄 SwapTransaction:\t \(swapTx[..<swapIdx])..")
        print("🧹 CleanupTransaction:\t \(cleanupTx[..<cleanupIdx])..")
        print()
    }

    private static func getSwapTransaction(for quote: QuoteResponse.DataResponse) async -> SwapResponse? {
        let swapRequest = SwapRequest(dataResponse: quote, userPublicKey: "E4NyQ8tdBWigdZ42uwzknDCL2uf8NfF8u6WKZY7k16qA")
        let fetchSwapResponse = await JupiterApi.fetchSwap(for: swapRequest)
        guard case .success(let swapResponse) = fetchSwapResponse else {
            printError(self, "Could not get swap response from \(fetchSwapResponse)")
            return nil
        }

        return swapResponse
    }

    /// Logs the input amount and output amount for a swap and also prints profitability.
    private static func isProfitOrLoss(using inputQuote: QuoteResponse, and outputQuote: QuoteResponse) -> Bool {
        guard
            let inputMarketResponse = inputQuote.data.first?.marketInfos.first,
            let outputMarketResponse = outputQuote.data.first?.marketInfos.first
        else {
            return false
        }

        let inAmount = CryptoAmount.unit(inputMarketResponse.inAmount).getFullAmount(for: .sol)
        let outAmount = CryptoAmount.unit(outputMarketResponse.outAmount).getFullAmount(for: .sol)

        print("\n-----")
        print("⬆️ INPUT:\t \(inAmount) SOL \t\t\t DEX: \(inputMarketResponse.label ?? "")..")
        print("⬇️ OUTPUT:\t \(outAmount) SOL \t DEX: \(outputMarketResponse.label ?? "")")

        if outAmount >= inAmount {
            let diff = outAmount - inAmount
            print("🤑 PROFIT:\t \(String(format: "%.9f", diff))")
            print("-----\n")
            return true
        } else {
            let diff = inAmount - outAmount
            print("🥵 LOSS:\t \(String(format: "%.9f", diff))")
            print("-----\n")
            return false
        }
    }

    private static func sendTransaction(swapResponse: SwapResponse) async {
        printDebug(self, "Sending transaction..")

        guard
            let secretKey = PrivateKeyManager.getPrivateKey(),
            let account = try? Account(secretKey: Data(secretKey))
        else {
            printError(self, "Could not create account.")
            return
        }

        let endpoint = APIEndPoint(
            address: "https://solana-mainnet.g.alchemy.com/v2/4TYxikV0LFWnb4hqs4J1oi0Hv6Rrjuru",
            network: .mainnetBeta
        )

        let apiClient = JSONRPCAPIClient(endpoint: endpoint)
        let blockChainClient = BlockchainClient(apiClient: apiClient)



        if let setupTransaction = swapResponse.setupTransaction {
            print("\n🔨 SetupTransaction..")
            guard let transactionId = try? await apiClient.sendTransaction(transaction: setupTransaction) else {
                return
            }

            print("--> TransactionID, \(transactionId)\n")
        }

        if let swapTransaction = swapResponse.swapTransaction {
            print("\n🔄 SwapTransaction..")
            guard let transactionId = try? await apiClient.sendTransaction(transaction: swapTransaction) else {
                return
            }

            print("--> TransactionID, \(transactionId)\n")
        }

        if let cleanupTransaction = swapResponse.cleanupTransaction {
            print("\n🧹 CleanupTransaction..")
            guard let transactionId = try? await apiClient.sendTransaction(transaction: cleanupTransaction) else {
                return
            }

            print("--> TransactionID, \(transactionId)\n")
        }
    }

    private static func getSolanaBalance() async {
        guard
            let secretKey = PrivateKeyManager.getPrivateKey(),
            let account = try? Account(secretKey: Data(secretKey))
        else {
            printError(self, "Could not create account.")
            return
        }

        let endpoint = APIEndPoint(
            address: "https://solana-mainnet.g.alchemy.com/v2/4TYxikV0LFWnb4hqs4J1oi0Hv6Rrjuru",
            network: .mainnetBeta
        )

        // To get block height
        let apiClient = JSONRPCAPIClient(endpoint: endpoint)

        // To get balance of the current account
        let accountEncoded = account.publicKey.base58EncodedString
        guard
            let balance = try? await apiClient.getBalance(account: accountEncoded, commitment: "recent")
        else {
            return
        }

        print("💰 Solana Balance: \(CryptoAmount.unit(Int(balance)).getFullAmount(for: .sol))")
    }
}
