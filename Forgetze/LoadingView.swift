import SwiftUI

/**
 * Loading View
 * 
 * A clean, accessible loading indicator that displays while the app is
 * loading data or performing operations. This view provides visual feedback
 * to users and maintains consistency with the app's design language.
 * 
 * ## Features:
 * - Animated progress indicator
 * - Customizable loading text
 * - Accessibility support
 * - Clean, minimal design
 * 
 * ## Usage:
 * ```swift
 * if isLoading {
 *     LoadingView()
 * }
 * ```
 */
struct LoadingView: View {
    @EnvironmentObject var appSettings: AppSettings
    let message: String
    
    init(_ message: String = "Loading...") {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Animated progress indicator
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: appSettings.primaryColor.color))
                .accessibilityIdentifier("loadingProgressIndicator")
                .accessibilityLabel("Loading indicator")
            
            // Loading text
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .accessibilityLabel("Loading status")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    LoadingView("Loading contacts...")
}

