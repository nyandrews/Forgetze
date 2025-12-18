import SwiftUI
import SwiftData

/**
 * DataProtectionStatusView - User Interface for Data Protection Status
 * 
 * This view provides users with:
 * - Real-time protection status
 * - Backup information and history
 * - Manual health check capabilities
 * - Recovery options
 * - Protection statistics
 */
struct DataProtectionStatusView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appSettings: AppSettings
    @StateObject private var protectionManager = DataProtectionManager.shared
    @State private var showingHealthCheck = false
    @State private var healthReport: DataHealthReport?
    @State private var showingRecoveryAlert = false
    @State private var showingBackupDetails = false
    
    var body: some View {
        NavigationView {
            List {
                // MARK: - Protection Status Section
                Section("🛡️ PROTECTION STATUS") {
                    HStack {
                        Image(systemName: protectionStatusIcon)
                            .foregroundColor(protectionStatusColor)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(protectionStatusText)
                                .font(.headline)
                                .foregroundColor(protectionStatusColor)
                            
                            Text(protectionStatusDescription)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if protectionManager.isBackingUp {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // MARK: - Backup Information Section
                Section("💾 BACKUP INFORMATION") {
                    HStack {
                        Image(systemName: "archivebox")
                            .foregroundColor(appSettings.primaryColor.color)
                        Text("Total Backups")
                        Spacer()
                        Text("\(protectionManager.backupCount)")
                            .font(.headline)
                            .foregroundColor(appSettings.primaryColor.color)
                    }
                    
                    if let lastBackup = protectionManager.lastBackupDate {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.green)
                            Text("Last Backup")
                            Spacer()
                            Text(lastBackup, style: .relative)
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                    
                    Button(action: {
                        showingBackupDetails = true
                    }) {
                        HStack {
                                                    Image(systemName: "folder")
                            .foregroundColor(appSettings.primaryColor.color)
                            Text("View Backup Details")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }
                
                // MARK: - Data Health Section
                Section("🔍 DATA HEALTH") {
                    if let report = healthReport {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: report.isHealthy ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                    .foregroundColor(report.isHealthy ? .green : .orange)
                                Text("Health Status")
                                Spacer()
                                Text(report.isHealthy ? "Healthy" : "Issues Detected")
                                    .font(.headline)
                                    .foregroundColor(report.isHealthy ? .green : .orange)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Contacts: \(report.validContacts)/\(report.totalContacts) valid")
                                    .font(.caption)
                                    .foregroundColor(report.validContacts == report.totalContacts ? .green : .orange)
                                
                                Text("Children: \(report.validKids)/\(report.totalKids) valid")
                                    .font(.caption)
                                    .foregroundColor(report.validKids == report.totalKids ? .green : .orange)
                                
                                Text("Birthdays: \(report.validBirthdays)/\(report.totalBirthdays) valid")
                                    .font(.caption)
                                    .foregroundColor(report.validBirthdays == report.totalBirthdays ? .green : .orange)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Button(action: {
                        performHealthCheck()
                    }) {
                        HStack {
                                                        Image(systemName: "stethoscope")
                                .foregroundColor(appSettings.primaryColor.color)
                                Text("Run Health Check")
                            Spacer()
                            if showingHealthCheck {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                    }
                    .disabled(showingHealthCheck)
                }
                
                // MARK: - Recovery Options Section
                Section("🔄 RECOVERY OPTIONS") {
                    Button(action: {
                        showingRecoveryAlert = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.red)
                            Text("Emergency Recovery")
                            Spacer()
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                    .disabled(protectionManager.lastOperationStatus == .recovering)
                    
                    Text("Use this only if you're experiencing data issues. This will restore from the most recent backup.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                
                // MARK: - Current Operation Status
                if protectionManager.lastOperationStatus != .idle && protectionManager.lastOperationStatus != .success {
                    Section("📱 CURRENT OPERATION") {
                        HStack {
                            Image(systemName: operationStatusIcon)
                                .foregroundColor(operationStatusColor)
                            Text(operationStatusText)
                                .foregroundColor(operationStatusColor)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Data Protection")
            .navigationBarTitleDisplayMode(.large)
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
            }
            .refreshable {
                // Refresh protection status
                await refreshProtectionStatus()
            }
        }
        .alert("Emergency Recovery", isPresented: $showingRecoveryAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Recover", role: .destructive) {
                Task {
                    await performEmergencyRecovery()
                }
            }
        } message: {
            Text("This will restore your data from the most recent backup. Any unsaved changes will be lost. Are you sure you want to continue?")
        }
        .sheet(isPresented: $showingBackupDetails) {
            BackupDetailsView()
        }
    }
    
    // MARK: - Computed Properties
    
    private var protectionStatusIcon: String {
        switch protectionManager.lastOperationStatus {
        case .idle, .success:
            return "checkmark.shield.fill"
        case .backingUp, .saving, .deleting, .validating, .recovering:
            return "shield.lefthalf.filled"
        case .error:
            return "exclamationmark.shield.fill"
        }
    }
    
    private var protectionStatusColor: Color {
        switch protectionManager.lastOperationStatus {
        case .idle, .success:
            return .green
        case .backingUp, .saving, .deleting, .validating, .recovering:
            return .blue
        case .error:
            return .red
        }
    }
    
    private var protectionStatusText: String {
        switch protectionManager.lastOperationStatus {
        case .idle, .success:
            return "Protected"
        case .backingUp:
            return "Backing Up"
        case .saving:
            return "Saving"
        case .deleting:
            return "Deleting"
        case .validating:
            return "Validating"
        case .recovering:
            return "Recovering"
        case .error(let message):
            return "Error: \(message)"
        }
    }
    
    private var protectionStatusDescription: String {
        switch protectionManager.lastOperationStatus {
        case .idle, .success:
            return "Your data is fully protected with automatic backups"
        case .backingUp:
            return "Creating backup before operation"
        case .saving:
            return "Saving data with protection"
        case .deleting:
            return "Deleting data with backup protection"
        case .validating:
            return "Verifying data integrity"
        case .recovering:
            return "Restoring from backup"
        case .error:
            return "An error occurred - check details below"
        }
    }
    
    private var operationStatusIcon: String {
        switch protectionManager.lastOperationStatus {
        case .backingUp:
            return "archivebox"
        case .saving:
            return "square.and.arrow.down"
        case .deleting:
            return "trash"
        case .validating:
            return "checkmark.circle"
        case .recovering:
            return "arrow.clockwise"
        case .error:
            return "exclamationmark.triangle"
        default:
            return "circle"
        }
    }
    
    private var operationStatusColor: Color {
        switch protectionManager.lastOperationStatus {
        case .backingUp, .saving, .deleting, .validating, .recovering:
            return .blue
        case .error:
            return .red
        default:
            return .secondary
        }
    }
    
    private var operationStatusText: String {
        switch protectionManager.lastOperationStatus {
        case .backingUp:
            return "Creating backup..."
        case .saving:
            return "Saving data..."
        case .deleting:
            return "Deleting data..."
        case .validating:
            return "Validating data..."
        case .recovering:
            return "Recovering data..."
        case .error(let message):
            return "Error: \(message)"
        default:
            return ""
        }
    }
    
    // MARK: - Methods
    
    private func performHealthCheck() {
        showingHealthCheck = true
        
        Task {
            do {
                let report = try await protectionManager.performDataHealthCheck(context: modelContext)
                await MainActor.run {
                    healthReport = report
                    showingHealthCheck = false
                }
            } catch {
                await MainActor.run {
                    showingHealthCheck = false
                    // Show error alert
                }
            }
        }
    }
    
    private func performEmergencyRecovery() async {
        do {
            try await protectionManager.emergencyRecovery(context: modelContext)
            await MainActor.run {
                // Show success message
            }
        } catch {
            await MainActor.run {
                // Show error message
            }
        }
    }
    
    private func refreshProtectionStatus() async {
        // Refresh any status information
        // This could include checking backup directory, etc.
    }
}

// MARK: - Backup Details View

struct BackupDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appSettings: AppSettings
    @StateObject private var protectionManager = DataProtectionManager.shared
    @State private var backupFiles: [BackupFileInfo] = []
    
    var body: some View {
        NavigationView {
            List {
                Section("📁 BACKUP FILES") {
                    if backupFiles.isEmpty {
                        Text("No backup files found")
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        ForEach(backupFiles, id: \.url) { backup in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(backup.filename)
                                        .font(.headline)
                                    Spacer()
                                    Text(backup.size)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Text(backup.creationDate, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(backup.operation)
                                    .font(.caption)
                                    .foregroundColor(appSettings.primaryColor.color)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(appSettings.primaryColor.color.opacity(0.1))
                                    .cornerRadius(4)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
                
                Section("ℹ️ BACKUP INFORMATION") {
                    Text("Backups are automatically created before every data operation to ensure your information is never lost.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Backup files are stored locally on your device and are automatically cleaned up to save space.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Backup Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadBackupFiles()
        }
    }
    
    private func loadBackupFiles() {
        backupFiles = protectionManager.getBackupFiles()
    }
}

// MARK: - Supporting Types

// Move BackupFileInfo outside or make it public in DataProtectionManager if it isn't already. 
// Since we defined it in the manager update above, let's make sure it matches.
// Actually, looking at the previous file content, BackupFileInfo was defined at the bottom of DataProtectionStatusView.swift.
// We should probably move the definition to DataProtectionManager.swift or make sure the View uses the one returned by the Manager.
// For now, let's assume we need to align the types.


// BackupFileInfo moved to DataProtectionManager.swift

#Preview {
    DataProtectionStatusView()
        .modelContainer(for: Contact.self, inMemory: true)
}
