import SwiftUI

/**
 * Empty State View
 * 
 * Displays a friendly, engaging empty state when no contacts exist in the app.
 * This view encourages users to add their first contact and provides clear
 * guidance on how to get started.
 * 
 * ## Features:
 * - Engaging visual design with large icon
 * - Clear call-to-action button
 * - Helpful descriptive text
 * - Accessibility support
 * 
 * ## Usage:
 * ```swift
 * EmptyStateView {
 *     // Action to perform when button is tapped
 *     showingAddContact = true
 * }
 * ```
 */
struct EmptyStateView: View {
    @EnvironmentObject var appSettings: AppSettings
    let onAddContact: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Large icon
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 80))
                .foregroundColor(appSettings.primaryColor.color)
                .font(.system(size: 48))
                .padding(.bottom, 16)
                .accessibilityHidden(true)
            
            // Title
            Text("No Contacts Yet")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.bottom, 8)
            
            // Description
            Text("Get started by adding your first contact")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 24)
            
            // Call-to-action button
            Button(action: onAddContact) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Your First Contact")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(appSettings.primaryColor.color)
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityIdentifier("addFirstContactButton")
            .accessibilityLabel("Add your first contact")
            .accessibilityHint("Tap to create your first contact")
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    EmptyStateView {
        print("Add contact tapped")
    }
}

