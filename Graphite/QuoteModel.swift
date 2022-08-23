//
//  QuoteModel.swift
//  Graphite
//
//  Created by Martin Lasek on 8/23/22.
//

import Foundation

struct QuoteModel: Codable {
    let data: [DataContent]?
    let timeTaken: Double?
    let contextSlot: String?
}

struct DataContent: Codable {
    let inAmount: Int?
    let outAmount: Int?
    let amount: Int?
    let otherAmountThreshold: Int?
    let outAmountWithSlippage: Int?
    let swapMode: String?
    let priceImpactPct: Double?
    let marketInfos: [MarketInfos]?
}

struct MarketInfos: Codable {
    let id: String?
    let label: String?
    let inputMint: String?
    let outputMint: String?
    let inAmount: Int?
    let outAmount: Int?
    let lpFee: LpFee?
    let platformFee: PlatformFee?
    let notEnoughLiquidity: Bool?
    let priceImpactPct: Double?
}

struct LpFee: Codable {
    let amount: Int?
    let mint: String?
    let pct: Double?
}

struct PlatformFee: Codable {
    let amount : Int?
    let mint : String?
    let pct : Int?
}
