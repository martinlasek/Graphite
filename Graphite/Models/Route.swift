//
//  Route.swift
//  Graphite
//
//  Created by Daniel Stewart on 8/28/22.
//

import Foundation

struct Route: Codable {
    let inAmount: Int?
    let outAmount: Int?
    let priceImpactPct: Double?
    let marketInfo: [MarketInfoResponse]?

    enum CodingKeys: String, CodingKey {
        case inAmount = "inAmount"
        case outAmount = "outAmount"
        case priceImpactPct = "priceImpactPct"
        case marketInfo = "marketInfos"
    }
}
