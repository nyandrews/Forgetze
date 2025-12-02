//
//  FileManager+Extensions.swift
//  Forgetze
//
//  Created on 2025-01-27.
//

import Foundation

// MARK: - File Operations Extension

extension FileManager {
    
    /// Creates a secure file URL in the caches directory with proper coordination
    /// - Parameters:
    ///   - fileName: The name of the file to create
    ///   - subdirectory: Optional subdirectory name
    ///   - data: The data to write to the file
    /// - Returns: The URL of the created file
    /// - Throws: FileManagerError if the operation fails
    func createSecureFile(fileName: String, in subdirectory: String? = nil, with data: Data) throws -> URL {
        let cachesDirectory = urls(for: .cachesDirectory, in: .userDomainMask)[0]
        
        var fileURL = cachesDirectory
        if let subdirectory = subdirectory {
            let subdirectoryURL = fileURL.appendingPathComponent(subdirectory, isDirectory: true)
            try? createDirectory(at: subdirectoryURL, withIntermediateDirectories: true)
            fileURL = subdirectoryURL
        }
        
        fileURL = fileURL.appendingPathComponent(fileName)
        
        // Write data with proper coordination
        let coordinator = NSFileCoordinator()
        var coordinatorError: NSError?
        coordinator.coordinate(writingItemAt: fileURL, options: .forReplacing, error: &coordinatorError) { url in
            try? data.write(to: url)
        }
        
        // Verify file was created successfully
        guard fileExists(atPath: fileURL.path),
              isReadableFile(atPath: fileURL.path) else {
            throw FileManagerError.fileCreationFailed(fileURL.path)
        }
        
        return fileURL
    }
    
    /// Safely reads data from a URL with security scoped resource access
    /// - Parameter url: The URL to read from
    /// - Returns: The data read from the file
    /// - Throws: FileManagerError if the operation fails
    func readSecureFile(from url: URL) throws -> Data {
        let success = url.startAccessingSecurityScopedResource()
        defer {
            if success {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        guard fileExists(atPath: url.path) else {
            throw FileManagerError.fileNotFound(url.path)
        }
        
        guard isReadableFile(atPath: url.path) else {
            throw FileManagerError.fileNotReadable(url.path)
        }
        
        return try Data(contentsOf: url)
    }
}

// MARK: - File Manager Errors

enum FileManagerError: LocalizedError {
    case fileNotFound(String)
    case fileNotReadable(String)
    case fileCreationFailed(String)
    case invalidFileType(String)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let path):
            return "File not found: \(path)"
        case .fileNotReadable(let path):
            return "File is not readable: \(path)"
        case .fileCreationFailed(let path):
            return "Failed to create file: \(path)"
        case .invalidFileType(let type):
            return "Invalid file type: \(type)"
        }
    }
}
