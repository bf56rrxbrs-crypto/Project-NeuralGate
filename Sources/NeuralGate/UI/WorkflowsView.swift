#if canImport(SwiftUI)
import SwiftUI

/// View for displaying and managing workflows
@available(iOS 16.0, *)
struct WorkflowsView: View {
    
    @ObservedObject var viewModel: NeuralGateViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.workflows) { workflow in
                    WorkflowRow(workflow: workflow) {
                        Swift.Task {
                            await viewModel.executeWorkflow(workflow.id)
                        }
                    }
                }
            }
            .navigationTitle("Workflows")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct WorkflowRow: View {
    let workflow: StepWorkflow
    let onExecute: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(workflow.name)
                    .font(.headline)

                Spacer()

                Button(action: onExecute) {
                    Image(systemName: "play.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
            }

            Text("\(workflow.steps.count) steps")
                .font(.caption)
                .foregroundColor(.secondary)

            // Show workflow steps
            ForEach(workflow.steps.indices, id: \.self) { index in
                HStack {
                    Text("\(index + 1).")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Text(workflow.steps[index].action.capitalized)
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
#endif
