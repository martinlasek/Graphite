//
//  Utilities.swift
//  Graphite
//
//  Created by Daniel Stewart on 9/14/22.
//

import Foundation

func readLocalJSONFile(forName name: String) -> Data? {
    let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let bundleURL = URL(fileURLWithPath: "JSONCoins.bundle", relativeTo: currentDirectoryURL)
    if let bundle = Bundle(url: bundleURL), let fileURL = bundle.url(forResource: name, withExtension: "json") {
        do {
            let data = try Data(contentsOf: fileURL)
            return data
        } catch {
            print("Could not retrieve JSON file")
        }
    }
    return nil
}

func parse(jsonData: Data) -> [CryptoCurrency.CryptoInfo]? {
    do {
        let decodedData = try JSONDecoder().decode([CryptoCurrency.CryptoInfo].self, from: jsonData)
        return decodedData
    } catch {
        print("error: \(error)")
    }
    return nil
}
