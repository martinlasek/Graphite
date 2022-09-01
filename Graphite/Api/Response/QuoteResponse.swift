//
//  QuoteResponse.swift
//  Graphite
//
//  Created by Martin Lasek on 8/23/22.
//

import Foundation

struct QuoteResponse: Codable {
    let data: [DataResponse]
    let timeTaken: Double
    let contextSlot: String

    struct DataResponse: Codable {
        let inAmount: Int
        let outAmount: Int
        let priceImpactPct: Double
        let amount: Int
        let otherAmountThreshold: Int?
        let outAmountWithSlippage: Int?
        let swapMode: String?
        let marketInfos: [MarketInfoResponse]
    }

    struct MarketInfoResponse: Codable {
        let id: String?
        let label: String?
        let inputMint: String?
        let outputMint: String?
        let inAmount: Int?
        let outAmount: Int?
        let lpFee: LiquidityProviderFeeResponse?
        let platformFee: PlatformFeeResponse?
        let notEnoughLiquidity: Bool?
        let priceImpactPct: Double?
    }

    struct LiquidityProviderFeeResponse: Codable {
        let amount: Int?
        let mint: String?
        let pct: Double?
    }

    struct PlatformFeeResponse: Codable {
        let amount: Int?
        let mint: String?
        let pct: Int?
    }
}
