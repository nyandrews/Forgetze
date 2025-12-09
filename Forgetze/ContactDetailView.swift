import SwiftUI
import SwiftData
import Contacts
import EventKit
import PDFKit
import UIKit

struct ContactDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appSettings: AppSettings
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var showingShareSheet = false
    @State private var showingExportOptions = false
    @State private var showingSuccessAlert = false
    @State private var successMessage = ""
    @State private var viewMode: ContactViewMode = .advanced // Default to advanced
    @State private var showingAddressEdit = false
    @State private var selectedAddress: Address?
    @State private var showingSocialMediaEdit = false
    @State private var newSocialMediaURL = ""
    
    let contact: Contact
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                // viewModeToggle removed
                birthdaySection
                childrenSection
                addressesSection
                socialMediaSection
            }
            .padding(.vertical)
        }
        .navigationTitle("Contact Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarColorScheme(appSettings.isDarkMode ? .dark : .light)
        .tint(appSettings.primaryColor.color)
        .accentColor(appSettings.primaryColor.color)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.body)
                            .fontWeight(.medium)
                        Text("Back")
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(appSettings.primaryColor.color)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    // Primary Actions
                    Button(action: { showingEditSheet = true }) {
                        Label("Edit Contact", systemImage: "pencil")
                    }
                    
                    Button(action: { showingShareSheet = true }) {
                        Label("Share Contact", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(action: { showingExportOptions = true }) {
                        Label("Export Contact", systemImage: "square.and.arrow.down")
                    }
                    
                    Divider()
                    
                    // Destructive Actions
                    Button(role: .destructive, action: { showingDeleteAlert = true }) {
                        Label("Delete Contact", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(appSettings.primaryColor.color)
                        .font(.title2)
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            ContactEditView(contact: contact)
        }
        .alert("Delete Contact", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteContact()
            }
        } message: {
            Text("Are you sure you want to delete '\(contact.displayName)'? This action cannot be undone.")
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: [contact.shareText])
        }
        .sheet(isPresented: $showingExportOptions) {
            ExportOptionsView(contact: contact)
        }
        .sheet(isPresented: $showingAddressEdit) {
            AddressEditView(address: selectedAddress) { updatedAddress in
                saveAddress(updatedAddress)
            }
        }
        .sheet(isPresented: $showingSocialMediaEdit) {
            SocialMediaEditSheet { url in
                addSocialMedia(url)
            }
        }
        .alert("Success", isPresented: $showingSuccessAlert) {
            Button("OK") { }
        } message: {
            Text(successMessage)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(contact.displayName)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            if !contact.notes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(contact.notes)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .modernCardBackground(glassEffectEnabled: appSettings.glassEffectEnabled)
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Birthday Section
    private var birthdaySection: some View {
        Group {
            if let birthday = contact.birthday {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "gift")
                            .foregroundColor(appSettings.primaryColor.color)
                        Text("Birthday")
                            .font(.headline)
                            .foregroundColor(appSettings.primaryColor.color)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(birthday.displayString)
                            .font(.title2)
                        
                        Text(birthday.ageDisplayString)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .modernCardBackground(glassEffectEnabled: appSettings.glassEffectEnabled)
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Children Section
    private var childrenSection: some View {
        Group {
            if contact.hasKids {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "person.3")
                            .foregroundColor(appSettings.primaryColor.color)
                        Text("Children (\(contact.kidsCount))")
                            .font(.headline)
                            .foregroundColor(appSettings.primaryColor.color)
                    }
                    
                    VStack(spacing: 16) {
                        ForEach(contact.kids) { kid in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(kid.displayName)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                
                                if let birthday = kid.birthday {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Born \(birthday.shortDisplayString)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        
                                        Text("(\(birthday.ageDisplayString))")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                } else {
                                    Text("No birthday set")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .modernCardBackground(glassEffectEnabled: appSettings.glassEffectEnabled)
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Addresses Section
    private var addressesSection: some View {
        Group {
            // Always show addresses
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "location")
                        .foregroundColor(appSettings.primaryColor.color)
                    Text(contact.addressesCount == 1 ? "Address" : "Addresses")
                        .font(.headline)
                        .foregroundColor(appSettings.primaryColor.color)
                    
                    Spacer()
                    
                    Button(action: {
                        selectedAddress = nil
                        showingAddressEdit = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(appSettings.primaryColor.color)
                            .font(.title2)
                    }
                }
                
                if contact.hasAddresses {
                    VStack(spacing: 12) {
                        ForEach(contact.addresses) { address in
                            AddressCard(
                                address: address,
                                themeColor: appSettings.primaryColor.color,
                                onEdit: {
                                    selectedAddress = address
                                    showingAddressEdit = true
                                },
                                onDelete: {
                                    deleteAddress(address)
                                },
                                onSetDefault: {
                                    setDefaultAddress(address)
                                }
                            )
                        }
                    }
                } else {
                    VStack(spacing: 8) {
                        Text("No addresses added yet")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                        
                        Button("Add First Address") {
                            selectedAddress = nil
                            showingAddressEdit = true
                        }
                        .foregroundColor(appSettings.primaryColor.color)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .modernCardBackground(glassEffectEnabled: appSettings.glassEffectEnabled)
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Social Media Section
    private var socialMediaSection: some View {
        Group {
            // Always show social media
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "link")
                        .foregroundColor(appSettings.primaryColor.color)
                    Text("Social Media")
                        .font(.headline)
                        .foregroundColor(appSettings.primaryColor.color)
                    
                    Spacer()
                    
                    Button(action: {
                        showingSocialMediaEdit = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(appSettings.primaryColor.color)
                            .font(.title2)
                    }
                }
                
                if contact.hasSocialMedia {
                    LazyVStack(spacing: 12) {
                        ForEach(contact.socialMediaURLs.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }, id: \.self) { url in
                            SocialMediaCard(
                                url: url,
                                themeColor: appSettings.primaryColor.color,
                                onDelete: {
                                    deleteSocialMedia(url)
                                }
                            )
                        }
                    }
                } else {
                    VStack(spacing: 8) {
                        Text("No social media links added yet")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                        
                        Button("Add First Social Media Link") {
                            showingSocialMediaEdit = true
                        }
                        .foregroundColor(appSettings.primaryColor.color)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .modernCardBackground(glassEffectEnabled: appSettings.glassEffectEnabled)
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Contact Deletion
    private func deleteContact() {
        Task {
            do {
                try await DataProtectionManager.shared.safeDelete(contact, in: modelContext)
                // Deletion successful - navigation will handle going back
            } catch {
                successMessage = "Failed to delete contact: \(error.localizedDescription)"
                showingSuccessAlert = true
            }
        }
    }
    
    // MARK: - Address Management
    private func deleteAddress(_ address: Address) {
        Task {
            do {
                contact.addresses.removeAll { $0.id == address.id }
                try modelContext.save()
                successMessage = "Address deleted successfully"
                showingSuccessAlert = true
            } catch {
                successMessage = "Failed to delete address: \(error.localizedDescription)"
                showingSuccessAlert = true
            }
        }
    }
    
    private func setDefaultAddress(_ address: Address) {
        Task {
            do {
                // Remove default from all other addresses
                for addr in contact.addresses {
                    addr.isDefault = false
                }
                // Set this address as default
                address.isDefault = true
                address.updateTimestamp()
                try modelContext.save()
                successMessage = "Default address updated"
                showingSuccessAlert = true
            } catch {
                successMessage = "Failed to set default address: \(error.localizedDescription)"
                showingSuccessAlert = true
            }
        }
    }
    
    private func saveAddress(_ address: Address) {
        Task {
            do {
                if let selectedAddress = selectedAddress,
                   let existingIndex = contact.addresses.firstIndex(where: { $0.id == selectedAddress.id }) {
                    // Update existing address
                    contact.addresses[existingIndex] = address
                } else {
                    // Add new address
                    contact.addresses.append(address)
                }
                try modelContext.save()
                successMessage = "Address saved successfully"
                showingSuccessAlert = true
                self.selectedAddress = nil
                showingAddressEdit = false
            } catch {
                successMessage = "Failed to save address: \(error.localizedDescription)"
                showingSuccessAlert = true
            }
        }
    }
    
    private func addSocialMedia(_ url: String) {
        Task {
            do {
                let trimmedURL = url.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmedURL.isEmpty {
                    contact.socialMediaURLs.append(trimmedURL)
                    try modelContext.save()
                    successMessage = "Social media link added successfully"
                    showingSuccessAlert = true
                }
            } catch {
                successMessage = "Failed to add social media link: \(error.localizedDescription)"
                showingSuccessAlert = true
            }
        }
    }
    
    private func deleteSocialMedia(_ url: String) {
        Task {
            do {
                contact.socialMediaURLs.removeAll { $0 == url }
                try modelContext.save()
                successMessage = "Social media link deleted successfully"
                showingSuccessAlert = true
            } catch {
                successMessage = "Failed to delete social media link: \(error.localizedDescription)"
                showingSuccessAlert = true
            }
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Social Media Edit Sheet
struct SocialMediaEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appSettings: AppSettings
    
    let onSave: (String) -> Void
    
    @State private var url = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Social Media URL") {
                    TextField("https://example.com", text: $url)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
            }
            .navigationTitle("Add Social Media")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(appSettings.primaryColor.color)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(url)
                        dismiss()
                    }
                    .foregroundColor(appSettings.primaryColor.color)
                    .fontWeight(.medium)
                    .disabled(url.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

// MARK: - Export Options View
struct ExportOptionsView: View {
    let contact: Contact
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appSettings: AppSettings
    
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
        }
    }
    
    private func exportToAppleContacts() {
        // Implementation for Apple Contacts export
    }
    
    private func exportAsPDF() {
        // Implementation for PDF export
    }
    
    private func exportAsVCard() {
        // Implementation for vCard export
    }
}

#Preview {
    ContactDetailView(contact: Contact(firstName: "John", lastName: "Doe"))
        .environmentObject(AppSettings())
        .modelContainer(for: Contact.self, inMemory: true)
}
