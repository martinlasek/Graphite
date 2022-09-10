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
        Logger.setLoggers([GraphiteLogger()])
        let hasExecutedATrade = await checkPossibleTradeAndExecuteIfProfitable()
//        let hasExecutedATrade = await sendSolFromOneWalletToAnother()
        print("Result: \(hasExecutedATrade)")
    }
}

// MARK: - Try finding and then executing profitable trade

extension GraphiteController {
    private static func checkPossibleTradeAndExecuteIfProfitable() async -> Bool {
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
            return false
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
            return false
        }

        // MARK: - Early return if not profitable

        let isProfitable = self.isProfitOrLoss(using: quoteSOL2USDTResponse, and: quoteUSDT2SOLResponse)
        guard isProfitable else {
            print("✋🏻 Not profitable swap.")
            return false
        }

        // MARK: - Get Swap Transactions

        guard
            let swap_SOL_2_USDT_Response = await getSwapTransaction(for: data_SOL_2_USDT_Response),
            let swap_USDT_2_SOL_Response = await getSwapTransaction(for: data_USDT_2_SOL_Response)
        else {
            return false
        }

        logSwapTransaction(swapResonse: swap_SOL_2_USDT_Response, comment: "SOL to USDT")
        logSwapTransaction(swapResonse: swap_USDT_2_SOL_Response, comment: "USDT to SOL")

        // perform transaction
        if let txID_SOL_2_USDT = await sendTransaction(swapResponse: swap_SOL_2_USDT_Response) {
            printSuccess(self, "SUCCESS | SOL 2 USDT | txID: \(txID_SOL_2_USDT)")
            if let txID_USDT_2_SOL = await sendTransaction(swapResponse: swap_USDT_2_SOL_Response) {
                printSuccess(self, "SUCCESS | USDT 2 SOL | txID: \(txID_USDT_2_SOL)")
            } else {
                printError(self, "FAILED | USDT 2 SOL.")
            }
        } else {
            printError(self, "FAILED | SOL 2 USDT.")
        }

        return true
    }
}

// MARK: - Profit/Loss calculator and logger.

extension GraphiteController {
    /// Logs the input amount and output amount for a swap and also prints profitability.
    private static func isProfitOrLoss(using inputQuote: QuoteResponse, and outputQuote: QuoteResponse) -> Bool {
        guard
            let inputMarketResponse = inputQuote.data.first?.marketInfos.first,
            let outputMarketResponse = outputQuote.data.first?.marketInfos.first
        else {
            return false
        }

        let inAmount = CryptoAmount.unit(inputMarketResponse.inAmount).getFullAmount(for: .sol)
        let outDollar = CryptoAmount.unit(inputMarketResponse.outAmount).getFullAmount(for: .usdt)

        let inDollar = CryptoAmount.unit(outputMarketResponse.inAmount).getFullAmount(for: .usdt)
        let outAmount = CryptoAmount.unit(outputMarketResponse.outAmount).getFullAmount(for: .sol)

        print("\n-----")
        print("➡️ SEND:\t \(inAmount) \t\t\t SOL \t\t DEX: \(inputMarketResponse.label ?? "")")
        print("💵 GET:\t\t \(outDollar) \t\t DOLLAR")
        print()
        print("💵 SEND:\t \(inDollar) \t\t DOLLAR")
        print("⬅️ GET:\t\t \(outAmount)\t SOL \t\t DEX: \(outputMarketResponse.label ?? "")")
        print()

        if outAmount >= inAmount && outAmount < inAmount * 2 {
            let diff = outAmount - inAmount
            print("🤑 PROFIT:\t \(String(format: "%.9f", diff))")
            print("-----\n")
            return true
        } else if outAmount >= inAmount {
            let diff = inAmount - outAmount
            print("⚠️ TOO MUCH PROFIT - UNREALISTIC:\t \(String(format: "%.9f", diff))")
            print("-----\n")
            return false
        } else {
            let diff = inAmount - outAmount
            print("🥵 LOSS:\t \(String(format: "%.9f", diff))")
            print("-----\n")
            return false
        }
    }
}

// MARK: - Swap Transaction

extension GraphiteController {
    private static func getSwapTransaction(for quote: QuoteResponse.DataResponse) async -> SwapResponse? {
        let swapRequest = SwapRequest(dataResponse: quote, userPublicKey: WalletKeyManager.getPublicKey())

        let fetchSwapResponse = await JupiterApi.fetchSwap(for: swapRequest)
        guard case .success(let swapResponse) = fetchSwapResponse else {
            printError(self, "Could not get swap response from \(fetchSwapResponse)")
            return nil
        }

        return swapResponse
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
        print("⚙️ SetupTransaction: \(setupTx[..<setupIdx])..")
        print("🔄 SwapTransaction:\t \(swapTx[..<swapIdx])..")
        print("🗑 CleanupTransaction:\t \(cleanupTx[..<cleanupIdx])..")
        print()
    }
}

// MARK: - Send Transaction

extension GraphiteController {
    private static func sendTransaction(swapResponse: SwapResponse) async -> [TransactionID]? {
        guard
            let secretKey = WalletKeyManager.getPrivateKey(),
            let account = try? Account(secretKey: Data(secretKey))
        else {
            printError(self, "Could not create account.")
            return nil
        }

        let endpoint = APIEndPoint(
            address: "https://solana-mainnet.g.alchemy.com/v2/4TYxikV0LFWnb4hqs4J1oi0Hv6Rrjuru",
            network: .mainnetBeta
        )

        let apiClient = JSONRPCAPIClient(endpoint: endpoint)
        // let blockChainClient = BlockchainClient(apiClient: apiClient)

        guard
            let swapTransaction = swapResponse.swapTransaction,
            let swapTx = try? await TransactionManager.createPreparedTransaction(with: swapTransaction, account: account, and: apiClient),
            let swapTxString = try? swapTx.serialize()
        else {
            printError(self, "SwapResponse had no swapTransaction.")
            return nil
        }

        // MARK: -  Preparing Transaction array with potential setup/cleanup transaction

        var transactionList = [swapTxString]

        // Prepare SETUP Transaction
        if let setupTransaction = swapResponse.setupTransaction {
            guard
                let setupTx = try? await TransactionManager.createPreparedTransaction(with: setupTransaction, account: account, and: apiClient),
                let setupTxString = try? setupTx.serialize()
            else {
                printError(self, "setupTransaction was given but UNABLE to create PreparedTransaction out of it.")
                return nil
            }

            transactionList.insert(setupTxString, at: 0)
        }

        // Prepare CLEANUP Transaction
        if let cleanupTransaction = swapResponse.cleanupTransaction {
            guard
                let cleanupTx = try? await TransactionManager.createPreparedTransaction(with: cleanupTransaction, account: account, and: apiClient),
                let cleanupTxString = try? cleanupTx.serialize()
            else {
                printError(self, "cleanupTransaction was given but UNABLE to create PreparedTransaction out of it.")
                return nil
            }

            transactionList.insert(cleanupTxString, at: 2)
        }

        let requestConf = RequestConfiguration(encoding: "base64", skipPreflight: true)!

        let batchRequestList = transactionList.map {
            return JSONRPCAPIClient.RequestEncoder.RequestType(method: "sendTransaction", params: [$0, requestConf])
        }

        do {
            print("🚀 Sending transaction..")
            let resultList = try await apiClient.batchRequest(with: batchRequestList)
            return resultList.map { $0.result?.description ?? "------" }
        } catch let error {
            handleSolanaError(id: "SEND TRANSACTION", error)
            return nil
        }
    }
}

// MARK: - Send SOL from one Wallet to another

extension GraphiteController {
    private static func sendSolFromOneWalletToAnother() async -> TransactionID? {

        let publicKeyFROMString: String = WalletKeyManager.getPublicKey()
        let publicKeyTOString = "7xA6BAdBrq63MVYVutWTfuHLvKws78n4xLYmSjmrSQ2M" // destination wallet

        guard
            let publicKeyFROM = try? PublicKey(string: publicKeyFROMString),
            let publicKeyTWO = try? PublicKey(string: publicKeyTOString)
        else {
            printError(self, "PUBLIC KEY: could not be created with: \(publicKeyFROMString)")
            return nil
        }

        let sol = CryptoAmount.full(0.2)
        let lamports = UInt64(sol.getUnitAmount(for: .sol))

        let ti = SystemProgram.transferInstruction(from: publicKeyFROM, to: publicKeyTWO, lamports: lamports)

        guard
            let secretKey = WalletKeyManager.getPrivateKey(),
            let account = try? Account(secretKey: Data(secretKey))
        else {
            printError(self, "Could not create account.")
            return nil
        }

        let endpoint = APIEndPoint(
            address: "https://solana-mainnet.g.alchemy.com/v2/4TYxikV0LFWnb4hqs4J1oi0Hv6Rrjuru",
            network: .mainnetBeta
        )

        let apiClient = JSONRPCAPIClient(endpoint: endpoint)
        let blockChainClient = BlockchainClient(apiClient: apiClient)

        var preparedTx: PreparedTransaction?

        do {
            preparedTx = try await blockChainClient.prepareTransaction(instructions: [ti], signers: [account], feePayer: publicKeyFROM)
        } catch let error {
            handleSolanaError(id: "PREPARATION", error)
            return nil
        }

        guard var preparedTransaction = preparedTx else {
            printError(self, "Preparing Transaction failed.")
            return nil
        }

        guard let recentBlockhash = try? await apiClient.getRecentBlockhash() else {
            printError(self, "Recent blockhash failed.")
            return nil
        }

        preparedTransaction.transaction.recentBlockhash = recentBlockhash
        preparedTransaction.signers = [account]
        try? preparedTransaction.sign()
        guard let tx = try? preparedTransaction.serialize() else {
            printError(self, "Could not serialize.")
            return nil
        }

        do {
            print("🚀 Sending transaction..")
            return try await apiClient.sendTransaction(transaction: tx)
        } catch let error {
            handleSolanaError(id: "SEND TRANSACTION", error)
            return nil
        }
    }
}

// MARK: - Get Solana Balance

extension GraphiteController {

    private static func getSolanaBalance() async {
        guard
            let secretKey = WalletKeyManager.getPrivateKey(),
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

    private static func handleSolanaError(id: String, _ error : Error) {
        if let sError = error as? SolanaError {
            printError(self, "\(id) - SolanaError: \(sError.readableDescription)")
        } else {
            printError(self, "\(id) - \(error.readableDescription)")
        }
    }
}
