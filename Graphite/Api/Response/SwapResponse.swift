//
//  SwapResponse.swift
//  Graphite
//
//  Created by Daniel Stewart on 8/28/22.
//

import Foundation

struct SwapResponse: Codable {
    let setupTransaction: String?
    let swapTransaction: String?
    let cleanupTransaction: String?
}
