import SwiftUI

struct ExportOptionsView: View {
    let contact: Contact
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appSettings: AppSettings
    
    @State private var showingExportAlert = false
    @State private var exportMessage = ""
    @State private var showingShareSheet = false
    @State private var shareURL: URL?
    
    // Keep exporter internal to this view or pass it in if needed, but shared instance is fine here
    private let exporter = ContactExporter.shared
    
    var body: some View {
        NavigationView {
            List {
                Section("Export Options") {
                    Button("Export to Apple Contacts") {
                        exportToAppleContacts()
                    }
                    .foregroundColor(appSettings.primaryColor.color)
                    .fontWeight(.medium)
                    
                    Button("Export as PDF") {
                        exportAsPDF()
                    }
                    .foregroundColor(appSettings.primaryColor.color)
                    .fontWeight(.medium)
                    
                    Button("Export as vCard") {
                        exportAsVCard()
                    }
                    .foregroundColor(appSettings.primaryColor.color)
                    .fontWeight(.medium)
                }
            }
            .navigationTitle("Export Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(appSettings.primaryColor.color)
                    .fontWeight(.medium)
                }
            }
            .alert("Export", isPresented: $showingExportAlert) {
                Button("OK") { }
            } message: {
                Text(exportMessage)
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = shareURL {
                    ShareSheet(activityItems: [url])
                }
            }
        }
    }
    
    private func exportToAppleContacts() {
        Task {
            do {
                try await exporter.exportToAppleContacts(contact)
                exportMessage = "Successfully exported '\(contact.displayName)' to Apple Contacts."
                showingExportAlert = true
            } catch {
                exportMessage = "Export failed: \(error.localizedDescription)"
                showingExportAlert = true
            }
        }
    }
    
    private func exportAsPDF() {
        do {
            let url = try exporter.createPDF(for: contact)
            self.shareURL = url
            self.showingShareSheet = true
        } catch {
            exportMessage = "Failed to create PDF: \(error.localizedDescription)"
            showingExportAlert = true
        }
    }
    
    private func exportAsVCard() {
        do {
            let url = try exporter.createVCard(for: contact)
            self.shareURL = url
            self.showingShareSheet = true
        } catch {
            exportMessage = "Failed to create vCard: \(error.localizedDescription)"
            showingExportAlert = true
        }
    }
}
