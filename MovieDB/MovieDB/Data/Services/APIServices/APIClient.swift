//
//  APIClient.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 06/03/26.
//

import Foundation
final class APIClient {
    
    // MARK: - Properties
    
    private let session: URLSession
    private let decoder: JSONDecoder
    private let logger: LoggerProtocol
    
    // MARK: - Initialization
    
    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        logger: LoggerProtocol = AppLogger()
    ) {
        self.session = session
        self.decoder = decoder
        self.logger = logger
    }
    
    // MARK: - Methods
    
    func request<T: Decodable>(
        url: URL,
        expecting: T.Type
    ) async throws -> T {
        let startTime = Date()
        logger.logAPIRequest(method: "GET", endpoint: url.absoluteString)
        do {
            let (data, response) = try await session.data(from: url)
            let duration = Date().timeIntervalSince(startTime)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown
            }
            
            // Log response
            logger.logAPIResponse(
                statusCode: httpResponse.statusCode,
                duration: duration
            )
            
            // Validar status code
            try validateStatusCode(httpResponse.statusCode)
            
            // Decodificar resposta
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                logger.logAPIError(error, context: "Decoding")
                throw NetworkError.decodingError(details:
                                                    error.localizedDescription)
            }
        } catch let error as NetworkError {
            logger.logAPIError(error, context: "APIClient")
            throw error
        } catch {
            let networkError = NetworkError.unknown
            logger.logAPIError(networkError, context: "APIClient")
            throw networkError
        }
    }
    
    // MARK: - Private Methods
    
    private func validateStatusCode(_ code: Int) throws {
        switch code {
        case 200...299:
            break
        case 400:
            throw NetworkError.invalidURL
        case 401:
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.forbidden
        case 404:
            throw NetworkError.notFound
        case 500...599:
            throw NetworkError.serverError(statusCode: code)
        default:
            throw NetworkError.unknown
        }
    }
}
