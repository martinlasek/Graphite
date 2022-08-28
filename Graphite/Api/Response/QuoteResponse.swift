//
//  QuoteResponse.swift
//  Graphite
//
//  Created by Martin Lasek on 8/23/22.
//

import Foundation

struct QuoteResponse: Codable {
    let data: [DataResponse]?
    let timeTaken: Double?
    let contextSlot: String

    struct DataResponse: Codable {
        let inAmount: Int
        let outAmount: Int
        let amount: Int
        let otherAmountThreshold: Int?
        let outAmountWithSlippage: Int?
        let swapMode: String?
        let priceImpactPct: Double?
        let marketInfos: [MarketInfosResponse]?
    }

    struct MarketInfosResponse: Codable {
        let id: String?
        let label: String?
        let inputMint: String?
        let outputMint: String?
        let inAmount: Int?
        let outAmount: Int?
        let lpFee: LpFeeResponse?
        let platformFee: PlatformFeeResponse?
        let notEnoughLiquidity: Bool?
        let priceImpactPct: Double?
    }

    struct LpFeeResponse: Codable {
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
