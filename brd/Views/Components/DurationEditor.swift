import SwiftUI

struct DurationEditor: View {
    @Binding var durations: [Int]
    @State private var showingAddAlert = false
    @State private var newDurationText = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            HStack {
                Text("Durations (seconds)")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                
                Spacer()
                
                Button(action: {
                    showingAddAlert = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(AppTheme.Colors.emberOrange)
                        .font(.system(size: 20))
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: AppTheme.Spacing.xSmall),
                    GridItem(.flexible(), spacing: AppTheme.Spacing.xSmall),
                    GridItem(.flexible(), spacing: AppTheme.Spacing.xSmall),
                    GridItem(.flexible(), spacing: AppTheme.Spacing.xSmall)
                ],
                spacing: AppTheme.Spacing.xSmall
            ) {
                ForEach(durations.sorted(), id: \.self) { duration in
                    DurationChip(
                        duration: duration,
                        onDelete: {
                            removeDuration(duration)
                        }
                    )
                }
            }
            
            Text("Tap + to add custom durations")
                .font(AppTheme.Typography.footnote)
                .foregroundColor(AppTheme.Colors.textTertiary)
                .padding(.top, AppTheme.Spacing.xxSmall)
        }
        .alert("Add Duration", isPresented: $showingAddAlert) {
            TextField("Seconds", text: $newDurationText)
                .keyboardType(.numberPad)
            
            Button("Cancel", role: .cancel) {
                newDurationText = ""
            }
            
            Button("Add") {
                addDuration()
            }
        } message: {
            Text("Enter duration in seconds (5-300)")
        }
    }
    
    private func addDuration() {
        guard let duration = Int(newDurationText),
              duration >= 5,
              duration <= 300,
              !durations.contains(duration) else {
            newDurationText = ""
            return
        }
        
        durations.append(duration)
        newDurationText = ""
    }
    
    private func removeDuration(_ duration: Int) {
        // Ensure at least one duration remains
        if durations.count > 1 {
            durations.removeAll { $0 == duration }
        }
    }
}

struct DurationChip: View {
    let duration: Int
    let onDelete: () -> Void
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        Button(action: {
            showingDeleteConfirmation = true
        }) {
            HStack(spacing: AppTheme.Spacing.xxSmall) {
                Text("\(duration)s")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(AppTheme.Colors.textTertiary)
                    .font(.system(size: 14))
            }
            .padding(.horizontal, AppTheme.Spacing.small)
            .padding(.vertical, AppTheme.Spacing.xxSmall)
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(AppTheme.Layout.smallCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Layout.smallCornerRadius)
                    .stroke(AppTheme.Colors.textTertiary.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .alert("Remove Duration?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Remove \(duration)s from available durations?")
        }
    }
}

#Preview {
    DurationEditor(durations: .constant([15, 30, 60, 120]))
        .padding()
        .background(AppTheme.Colors.backgroundPrimary)
}