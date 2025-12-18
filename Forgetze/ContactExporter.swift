import Foundation
import Contacts
import UIKit
import PDFKit

@MainActor
class ContactExporter {
    static let shared = ContactExporter()
    
    private init() {}
    
    // MARK: - Apple Contacts Export
    
    func exportToAppleContacts(_ contact: Contact) async throws {
        let store = CNContactStore()
        
        // Check permissions
        let status = CNContactStore.authorizationStatus(for: .contacts)
        if status == .denied || status == .restricted {
            throw ExportError.accessDenied
        }
        
        if status == .notDetermined {
            let granted = try await store.requestAccess(for: .contacts)
            if !granted {
                throw ExportError.accessDenied
            }
        }
        
        // Create mutable contact
        let mutableContact = CNMutableContact()
        mutableContact.givenName = contact.firstName
        mutableContact.familyName = contact.lastName
        // Append Spouse and Children to Notes
        var exportNote = contact.notes
        
        var extraInfo: [String] = []
        
        if let spouse = contact.spouse {
            var spouseInfo = "Spouse: \(spouse.displayName)"
            if let bday = spouse.birthday {
                spouseInfo += " (Born \(bday.shortDisplayString))"
            }
            extraInfo.append(spouseInfo)
        }
        
        if contact.hasKids {
            let kidsInfo = contact.kids.map { kid in
                var info = "Child: \(kid.displayName)"
                if let bday = kid.birthday {
                    info += " (Born \(bday.shortDisplayString))"
                }
                return info
            }.joined(separator: "\n")
            extraInfo.append(kidsInfo)
        }
        
        if !extraInfo.isEmpty {
            if !exportNote.isEmpty {
                exportNote += "\n\n"
            }
            exportNote += extraInfo.joined(separator: "\n")
        }
        
        mutableContact.note = exportNote
        
        // Add Birthday
        if let bday = contact.birthday {
            var components = DateComponents()
            components.month = bday.month
            components.day = bday.day
            if let year = bday.year {
                components.year = year
            }
            mutableContact.birthday = components
        }
        
        // Add Addresses
        mutableContact.postalAddresses = contact.addresses.map { address in
            let postal = CNMutablePostalAddress()
            postal.street = (address.street + (address.street2 != nil ? "\n\(address.street2!)" : ""))
            postal.city = address.city
            postal.state = address.state
            postal.postalCode = address.zip
            postal.country = address.country
            
            let label = address.isDefault ? CNLabelHome : (address.type.isEmpty ? CNLabelOther : address.type)
            return CNLabeledValue(label: label, value: postal)
        }
        
        // Add Social Profiles
        mutableContact.socialProfiles = contact.socialMediaURLs.compactMap { urlString in
            guard let url = URL(string: urlString), url.scheme != nil else { return nil }
            // Simple heuristic for service type
            let service: String
            if urlString.localizedCaseInsensitiveContains("facebook") { service = CNSocialProfileServiceFacebook }
            else if urlString.localizedCaseInsensitiveContains("twitter") || urlString.localizedCaseInsensitiveContains("x.com") { service = CNSocialProfileServiceTwitter }
            else if urlString.localizedCaseInsensitiveContains("linkedin") { service = CNSocialProfileServiceLinkedIn }
            else if urlString.localizedCaseInsensitiveContains("flickr") { service = CNSocialProfileServiceFlickr }
            else if urlString.localizedCaseInsensitiveContains("myspace") { service = CNSocialProfileServiceMySpace }
            else if urlString.localizedCaseInsensitiveContains("sina") { service = CNSocialProfileServiceSinaWeibo }
            else { service = "Other" }
            
            let profile = CNSocialProfile(urlString: urlString, username: nil, userIdentifier: nil, service: service)
            return CNLabeledValue(label: nil, value: profile)
        }
        
        // Save Request
        let saveRequest = CNSaveRequest()
        saveRequest.add(mutableContact, toContainerWithIdentifier: nil)
        
        try store.execute(saveRequest)
    }
    
    // MARK: - vCard Export
    
    func createVCard(for contact: Contact) throws -> URL {
        var vCard = "BEGIN:VCARD\nVERSION:3.0\n"
        vCard += "N:\(contact.lastName);\(contact.firstName);;;\n"
        vCard += "FN:\(contact.displayName)\n"
        
        if !contact.notes.isEmpty {
             let safeNotes = contact.notes.replacingOccurrences(of: "\n", with: "\\n")
             vCard += "NOTE:\(safeNotes)\n"
        }
        
        if let bday = contact.birthday {
            let year = bday.year ?? 0000
            if bday.year != nil {
                let chunk = String(format: "%04d-%02d-%02d", year, bday.month, bday.day)
                vCard += "BDAY:\(chunk)\n"
            }
        }
        
        for address in contact.addresses {
            let label = address.isDefault ? "HOME" : "WORK"
            let street = address.street + (address.street2.map { ", " + $0 } ?? "")
            vCard += "ADR;TYPE=\(label):;;\(street);\(address.city);\(address.state);\(address.zip);\(address.country)\n"
        }
        
        for url in contact.socialMediaURLs {
            vCard += "URL:\(url)\n"
        }
        
        vCard += "END:VCARD"
        
        let fileName = "\(contact.firstName)_\(contact.lastName).vcf"
        let tempUrl = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        try vCard.write(to: tempUrl, atomically: true, encoding: .utf8)
        return tempUrl
    }
    
    // MARK: - PDF Export
    
    // MARK: - PDF Export
    
    func createPDF(for contact: Contact) throws -> URL {
        let pdfMetaData = [
            kCGPDFContextCreator: "Forgetze App",
            kCGPDFContextAuthor: "Forgetze User"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11.0 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let margin: CGFloat = 50.0
        let contentWidth = pageWidth - (margin * 2)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { (context) in
            context.beginPage()
            
            var currentY: CGFloat = margin
            
            // Helper to check for new page
            func checkPageBounds(accruedHeight: CGFloat) {
                if currentY + accruedHeight > pageHeight - margin {
                    context.beginPage()
                    currentY = margin
                }
            }
            
            // Helper to draw text with wrapping
            func drawText(_ text: String, font: UIFont, color: UIColor = .black, isTitle: Bool = false) {
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: color
                ]
                let attributedString = NSAttributedString(string: text, attributes: attributes)
                
                // Calculate height needed
                let size = attributedString.boundingRect(
                    with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    context: nil
                ).size
                
                checkPageBounds(accruedHeight: size.height + (isTitle ? 10 : 20)) // Extra spacing
                
                attributedString.draw(in: CGRect(x: margin, y: currentY, width: contentWidth, height: size.height))
                currentY += size.height + (isTitle ? 5 : 15) // Spacing after text
            }
            
            // Draw Header
            drawText(contact.displayName, font: .systemFont(ofSize: 24.0, weight: .bold), isTitle: true)
            currentY += 10
            
            // Draw Note
            if !contact.notes.isEmpty {
                drawText("Notes", font: .systemFont(ofSize: 14, weight: .semibold), color: .darkGray, isTitle: true)
                drawText(contact.notes, font: .systemFont(ofSize: 12))
            }
            
            // Draw Birthday
            if let birthday = contact.birthday {
                drawText("Birthday", font: .systemFont(ofSize: 14, weight: .semibold), color: .darkGray, isTitle: true)
                drawText(birthday.displayString, font: .systemFont(ofSize: 12))
            }
            
            // Draw Spouse
            if let spouse = contact.spouse {
                drawText("Spouse", font: .systemFont(ofSize: 14, weight: .semibold), color: .darkGray, isTitle: true)
                var spouseInfo = spouse.displayName
                if let bday = spouse.birthday {
                    spouseInfo += " (Born \(bday.shortDisplayString), Age: \(bday.age ?? 0))"
                }
                drawText(spouseInfo, font: .systemFont(ofSize: 12))
            }
            
            // Draw Children
            if contact.hasKids {
                drawText("Children", font: .systemFont(ofSize: 14, weight: .semibold), color: .darkGray, isTitle: true)
                let kidString = contact.kids.map { kid in
                    var info = kid.displayName
                    if let bday = kid.birthday {
                        info += " (Born \(bday.shortDisplayString), Age: \(bday.age ?? 0))"
                    }
                    return info
                }.joined(separator: "\n")
                drawText(kidString, font: .systemFont(ofSize: 12))
            }
            
            // Draw Addresses
            if contact.hasAddresses {
                drawText("Addresses", font: .systemFont(ofSize: 14, weight: .semibold), color: .darkGray, isTitle: true)
                let addrString = contact.addresses.map { addr in
                    [addr.street, addr.street2 ?? "", addr.city, addr.state, addr.zip, addr.country]
                        .filter { !$0.isEmpty }
                        .joined(separator: ", ")
                }.joined(separator: "\n")
                drawText(addrString, font: .systemFont(ofSize: 12))
            }
            
            // Draw Social Media
            if contact.hasSocialMedia {
                drawText("Social Media", font: .systemFont(ofSize: 14, weight: .semibold), color: .darkGray, isTitle: true)
                drawText(contact.socialMediaURLs.joined(separator: "\n"), font: .systemFont(ofSize: 12))
            }
        }
        
        let fileName = "\(contact.firstName)_\(contact.lastName).pdf"
        let tempUrl = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        try data.write(to: tempUrl)
        return tempUrl
    }
}

enum ExportError: LocalizedError {
    case accessDenied
    case generic(String)
    
    var errorDescription: String? {
        switch self {
        case .accessDenied: return "Access to Contacts was denied. Please enable it in Settings."
        case .generic(let msg): return msg
        }
    }
}
