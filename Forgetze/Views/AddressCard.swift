import SwiftUI

struct AddressCard: View {
    let address: Address
    let themeColor: Color
    let onEdit: (() -> Void)?
    let onDelete: (() -> Void)?
    let onSetDefault: (() -> Void)?
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
                    .cornerRadius(8)
                
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
                    .background(themeColor)
                    .cornerRadius(8)
                }
            }
            
            // Address Content
            Button(action: openInMaps) {
                HStack(alignment: .top, spacing: 12) {
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
                    
                    Spacer()
                    
                    Image(systemName: "map.fill")
                        .font(.title3)
                        .foregroundColor(themeColor.opacity(0.8))
                        .padding(.top, 4)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Action Buttons
            if onEdit != nil || onDelete != nil || onSetDefault != nil {
                HStack(spacing: 16) {
                    if let onEdit = onEdit {
                        Button(action: onEdit) {
                            HStack(spacing: 4) {
                                Image(systemName: "pencil.circle")
                                    .font(.system(size: 14))
                                Text("Edit")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(themeColor)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    if !address.isDefault, let onSetDefault = onSetDefault {
                        Button(action: onSetDefault) {
                            HStack(spacing: 4) {
                                Image(systemName: "star.circle")
                                    .font(.system(size: 14))
                                Text("Set Default")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(themeColor)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Spacer()
                    
                    if let onDelete = onDelete {
                        Button(action: onDelete) {
                            HStack(spacing: 4) {
                                Image(systemName: "trash.circle")
                                    .font(.system(size: 14))
                                Text("Delete")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.red.opacity(0.8))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .modernCardBackground(glassEffectEnabled: appSettings.glassEffectEnabled)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeColor.opacity(0.3), lineWidth: 1)
        )
    }
    
    private func openInMaps() {
        let addressString = [address.street, address.city, address.state, address.zip, address.country]
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
        
        guard let encodedAddress = addressString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "maps://?q=\(encodedAddress)") else {
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
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
