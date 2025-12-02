//
//  ImportExportUtilities.swift
//  Forgetze
//
//  Created on 2025-01-27.
//

import Foundation
import SwiftData

// MARK: - Import Export Utilities

struct ImportExportUtilities {
    
    /// Validates if a file is a valid Forgetze file
    /// - Parameter url: The file URL to validate
    /// - Returns: True if valid Forgetze file
    static func isValidForgetzeFile(_ url: URL) -> Bool {
        return url.pathExtension.lowercased() == "forgetze"
    }
    
    /// Imports a contact from Forgetze file data
    /// - Parameter data: The file data to import
    /// - Returns: The imported Contact
    /// - Throws: ImportError if the operation fails
    static func importContact(from data: Data) throws -> Contact {
        do {
            let forgetzeFile = try JSONDecoder().decode(ForgetzeFile.self, from: data)
            return forgetzeFile.contact.toContact()
        } catch DecodingError.keyNotFound(let key, let context) {
            throw ImportError.missingKey(key, context.debugDescription)
        } catch DecodingError.valueNotFound(let value, let context) {
            throw ImportError.missingValue(value, context.debugDescription)
        } catch DecodingError.typeMismatch(let type, let context) {
            throw ImportError.typeMismatch(type, context.debugDescription)
        } catch DecodingError.dataCorrupted(let context) {
            throw ImportError.dataCorrupted(context.debugDescription)
        } catch {
            throw ImportError.decodingFailed(error.localizedDescription)
        }
    }
    
    /// Exports a contact to Forgetze file format
    /// - Parameter contact: The contact to export
    /// - Returns: The exported file data
    /// - Throws: ExportError if the operation fails
    static func exportContact(_ contact: Contact) throws -> Data {
        do {
            return try ForgetzeFile.export(contact: contact)
        } catch {
            throw ExportError.exportFailed(error.localizedDescription)
        }
    }
    
    /// Creates a user-friendly filename for a contact
    /// - Parameter contact: The contact to create filename for
    /// - Returns: Sanitized filename
    static func createFilename(for contact: Contact, extension: String) -> String {
        let sanitizedName = contact.displayName
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: "\\", with: "-")
            .replacingOccurrences(of: ":", with: "-")
        return "\(sanitizedName).\(`extension`)"
    }
}

// MARK: - Import Errors

enum ImportError: LocalizedError {
    case missingKey(String, String)
    case missingValue(String, String)
    case typeMismatch(String, String)
    case dataCorrupted(String)
    case decodingFailed(String)
    case fileAccessFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .missingKey(let key, let context):
            return "Missing required field '\(key)': \(context)"
        case .missingValue(let value, let context):
            return "Missing required value '\(value)': \(context)"
        case .typeMismatch(let type, let context):
            return "Invalid data type for '\(type)': \(context)"
        case .dataCorrupted(let context):
            return "File data is corrupted: \(context)"
        case .decodingFailed(let message):
            return "Failed to decode file: \(message)"
        case .fileAccessFailed(let message):
            return "File access failed: \(message)"
        }
    }
}

// MARK: - Export Errors

enum ExportError: LocalizedError {
    case exportFailed(String)
    case fileCreationFailed(String)
    case dataGenerationFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .exportFailed(let message):
            return "Export failed: \(message)"
        case .fileCreationFailed(let message):
            return "File creation failed: \(message)"
        case .dataGenerationFailed(let message):
            return "Data generation failed: \(message)"
        }
    }
}
