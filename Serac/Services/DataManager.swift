//
//  DataManager.swift
//  Serac
//
//  Created by Mike Polan on 11/12/21.
//

import Foundation

// MARK: - Errors

enum DataImportError: LocalizedError {
    case invalidFileFormat(description: String, reason: String, recovery: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidFileFormat(let description, _, _):
            return description
        }
    }
    
    var failureReason: String? {
        switch self {
        case .invalidFileFormat(_, let reason, _):
            return reason
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .invalidFileFormat(_, _, let recovery):
            return recovery
        }
    }
}

// MARK: - Protocol

protocol DataImporter {
    func load(contentsOf url: URL) -> Result<[CollectionItem], DataImportError>
}
