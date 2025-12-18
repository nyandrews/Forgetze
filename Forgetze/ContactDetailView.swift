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

    @State private var showingAddressEdit = false
    @State private var selectedAddress: Address?
    @State private var showingSocialMediaEdit = false
    @State private var newSocialMediaURL = ""
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
    let contact: Contact
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                notesSection // Moved to top
                if contact.hasPhoneNumber {
                    phoneSection
                }
                birthdaySection
                spouseSection
                childrenSection
                addressesSection
                socialMediaSection
            }
            .padding(.vertical)
        }
        .ignoresSafeArea(edges: .top)
        .navigationTitle("") // Hidden to allow hero header to shine
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
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Header Section
    // SWITCH: Change this to use legacyHeaderSection to rollback
    private var headerSection: some View {
        ContactHeroHeader(
            contact: contact,
            appSettings: appSettings
        )
        .listRowInsets(EdgeInsets()) // If in list
    }

    // MARK: - Legacy Header (Rollback)
    private var legacyHeaderSection: some View {
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
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(appSettings.primaryColor.color.opacity(0.3), lineWidth: 1)
                )
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
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .modernCardBackground(glassEffectEnabled: appSettings.glassEffectEnabled)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(appSettings.primaryColor.color.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Spouse Section
    private var spouseSection: some View {
        Group {
            if let spouse = contact.spouse {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(appSettings.primaryColor.color)
                        Text("Spouse")
                            .font(.headline)
                            .foregroundColor(appSettings.primaryColor.color)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(spouse.displayName)
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        if let birthday = spouse.birthday {
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
                    .modernCardBackground(glassEffectEnabled: appSettings.glassEffectEnabled)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(appSettings.primaryColor.color.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Notes Section
    private var notesSection: some View {
        Group {
            if !contact.notes.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "note.text")
                            .foregroundColor(appSettings.primaryColor.color)
                        Text("Notes")
                            .font(.headline)
                            .foregroundColor(appSettings.primaryColor.color)
                    }
                    
                    Text(contact.notes)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .modernCardBackground(glassEffectEnabled: appSettings.glassEffectEnabled)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(appSettings.primaryColor.color.opacity(0.3), lineWidth: 1)
                        )
                }
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
                            .modernCardBackground(glassEffectEnabled: appSettings.glassEffectEnabled)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(appSettings.primaryColor.color.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .modernCardBackground(glassEffectEnabled: appSettings.glassEffectEnabled)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(appSettings.primaryColor.color.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Addresses Section
    private var addressesSection: some View {
        Group {
            if contact.hasAddresses {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "location")
                            .foregroundColor(appSettings.primaryColor.color)
                        Text(contact.addressesCount == 1 ? "Address" : "Addresses")
                            .font(.headline)
                            .foregroundColor(appSettings.primaryColor.color)
                        
                        Spacer()
                    }
                    
                    VStack(spacing: 12) {
                        ForEach(contact.addresses) { address in
                            AddressCard(
                                address: address,
                                themeColor: appSettings.primaryColor.color,
                                onEdit: nil,
                                onDelete: nil,
                                onSetDefault: nil
                            )
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Social Media Section
    private var socialMediaSection: some View {
        Group {
            if contact.hasSocialMedia {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "link")
                            .foregroundColor(appSettings.primaryColor.color)
                        Text("Social Media")
                            .font(.headline)
                            .foregroundColor(appSettings.primaryColor.color)
                        
                        Spacer()
                    }
                    
                    LazyVStack(spacing: 12) {
                        ForEach(contact.socialMediaURLs.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }, id: \.self) { url in
                            SocialMediaCard(
                                url: url,
                                themeColor: appSettings.primaryColor.color,
                                onDelete: nil
                            )
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Contact Deletion
    private func deleteContact() {
        Task {
            do {
                try await DataProtectionManager.shared.safeDelete(contact, in: modelContext)
                // Deletion successful - navigation will handle going back
            } catch {
                errorMessage = "Failed to delete contact: \(error.localizedDescription)"
                showingErrorAlert = true
            }
        }
    }
    
    // MARK: - Address Management
    private func deleteAddress(_ address: Address) {
        Task {
            do {
                // Safe Delete for Address
                // Ideally this would be safeDelete, but since address is a relationship, we remove it from the array
                // and then perform a safeSave on the parent contact
                contact.addresses.removeAll { $0.id == address.id }
                try await DataProtectionManager.shared.safeSave(contact, in: modelContext)
                successMessage = "Address deleted successfully"
                showingSuccessAlert = true
            } catch {
                errorMessage = "Failed to delete address: \(error.localizedDescription)"
                showingErrorAlert = true
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
                try await DataProtectionManager.shared.safeSave(contact, in: modelContext)
                successMessage = "Default address updated"
                showingSuccessAlert = true
            } catch {
                errorMessage = "Failed to set default address: \(error.localizedDescription)"
                showingErrorAlert = true
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
                try await DataProtectionManager.shared.safeSave(contact, in: modelContext)
                successMessage = "Address saved successfully"
                showingSuccessAlert = true
                self.selectedAddress = nil
                showingAddressEdit = false
            } catch {
                errorMessage = "Failed to save address: \(error.localizedDescription)"
                showingErrorAlert = true
            }
        }
    }
    
    private func addSocialMedia(_ url: String) {
        Task {
            do {
                let trimmedURL = url.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmedURL.isEmpty {
                    contact.socialMediaURLs.append(trimmedURL)
                    try await DataProtectionManager.shared.safeSave(contact, in: modelContext)
                    successMessage = "Social media link added successfully"
                    showingSuccessAlert = true
                }
            } catch {
                errorMessage = "Failed to add social media link: \(error.localizedDescription)"
                showingErrorAlert = true
            }
        }
    }
    
    private func deleteSocialMedia(_ url: String) {
        Task {
            do {
                contact.socialMediaURLs.removeAll { $0 == url }
                try await DataProtectionManager.shared.safeSave(contact, in: modelContext)
                successMessage = "Social media link deleted successfully"
                showingSuccessAlert = true
            } catch {
                errorMessage = "Failed to delete social media link: \(error.localizedDescription)"
                showingErrorAlert = true
            }
        }
    }
    // MARK: - Phone Section
    private var phoneSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "phone.fill")
                    .foregroundColor(appSettings.primaryColor.color)
                Text("Phone Numbers")
                    .font(.headline)
                    .foregroundColor(appSettings.primaryColor.color)
            }
            
            ForEach(contact.displayPhoneNumbers) { phoneNumber in
                Button(action: {
                    callNumber(phoneNumber.number)
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(phoneNumber.number)
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            Text(phoneNumber.label)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "phone.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .modernCardBackground(glassEffectEnabled: appSettings.glassEffectEnabled)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(appSettings.primaryColor.color.opacity(0.3), lineWidth: 1)
                    )
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func callNumber(_ phoneNumber: String) {
        let cleanNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if let url = URL(string: "tel://\(cleanNumber)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
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

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Contact.self, Address.self, Spouse.self, Kid.self, Birthday.self, PhoneNumber.self, configurations: config)
    
    let contact = Contact(firstName: "Preview", lastName: "User", phoneNumbers: [PhoneNumber(number: "555-1234")])
    container.mainContext.insert(contact)
    
    return ContactDetailView(contact: contact)
        .environmentObject(AppSettings())
        .modelContainer(container)
}

// MARK: - Hero Header Components

struct ContactHeroHeader: View {
    let contact: Contact
    let appSettings: AppSettings
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 1. Immersive Background
            // We use a gradient based on the app's primary color
            LinearGradient(
                gradient: Gradient(colors: [
                    appSettings.primaryColor.color.opacity(0.8),
                    appSettings.primaryColor.color.opacity(0.4),
                    Color(.systemBackground)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 280)
            .ignoresSafeArea()
            .offset(y: -40) // Push up slightly
            
            // 2. Content Stack
            VStack(spacing: 16) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Color(.systemBackground))
                        .frame(width: 110, height: 110)
                        .shadow(radius: 8)
                    
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [appSettings.primaryColor.color, appSettings.primaryColor.color.opacity(0.7)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                    
                    Text(contact.initials)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.top, 60) // Push down to avoid navigation bar overlap
                
                // Name & Info
                VStack(spacing: 4) {
                    Text(contact.displayName)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                    
                    if let birthday = contact.birthday {
                        Label(birthday.ageDisplayString, systemImage: "gift.fill")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.bottom, 20) // Add bottom padding since action bar is gone
            }
            .padding(.bottom, 20)
        }
    }
}
