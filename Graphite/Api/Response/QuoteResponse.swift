//
//  QuoteResponse.swift
//  Graphite
//
//  Created by Martin Lasek on 8/23/22.
//

import Foundation

struct QuoteResponse: Codable {
    let data: [Transaction]
    let timeTaken: Double
    let contextSlot: String

    struct Transaction: Codable {
        let inAmount: Int

        /// Unit representation of the `amount` you'd get in return for the `inAmount` given.
        let outAmount: Int

        /// Percentage of how much of an impact this trade would have on the currency.
        let priceImpactPct: Double

        let amount: Int
        let otherAmountThreshold: Int?
        let outAmountWithSlippage: Int?
        let swapMode: String?
        let marketInfos: [MarketInfo]
        let fees: Fees
    }

    struct MarketInfo: Codable {
        let id: String?
        let label: String?
        let inputMint: String?
        let outputMint: String?
        let inAmount: Int
        let outAmount: Int
        let lpFee: LiquidityProviderFee?
        let platformFee: PlatformFee?
        let notEnoughLiquidity: Bool?
        let priceImpactPct: Double?
    }

    struct LiquidityProviderFee: Codable {
        let amount: Int?
        let mint: String?
        let pct: Double?
    }

    struct PlatformFee: Codable {
        let amount: Int?
        let mint: String?
        let pct: Int?
    }

    struct Fees: Codable {
        let signatureFee: Int?
        let openOrdersDeposits: [Int]?
        let ataDeposits: [Int]?
        let totalFeeAndDeposits: Int?
        let minimumSOLForTransaction: Int?
    }
}

extension QuoteResponse.Transaction {
    func containsKnownCoins() -> Bool {
        for info in self.marketInfos {
            if info.containsKnownCoins() == false {
                return false
            }
        }
        return true
    }
    
    func printMarketInfo() {
        for info in self.marketInfos {
            info.printInfo()
        }
    }
}

extension QuoteResponse.MarketInfo {
    func containsKnownCoins() -> Bool {
        guard
            let inMint = self.inputMint,
            let outMint = self.outputMint
        else {
            return false
        }

        if !coinListManager.isCoinKnown(address: inMint) {
            print("\nUnknown Coin: \(inMint)")
            return false
        }

        if !coinListManager.isCoinKnown(address: outMint) {
            print("\nUnknown Coin: \(outMint)")
            return false
        }

        return true
    }

    func printInfo() {
        guard
            let exchange = self.label,
            let inMint = self.inputMint,
            let outMint = self.outputMint
        else {
            return
        }

        let inputCoin = CryptoCurrency(with: inMint)
        let outputCoin = CryptoCurrency(with: outMint)

        let inAmountFull = CryptoAmount.unit(self.inAmount).getFullAmount(for: inputCoin)
        let outAmountFull = CryptoAmount.unit(self.outAmount).getFullAmount(for: outputCoin)

        let exchangeString = "DEX: \(exchange)\n\n"
        let sendString = "➡️ SEND:\t \(inAmountFull) \(inputCoin.info.symbol)\n"
        let getString =  "💵 GET:\t\t \(outAmountFull) \(outputCoin.info.symbol)"

        print("\(exchangeString + sendString + getString)")
    }
}
