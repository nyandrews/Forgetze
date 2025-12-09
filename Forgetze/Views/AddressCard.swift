import SwiftUI

struct AddressCard: View {
    let address: Address
    let themeColor: Color
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onSetDefault: () -> Void
    @EnvironmentObject var appSettings: AppSettings
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Address Type Badge
                Text(address.type)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(themeColor)
                    .cornerRadius(12)
                
                Spacer()
                
                // Default Badge
                if address.isDefault {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                        Text("Default")
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.orange)
                    .cornerRadius(8)
                }
            }
            
            // Address Content
            VStack(alignment: .leading, spacing: 4) {
                if !address.street.isEmpty {
                    Text(address.street)
                        .font(.body)
                        .fontWeight(.medium)
                }
                
                if let street2 = address.street2, !street2.isEmpty {
                    Text(street2)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                if !address.city.isEmpty || !address.state.isEmpty || !address.zip.isEmpty {
                    Text([address.city, address.state, address.zip].filter { !$0.isEmpty }.joined(separator: ", "))
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                if !address.country.isEmpty && address.country != "United States" {
                    Text(address.country)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                Button(action: onEdit) {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                            .font(.caption)
                        Text("Edit")
                            .font(.caption)
                    }
                    .foregroundColor(themeColor)
                }
                .buttonStyle(PlainButtonStyle())
                
                if !address.isDefault {
                    Button(action: onSetDefault) {
                        HStack(spacing: 4) {
                            Image(systemName: "star")
                                .font(.caption)
                            Text("Set Default")
                                .font(.caption)
                        }
                        .foregroundColor(themeColor)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Spacer()
                
                Button(action: onDelete) {
                    HStack(spacing: 4) {
                        Image(systemName: "trash")
                            .font(.caption)
                        Text("Delete")
                            .font(.caption)
                    }
                    .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .modernCardBackground(glassEffectEnabled: appSettings.glassEffectEnabled)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeColor.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    AddressCard(
        address: Address(
            type: "Home",
            street: "123 Main Street",
            street2: "Apt 4B",
            city: "New York",
            state: "NY",
            zip: "10001",
            isDefault: true
        ),
        themeColor: .blue,
        onEdit: {},
        onDelete: {},
        onSetDefault: {}
    )
    .environmentObject(AppSettings())
    .padding()
}
