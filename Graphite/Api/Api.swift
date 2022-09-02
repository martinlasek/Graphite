//
//  Api.swift
//  Graphite
//
//  Created by Martin Lasek on 8/23/22.
//

import Foundation

enum ApiError: Error {
    case error(String)
    case noData
    case couldNotDecodeResponse
}

struct Api {
    /// Generic Send Function.
    /// Specify the result type when calling the function to help inferring it.
    /// e.g. `Api.send(request: quoteRequest) { (result: Result<QuoteResponse, ApiError>) in ... }`
    static func send<T: Decodable>(request: URLRequest, completionHandler: @escaping (Result<T, ApiError>) -> Void) {
        print("🌐 API Request to: \(request.url?.absoluteString ?? "nil")")

        URLSession(configuration: .ephemeral).dataTask(with: request) { data, resp, error in

            // Early return in case of error.
            if let error = error {
                printError(self, error.localizedDescription)
                completionHandler(.failure(.error(error.localizedDescription)))
                return
            }

            guard let data = data else {
                completionHandler(.failure(.noData))
                return
            }

            if let restaurant = try? JSONDecoder().decode(T.self, from: data) {
                completionHandler(.success(restaurant))
                return
            }

            printError(self, String(data: data, encoding: .utf8) ?? "")
            completionHandler(.failure(ApiError.couldNotDecodeResponse))
        }.resume()
    }
    
    /// Generic Send Function.
    /// Specify the result type when calling the function to help inferring it.
    /// e.g. `Api.send(request: quoteRequest) { (result: Result<QuoteResponse, ApiError>) in ... }`
    static func sendAsync<T: Decodable>(request: URLRequest) async -> Result<T, ApiError> {
        print("🌐 API Request to: \(request.url?.absoluteString ?? "nil")")


        guard let (data, response) = try? await URLSession.shared.data(for: request) else {
            return .failure(.couldNotDecodeResponse)
        }

        guard let restaurant = try? JSONDecoder().decode(T.self, from: data) else {
            printError(self, response.debugDescription)
            return .failure(.couldNotDecodeResponse)
        }

        return .success(restaurant)
    }
}
