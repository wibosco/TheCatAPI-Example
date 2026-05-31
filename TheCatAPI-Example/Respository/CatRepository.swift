//
//  CatRepository.swift
//  TheCatAPI-Example
//
//  Created by William Boles on 24/05/2026.
//

import Foundation
import OSLog

enum CatRepositoryError: Error {
    case networkError
    case decodingErrror
}

actor CatRepository {
    private let logger: Logger
    
    // MARK: - Init
    
    init() {
        self.logger = Logger(subsystem: "com.williamboles",
                             category: "CatRepository")
    }
    
    // MARK: - Cats
    
    func retrieveCats(_ page: Int = 0) async throws -> Page {
        let APIKey = Bundle.main.object(forInfoDictionaryKey: "CatAPIKey") as? String ?? "" // Add your API key from: https://thecatapi.com/

        if APIKey.isEmpty {
            logger.error("""
            *******************************************************************************  
            *******************************************************************************  
            *******************************************************************************  
            ******************************* MISSING API KEY *******************************
            *******************************************************************************  
            ******************************************************************************* 
            ******************************************************************************* 
            """)
        }

        let paginationLimit = 48

        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.thecatapi.com"
        components.path = "/v1/images/search"
        components.queryItems = [
            URLQueryItem(name: "order", value: "DESC"),
            URLQueryItem(name: "limit", value: "\(paginationLimit)"),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "has_breeds", value: "false"),
            URLQueryItem(name: "mime_types", value: "jpg"),
        ]

        guard let url = components.url else {
            throw CatRepositoryError.networkError
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue(APIKey, forHTTPHeaderField: "x-api-key")

        logger.info("Retrieving cats from: \(urlRequest.url?.absoluteString ?? "")")

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: urlRequest)
        } catch {
            logger.error("Network error: \(error)")
            throw CatRepositoryError.networkError
        }

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw CatRepositoryError.networkError
        }
        
        let cats: [Cat]
        do {
            cats = try JSONDecoder().decode([Cat].self, from: data)
        } catch {
            logger.error("Decoding failed: \(error)")
            throw CatRepositoryError.decodingErrror
        }

        logger.info("Cats successfully retrieved!")

        let paginationCount = httpResponse.value(forHTTPHeaderField: "Pagination-Count").flatMap(Int.init) ?? 0
        let totalPages = paginationCount == 0 ? 0 : (paginationCount + paginationLimit - 1) / paginationLimit

        return Page(totalPages: totalPages, cats: cats)
    }
}
