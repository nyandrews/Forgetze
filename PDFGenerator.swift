//
//  PDFGenerator.swift
//  Forgetze
//
//  Created on 2025-01-27.
//

import Foundation
import UIKit
import SwiftUI

// MARK: - PDF Generator

struct PDFGenerator {
    
    /// Generates PDF data for a contact
    /// - Parameter contact: The contact to generate PDF for
    /// - Returns: PDF data
    /// - Throws: PDFGenerationError if generation fails
    static func generatePDF(for contact: Contact) throws -> Data {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // Standard letter size
        let pdfData = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(pdfData, pageRect, nil)
        UIGraphicsBeginPDFPage()
        
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndPDFContext()
            throw PDFGenerationError.contextCreationFailed
        }
        
        // Initialize context
        context.saveGState()
        context.setFillColor(UIColor.white.cgColor)
        context.fill(pageRect)
        context.restoreGState()
        
        // Set up fonts and colors
        let titleFont = UIFont.boldSystemFont(ofSize: 24)
        let headerFont = UIFont.boldSystemFont(ofSize: 18)
        let bodyFont = UIFont.systemFont(ofSize: 14)
        
        let titleColor = UIColor.label
        let headerColor = UIColor.label
        let bodyColor = UIColor.label
        
        var yPosition: CGFloat = 50
        
        // Draw contact title
        yPosition = drawText(
            text: contact.displayName,
            font: titleFont,
            color: titleColor,
            yPosition: yPosition,
            pageRect: pageRect
        )
        
        yPosition += 20
        
        // Draw basic information
        yPosition = drawSectionHeader("Basic Information", font: headerFont, color: headerColor, yPosition: yPosition, pageRect: pageRect)
        
        if let birthday = contact.birthday {
            yPosition = drawText("Birthday: \(birthday.displayString) (\(birthday.ageDisplayString))", font: bodyFont, color: bodyColor, yPosition: yPosition, pageRect: pageRect)
        }
        
        if let spouseName = contact.spouseName, !spouseName.isEmpty {
            var spouseText = "Spouse: \(spouseName)"
            if let spouseBirthday = contact.spouseBirthday {
                spouseText += " (Born \(spouseBirthday.displayString))"
            }
            yPosition = drawText(spouseText, font: bodyFont, color: bodyColor, yPosition: yPosition, pageRect: pageRect)
        }
        
        if !contact.notes.isEmpty {
            yPosition = drawText("Notes: \(contact.notes)", font: bodyFont, color: bodyColor, yPosition: yPosition, pageRect: pageRect)
        }
        
        yPosition += 20
        
        // Draw children information
        if let kids = contact.kids, !kids.isEmpty {
            yPosition = drawSectionHeader("Children", font: headerFont, color: headerColor, yPosition: yPosition, pageRect: pageRect)
            
            for kid in kids {
                var kidText = "• \(kid.displayName)"
                if let kidBirthday = kid.birthday {
                    kidText += " (Born \(kidBirthday.displayString))"
                }
                yPosition = drawText(kidText, font: bodyFont, color: bodyColor, yPosition: yPosition, pageRect: pageRect)
            }
            
            yPosition += 20
        }
        
        // Draw addresses
        if let addresses = contact.addresses, !addresses.isEmpty {
            yPosition = drawSectionHeader("Addresses", font: headerFont, color: headerColor, yPosition: yPosition, pageRect: pageRect)
            
            for address in addresses {
                yPosition = drawText("\(address.type): \(address.fullAddress)", font: bodyFont, color: bodyColor, yPosition: yPosition, pageRect: pageRect)
            }
            
            yPosition += 20
        }
        
        // Draw social media
        if !contact.socialMediaURLs.isEmpty {
            let validURLs = contact.socialMediaURLs.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            if !validURLs.isEmpty {
                yPosition = drawSectionHeader("Social Media", font: headerFont, color: headerColor, yPosition: yPosition, pageRect: pageRect)
                
                for urlString in validURLs {
                    yPosition = drawText("• \(urlString)", font: bodyFont, color: bodyColor, yPosition: yPosition, pageRect: pageRect)
                }
            }
        }
        
        UIGraphicsEndPDFContext()
        
        return pdfData as Data
    }
    
    // MARK: - Private Drawing Methods
    
    private static func drawSectionHeader(_ text: String, font: UIFont, color: UIColor, yPosition: CGFloat, pageRect: CGRect) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color
        ]
        
        let textSize = text.size(withAttributes: attributes)
        let textRect = CGRect(x: 50, y: yPosition, width: pageRect.width - 100, height: textSize.height)
        
        text.draw(in: textRect, withAttributes: attributes)
        
        return yPosition + textSize.height + 10
    }
    
    private static func drawText(_ text: String, font: UIFont, color: UIColor, yPosition: CGFloat, pageRect: CGRect) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color
        ]
        
        let textSize = text.size(withAttributes: attributes)
        let textRect = CGRect(x: 70, y: yPosition, width: pageRect.width - 140, height: textSize.height)
        
        text.draw(in: textRect, withAttributes: attributes)
        
        return yPosition + textSize.height + 5
    }
}

// MARK: - PDF Generation Errors

enum PDFGenerationError: LocalizedError {
    case contextCreationFailed
    case drawingFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .contextCreationFailed:
            return "Failed to create PDF graphics context"
        case .drawingFailed(let message):
            return "PDF drawing failed: \(message)"
        }
    }
}
