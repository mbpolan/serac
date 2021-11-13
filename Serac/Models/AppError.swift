//
//  AppError.swift
//  Serac
//
//  Created by Mike Polan on 11/13/21.
//

import Foundation

enum AppError: LocalizedError {
    case dataImportError(error: DataImportError)
    
    var errorDescription: String? {
        switch self {
        case .dataImportError(let error):
            return error.errorDescription
        }
    }
    
    var failureReason: String? {
        switch self {
        case .dataImportError(let error):
            return error.failureReason
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .dataImportError(let error):
            return error.recoverySuggestion
        }
    }
}
