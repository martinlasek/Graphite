//
//  RouteMap.swift
//  Graphite
//
//  Created by Daniel Stewart on 8/21/22.
//

import Foundation

struct RouteMap: Codable {

    struct Response: Codable {
        let routeMap: RouteMap
    }

    // MARK: - Public Properties

    let mintKeys: [String]
    let routeMap: [String : [Int]]

    // MARK: Initialization

    init(from decoder: Decoder) throws {
        let results = try decoder.container(keyedBy: CodingKeys.self)
        mintKeys = try results.decode([String].self, forKey: .mintKeys)
        routeMap = try results.decode([String : [Int]].self, forKey: .routeMap)
    }

    // MARK: CodingKeys

    enum CodingKeys: String, CodingKey {
        case mintKeys = "mintKeys"
        case routeMap = "indexedRouteMap"
    }
}
