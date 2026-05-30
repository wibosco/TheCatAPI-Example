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
    
    func retrieveCats(_ page: Int = 0) async throws -> [Cat] {
        let APIKey = "live_yzNvM2rsrxvWpSwtsAWzbSiGoGW175yNLmnO1u5Fh5GMFxbZ9l4C01t9BcP2v6WQ" // To get access to the full response, replace this empty string with your API key from: https://thecatapi.com/
        
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
        
        let orderQueryItem = URLQueryItem(name: "order", value: "DESC")
        let limitQueryItem = URLQueryItem(name: "limit", value: "48")
        let pageItem = URLQueryItem(name: "page", value: "\(page)")
        
        let queryItems = [orderQueryItem, limitQueryItem, pageItem]
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.thecatapi.com"
        components.path = "/v1/images/search"
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw CatRepositoryError.networkError
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue(APIKey, forHTTPHeaderField: "x-api-key")
        
        logger.info("Retrieving cats...")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
               throw CatRepositoryError.networkError
            }
            
            guard let cats = try? JSONDecoder().decode([Cat].self, from: data) else {
                throw CatRepositoryError.decodingErrror
            }
            
            logger.info("Cats successfully retrieved!")
            
           return cats
        } catch let error as CatRepositoryError {
            throw error
        } catch {
            throw CatRepositoryError.networkError
        }
    }
}
