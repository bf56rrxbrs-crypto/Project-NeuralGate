#if canImport(SwiftUI)
import SwiftUI

/// Main view for NeuralGate AI Agent interface
@available(iOS 16.0, *)
public struct NeuralGateView: View {
    
    @StateObject private var viewModel = NeuralGateViewModel()
    @State private var inputText: String = ""
    @State private var showingWorkflows = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                headerView
                
                // Input section
                inputSection
                
                // Recent tasks
                recentTasksSection
                
                Spacer()
            }
            .padding()
            .navigationTitle("NeuralGate")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingWorkflows.toggle() }) {
                        Image(systemName: "list.bullet.rectangle")
                    }
                }
            }
            .sheet(isPresented: $showingWorkflows) {
                WorkflowsView(viewModel: viewModel)
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("AI Task Automation")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .padding(.top)
    }
    
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What would you like to do?")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                TextField("e.g., Send a message to John", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .submitLabel(.send)
                    .onSubmit {
                        submitTask()
                    }
                
                Button(action: submitTask) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(inputText.isEmpty ? Color.gray : Color.blue)
                        .clipShape(Circle())
                }
                .disabled(inputText.isEmpty)
            }
            
            // Quick action buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    QuickActionButton(title: "Morning Routine", icon: "sunrise.fill") {
                        Swift.Task {
                            await viewModel.executeWorkflow("morning-routine")
                        }
                    }

                    QuickActionButton(title: "Email Digest", icon: "envelope.fill") {
                        Swift.Task {
                            await viewModel.executeWorkflow("email-digest")
                        }
                    }
                    
                    QuickActionButton(title: "Shortcuts", icon: "link") {
                        viewModel.openShortcuts()
                    }
                }
            }
        }
    }
    
    private var recentTasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Tasks")
                .font(.headline)
            
            if viewModel.recentTasks.isEmpty {
                Text("No recent tasks")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.recentTasks) { task in
                            TaskRowView(task: task)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func submitTask() {
        guard !inputText.isEmpty else { return }

        Swift.Task {
            await viewModel.processRequest(inputText)
            inputText = ""
        }
    }
}

// MARK: - Supporting Views

struct QuickActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(8)
        }
    }
}

struct TaskRowView: View {
    let task: Task
    
    var body: some View {
        HStack {
            Image(systemName: statusIcon)
                .foregroundColor(statusColor)
            
            VStack(alignment: .leading) {
                Text(task.name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(task.createdAt.formatted())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(task.status.rawValue.capitalized)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.2))
                .foregroundColor(statusColor)
                .cornerRadius(4)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var statusIcon: String {
        switch task.status {
        case .completed: return "checkmark.circle.fill"
        case .failed: return "xmark.circle.fill"
        case .inProgress: return "arrow.clockwise"
        case .pending: return "clock"
        case .cancelled: return "minus.circle.fill"
        }
    }

    private var statusColor: Color {
        switch task.status {
        case .completed: return .green
        case .failed: return .red
        case .inProgress: return .blue
        case .pending: return .orange
        case .cancelled: return .gray
        }
    }
}

// MARK: - Preview

@available(iOS 16.0, *)
struct NeuralGateView_Previews: PreviewProvider {
    static var previews: some View {
        NeuralGateView()
    }
}
#endif
