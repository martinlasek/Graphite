//
//  QuoteResponse.swift
//  Graphite
//
//  Created by Martin Lasek on 8/23/22.
//

import Foundation

typealias MarketInfoResponse = QuoteResponse.MarketInfo

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
        let route: Route

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)

            self.amount = try values.decodeIfPresent(Int.self, forKey: .amount)
            self.otherAmountThreshold = try values.decodeIfPresent(Int.self, forKey: .otherAmountThreshold)
            self.outAmountWithSlippage = try values.decodeIfPresent(Int.self, forKey: .outAmountWithSlippage)
            self.swapMode = try values.decodeIfPresent(String.self, forKey: .swapMode)

            let inAmount = try values.decodeIfPresent(Int.self, forKey: .inAmount)
            let outAmount = try values.decodeIfPresent(Int.self, forKey: .outAmount)
            let priceImpactPct = try values.decodeIfPresent(Double.self, forKey: .priceImpactPct)
            let marketInfo = try values.decodeIfPresent([MarketInfo].self, forKey: .marketInfos)
            self.route = Route(inAmount: inAmount, outAmount: outAmount, priceImpactPct: priceImpactPct, marketInfo: marketInfo)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(amount, forKey: .amount)
            try container.encode(otherAmountThreshold, forKey: .otherAmountThreshold)
            try container.encode(outAmountWithSlippage, forKey: .outAmountWithSlippage)
            try container.encode(swapMode, forKey: .swapMode)
        }

        enum CodingKeys: String, CodingKey {
            case amount = "amount"
            case otherAmountThreshold = "otherAmountThreshold"
            case outAmountWithSlippage = "outAmountWithSlippage"
            case swapMode = "swapMode"
            case inAmount = "inAmount"
            case outAmount = "outAmount"
            case priceImpactPct = "priceImpactPct"
            case marketInfos = "marketInfos"
        }
    }

    struct MarketInfo: Codable {
        let id: String?
        let label: String?
        let inputMint: String?
        let outputMint: String?
        let inAmount: Int?
        let outAmount: Int?
        let lpFee: LiquidityProviderFee?
        let platformFee: PlatformFee?
        let notEnoughLiquidity: Bool?
        let priceImpactPct: Double?

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)

            self.id = try values.decodeIfPresent(String.self, forKey: .id)
            self.label = try values.decodeIfPresent(String.self, forKey: .label)
            self.inputMint = try values.decodeIfPresent(String.self, forKey: .inputMint)
            self.outputMint = try values.decodeIfPresent(String.self, forKey: .outputMint)
            self.inAmount = try values.decodeIfPresent(Int.self, forKey: .inAmount)
            self.outAmount = try values.decodeIfPresent(Int.self, forKey: .outAmount)
            self.lpFee = try values.decodeIfPresent(LiquidityProviderFee.self, forKey: .lpFee)
            self.platformFee = try values.decodeIfPresent(PlatformFee.self, forKey: .platformFee)
            self.notEnoughLiquidity = try values.decodeIfPresent(Bool.self, forKey: .notEnoughLiquidity)
            self.priceImpactPct = try values.decodeIfPresent(Double.self, forKey: .priceImpactPct)
        }
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
}
