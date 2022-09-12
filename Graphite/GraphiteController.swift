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

        // MARK: - Quote for SOL worth in USDT (e.g. 1 SOL => 33 USDT)
        // MARK: - Quote for USDT worth in SOL (e.g. 33 USDT => 1.001489444 SOL)

        while true {
            let hasExecutedATrade = await checkPossibleTradeAndExecuteIfProfitable(inputMint: .usdc, outputMint: .oxy)
            try await Task.sleep(nanoseconds: 1_000_000_000)

            if hasExecutedATrade {
                print(DateTimeManager.currentTime())
                break
            }
        }
//        let hasExecutedATrade = await sendSolFromOneWalletToAnother()

    }
}

// MARK: - Try finding and then executing profitable trade

extension GraphiteController {
    private static func checkPossibleTradeAndExecuteIfProfitable(
        inputMint: CryptoCurrency,
        outputMint: CryptoCurrency
    ) async -> Bool {

        guard
            let quoteResponses = await retrieveQuoteData(inputMint: inputMint, outputMint: outputMint),
            let inputData = quoteResponses.input.data.first,
            let outputData = quoteResponses.output.data.first
        else {
            return false
        }

        // MARK: - Early return if not profitable

        let isProfitable = self.isProfitable(using: quoteResponses.input, and: quoteResponses.output)
        guard isProfitable else {
            print("✋🏻 Not profitable swap.")
            return false
        }

        // MARK: - Get Swap Transactions

        guard
            let inputSwapResponse = await getSwapTransaction(for: inputData),
            let outputSwapResponse = await getSwapTransaction(for: outputData)
        else {
            return false
        }

        logSwapTransaction(swapResonse: inputSwapResponse, comment: "\(inputMint.info.symbol) to \(outputMint.info.symbol)")
        logSwapTransaction(swapResonse: outputSwapResponse, comment: "\(outputMint.info.symbol) to \(inputMint.info.symbol)")

        // perform transaction
        if let input_tx_ID = await sendTransaction(swapResponse: inputSwapResponse) {
            printSuccess(self, "SUCCESS | \(inputMint.info.symbol) -> \(outputMint.info.symbol) | txID: \(input_tx_ID)")
            if let output_tx_ID = await sendTransaction(swapResponse: outputSwapResponse) {
                printSuccess(self, "SUCCESS | \(outputMint.info.symbol) -> \(inputMint.info.symbol) | txID: \(output_tx_ID)")
            } else {
                printError(self, "FAILED | \(outputMint.info.symbol) -> \(inputMint.info.symbol).")
            }
        } else {
            printError(self, "FAILED | \(inputMint.info.symbol) -> \(outputMint.info.symbol).")
        }

        return true
    }
}

extension GraphiteController {
    // Fetches 2 QuoteRequests - one for each CryptoCurrency in exchange for each other
    private static func retrieveQuoteData(
        inputMint: CryptoCurrency,
        outputMint: CryptoCurrency
    ) async -> (input: QuoteResponse, output: QuoteResponse)? {
        guard let publicKeyString = WalletKeyManager.getPublicKeyString() else {
            return nil
        }

        let firstQuote = QuoteRequest(
            inputMint: inputMint,
            outputMint: outputMint,
            inputAmount: .full(10),
            slippage: .percent(0),
            publicKey: publicKeyString,
            onlyDirectRoutes: false
        )

        guard
            case .success(let firstQuoteResponse) = await JupiterApi.fetchQuote(for: firstQuote),
            let firstTransaction = firstQuoteResponse.data.first
        else {
            return nil
        }

        let secondQuote = QuoteRequest(
            inputMint: outputMint,
            outputMint: inputMint,
            inputAmount: .unit(firstTransaction.outAmount),
            slippage: .percent(0),
            publicKey: publicKeyString,
            onlyDirectRoutes: false
        )

        guard
            case .success(let secondQuoteResponse) = await JupiterApi.fetchQuote(for: secondQuote)
        else {
            return nil
        }

        return (firstQuoteResponse, secondQuoteResponse)
    }
}

// MARK: - Profit/Loss calculator and logger.

extension GraphiteController {
    /// Logs the input amount and output amount for a swap and also prints profitability.
    private static func isProfitable(using firstQuote: QuoteResponse, and secondQuote: QuoteResponse) -> Bool {
        guard
            let firstTransaction = firstQuote.data.first,
            let secondTransaction = secondQuote.data.first
        else {
            return false
        }

        print("\n-----INPUT-------")
        firstTransaction.printMarketInfo()
        print("\n------------------")

        print("\n-----OUTPUT-------")
        secondTransaction.printMarketInfo()
        print("\n------------------")

        guard
            let firstMarketData = firstTransaction.marketInfos.first,
            let lastMarketData = secondTransaction.marketInfos.last,
            let inputMint = firstMarketData.inputMint
        else {
            return false
        }

        let baseCoin = CryptoCurrency(with: inputMint)

        let inAmountFull = CryptoAmount.unit(firstMarketData.inAmount).getFullAmount(for: baseCoin)
        let outAmountFull = CryptoAmount.unit(lastMarketData.outAmount).getFullAmount(for: baseCoin)

        if outAmountFull > inAmountFull {
            let diff = outAmountFull - inAmountFull
            print("🤑 PROFIT:\t \(String(format: "%.9f", diff))")
            print("-----\n")
            return true
        } else {
            let diff = inAmountFull - outAmountFull
            print("🥵 LOSS:\t \(String(format: "%.9f", diff))")
            print("-----\n")
            return false
        }

        // TODO: Calculate Fees

        let inputFees = firstTransaction.fees
        let outputFees = secondTransaction.fees

        guard
            let inputTotalFeeAndDeposits = inputFees.totalFeeAndDeposits,
            let outputTotalFeeAndDeposits = outputFees.totalFeeAndDeposits
        else {
            return false
        }
    }
}

// MARK: - Swap Transaction

extension GraphiteController {
    private static func getSwapTransaction(for quote: QuoteResponse.Transaction) async -> SwapResponse? {
        guard let publicKeyString = WalletKeyManager.getPublicKeyString() else {
            return nil
        }

        let swapRequest = SwapRequest(dataResponse: quote, userPublicKey: publicKeyString)

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

        guard let publicKeyFROMString = WalletKeyManager.getPublicKeyString() else {
            return nil
        }

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
