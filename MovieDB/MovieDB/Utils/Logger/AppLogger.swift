//
//  AppLogger.swift
//  MovieDB
//
//  Created by Eliane Regina Nicácio Mendes on 03/03/26.
//

import Foundation
import os.log

protocol LoggerProtocol {
    func logAPIRequest(method: String, endpoint: String)
    func logAPIResponse(statusCode: Int, duration: TimeInterval)
    func logAPIError(_ error: Error, context: String)
    func logPersistenceEvent(_ message: String)
}

final class AppLogger: LoggerProtocol {
    // MARK: - Properties
    private let networkLog = OSLog(
        subsystem: "com.moviedb",
        category: "Network"
    )
    private let persistenceLog = OSLog(
        subsystem: "com.moviedb",
        category: "Persistence"
    )
    
    // MARK: - Initialization
    init() {}
    
    // MARK: - LoggerProtocol
    func logAPIRequest(
        method: String = "GET",
        endpoint: String
    ) {
        os_log(
            "🌐 [%{public}@] %{public}@",
            log: networkLog,
            type: .debug,
            method,
            endpoint
        )
    }
    
    func logAPIResponse(statusCode: Int, duration: TimeInterval) {
        let emoji = (200...299).contains(statusCode) ? "✅" : "⚠️"
        os_log(
            "%{public}@ Response: %d (%.3fs)",
            log: networkLog,
            type: .debug,
            emoji,
            statusCode,
            duration
        )
    }
    
    func logAPIError(
        _ error: Error,
        context: String
    ) {
        os_log(
            "❌ [%{public}@] %{public}@",
            log: networkLog,
            type: .error,
            context,
            error.localizedDescription
        )
    }
    
    func logPersistenceEvent(
        _ message: String
    ) {
        os_log(
            "%{public}@",
            log: persistenceLog,
            type: .debug,
            message
        )
    }
}
