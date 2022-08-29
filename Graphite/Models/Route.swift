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
    let marketInfos: [MarketInfoResponse]?
}
