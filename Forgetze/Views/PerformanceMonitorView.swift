import SwiftUI

struct PerformanceMonitorView: View {
    @EnvironmentObject var appSettings: AppSettings
    @ObservedObject var searchManager: SearchManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Performance Monitor")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Cache Hit Rate:")
                        .font(.caption2)
                    Spacer()
                    Text("\(String(format: "%.1f", searchManager.cacheHitRate * 100))%")
                        .font(.caption2)
                        .foregroundColor(appSettings.primaryColor.color)
                }
                
                HStack {
                    Text("Cache Size:")
                        .font(.caption2)
                    Spacer()
                    Text("\(searchManager.cacheSize) queries")
                        .font(.caption2)
                        .foregroundColor(appSettings.primaryColor.color)
                }
                
                HStack {
                    Text("Memory Usage:")
                        .font(.caption2)
                    Spacer()
                    Text(searchManager.memoryUsage)
                        .font(.caption2)
                        .foregroundColor(appSettings.primaryColor.color)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(.systemGray6))
            .cornerRadius(6)
            
            Button("Clear Cache") {
                searchManager.clearCache()
            }
            .font(.caption2)
            .buttonStyle(.bordered)
            .foregroundColor(appSettings.primaryColor.color)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 2)
    }
}

#Preview {
    PerformanceMonitorView(searchManager: SearchManager())
}


