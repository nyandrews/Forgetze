import SwiftUI

struct EmptyStateView: View {
    let onAddContact: () -> Void
    @EnvironmentObject var appSettings: AppSettings
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(appSettings.primaryColor.color)
            
            Text("No Contacts Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Tap 'Add Contact' to get started")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Add Your First Contact") {
                onAddContact()
            }
            .buttonStyle(.borderedProminent)
            .tint(appSettings.primaryColor.color)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyStateView {
        print("Add contact tapped")
    }
}


