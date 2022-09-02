//
//  RouteRequest.swift
//  Graphite
//
//  Created by Daniel Stewart on 8/28/22.
//

import Foundation

struct RouteRequest: Codable {
    let inAmount: Int
    let outAmount: Int
    let priceImpactPct: Double
    let marketInfos: [QuoteResponse.MarketInfoResponse]
}
