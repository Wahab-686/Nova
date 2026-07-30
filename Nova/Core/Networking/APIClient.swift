//
//  APIClient.swift
//  Nova
//
//  Created by Wahab on 30/07/2026.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case decodingFailed
    case serverError(statusCode: Int)
    case unknown(Error)
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

final class APIClient {
    static let shared = APIClient()
    private init() {}
    
    private let session = URLSession.shared
    
    func request<T: Decodable>(
        urlString: String,
        method: HTTPMethod = .get,
        headers: [String: String]? = nil,
        body: Data? = nil
    ) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        headers?.forEach {
            request.setValue($1, forHTTPHeaderField: $0)
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.serverError(statusCode: httpResponse.statusCode)
            }
            
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw APIError.decodingFailed
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.unknown(error)
        }
    }
}
