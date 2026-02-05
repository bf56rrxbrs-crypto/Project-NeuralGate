// RecommendationsView.swift
// NeuralGate - UI for displaying AI recommendations
//
// Provides a user-friendly interface to display, understand, and act on
// AI-generated recommendations with clear reasoning and impact visualization.

#if canImport(SwiftUI)
import SwiftUI

#if canImport(NeuralGateAI)
import NeuralGateAI
#endif

/// View for displaying AI recommendations to users
@available(iOS 16.0, *)
public struct RecommendationsView: View {
    @StateObject private var viewModel = RecommendationsViewModel()
    @State private var selectedRecommendation: Recommendation?
    @State private var showingDetailSheet = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Header with stats
                    recommendationStatsCard
                    
                    // Filter options
                    recommendationFilters
                    
                    // Recommendations list
                    if viewModel.isLoading {
                        ProgressView("Analyzing your activity...")
                            .padding()
                    } else if viewModel.recommendations.isEmpty {
                        emptyStateView
                    } else {
                        recommendationsList
                    }
                }
                .padding()
            }
            .navigationTitle("AI Recommendations")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.refreshRecommendations() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .sheet(isPresented: $showingDetailSheet) {
                if let recommendation = selectedRecommendation {
                    RecommendationDetailView(recommendation: recommendation, onAction: { action in
                        viewModel.handleAction(action, for: recommendation)
                        showingDetailSheet = false
                    })
                }
            }
        }
        .onAppear {
            viewModel.loadRecommendations()
        }
    }
    
    // MARK: - View Components
    
    private var recommendationStatsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.blue)
                Text("Smart Insights")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.recommendations.count)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            Text("AI-powered suggestions to optimize your workflow")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var recommendationFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(
                    title: "All",
                    isSelected: viewModel.selectedFilter == nil,
                    action: { viewModel.selectedFilter = nil }
                )
                
                ForEach(RecommendationType.allCases, id: \.self) { type in
                    FilterChip(
                        title: type.rawValue.capitalized,
                        isSelected: viewModel.selectedFilter == type,
                        action: { viewModel.selectedFilter = type }
                    )
                }
            }
            .padding(.horizontal, 4)
        }
    }
    
    private var recommendationsList: some View {
        LazyVStack(spacing: 12) {
            ForEach(viewModel.filteredRecommendations) { recommendation in
                RecommendationCard(recommendation: recommendation)
                    .onTapGesture {
                        selectedRecommendation = recommendation
                        showingDetailSheet = true
                    }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "lightbulb")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No recommendations yet")
                .font(.headline)
            
            Text("Keep using NeuralGate and we'll provide personalized suggestions to improve your workflow")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.top, 60)
    }
}

// MARK: - Recommendation Card

@available(iOS 16.0, *)
struct RecommendationCard: View {
    let recommendation: Recommendation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with priority indicator
            HStack {
                priorityIndicator
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(recommendation.title)
                        .font(.headline)
                    
                    Text(recommendation.type.rawValue.capitalized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                confidenceBadge
            }
            
            // Description
            Text(recommendation.description)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            // Impact and reasoning
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundColor(.green)
                    Text(recommendation.estimatedImpact)
                        .font(.caption)
                        .foregroundColor(.green)
                }
                
                HStack {
                    Image(systemName: "brain")
                        .foregroundColor(.purple)
                    Text(recommendation.reasoning)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 4)
            
            // Action button if actionable
            if recommendation.actionable {
                Button(action: {}) {
                    HStack {
                        Text("Take Action")
                        Image(systemName: "arrow.right")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                }
                .buttonStyle(.bordered)
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var priorityIndicator: some View {
        Circle()
            .fill(priorityColor)
            .frame(width: 12, height: 12)
    }
    
    private var priorityColor: Color {
        switch recommendation.priority {
        case 1: return .red
        case 2: return .orange
        case 3: return .yellow
        case 4: return .blue
        default: return .gray
        }
    }
    
    private var confidenceBadge: some View {
        Text("\(Int(recommendation.confidence * 100))%")
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(confidenceColor)
            .cornerRadius(8)
    }
    
    private var confidenceColor: Color {
        if recommendation.confidence >= 0.8 {
            return .green
        } else if recommendation.confidence >= 0.6 {
            return .orange
        } else {
            return .gray
        }
    }
}

// MARK: - Filter Chip

@available(iOS 16.0, *)
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .cornerRadius(20)
        }
    }
}

// MARK: - Recommendation Detail View

@available(iOS 16.0, *)
struct RecommendationDetailView: View {
    let recommendation: Recommendation
    let onAction: (String) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Title and type
                    VStack(alignment: .leading, spacing: 8) {
                        Text(recommendation.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(recommendation.type.rawValue.capitalized)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Description", systemImage: "doc.text")
                            .font(.headline)
                        Text(recommendation.description)
                            .font(.body)
                    }
                    
                    // AI Reasoning
                    VStack(alignment: .leading, spacing: 8) {
                        Label("AI Reasoning", systemImage: "brain")
                            .font(.headline)
                        Text(recommendation.reasoning)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    // Expected Impact
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Expected Impact", systemImage: "chart.line.uptrend.xyaxis")
                            .font(.headline)
                        Text(recommendation.estimatedImpact)
                            .font(.body)
                            .foregroundColor(.green)
                    }
                    
                    // Confidence
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Confidence Level", systemImage: "percent")
                            .font(.headline)
                        ProgressView(value: recommendation.confidence)
                            .tint(.blue)
                        Text("\(Int(recommendation.confidence * 100))% confidence")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Actions
                    if recommendation.actionable {
                        VStack(spacing: 12) {
                            Button(action: { onAction("accept") }) {
                                Text("Apply This Recommendation")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Button(action: { onAction("dismiss") }) {
                                Text("Not Now")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding(.top)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - View Model

@available(iOS 16.0, *)
@MainActor
class RecommendationsViewModel: ObservableObject {
    @Published var recommendations: [Recommendation] = []
    @Published var isLoading = false
    @Published var selectedFilter: RecommendationType?
    
    #if canImport(NeuralGateAI)
    private let engine = RecommendationEngine()
    #endif
    
    var filteredRecommendations: [Recommendation] {
        if let filter = selectedFilter {
            return recommendations.filter { $0.type == filter }
        }
        return recommendations
    }
    
    func loadRecommendations() {
        isLoading = true
        
        Task {
            #if canImport(NeuralGateAI)
            // Create sample context (in production, this would come from user data)
            let context = UserContext(
                currentTime: Date(),
                recentTasks: ["email", "calendar", "notes"],
                completionRate: 0.85,
                averageTaskDuration: 420.0,
                preferredWorkTimes: [9, 10, 11, 14, 15, 16],
                deviceBatteryLevel: 0.75,
                activeWorkflows: ["morning-routine"]
            )
            
            let result = await engine.generateRecommendations(context: context)
            
            await MainActor.run {
                self.recommendations = result
                self.isLoading = false
            }
            #else
            // Fallback for when AI module is not available
            await MainActor.run {
                self.recommendations = []
                self.isLoading = false
            }
            #endif
        }
    }
    
    func refreshRecommendations() {
        #if canImport(NeuralGateAI)
        Task {
            await engine.clearCache()
            loadRecommendations()
        }
        #endif
    }
    
    func handleAction(_ action: String, for recommendation: Recommendation) {
        // Handle user action on recommendation
        print("Action '\(action)' for recommendation: \(recommendation.title)")
        
        // In production, this would:
        // 1. Execute the recommended action
        // 2. Record user feedback
        // 3. Update ML models
        // 4. Refresh recommendations
    }
}

// MARK: - Supporting Extensions

extension RecommendationType: CaseIterable {
    public static var allCases: [RecommendationType] = [
        .workflow, .task, .timing, .automation, .efficiency
    ]
}

// MARK: - Preview Provider

#if DEBUG
@available(iOS 16.0, *)
struct RecommendationsView_Previews: PreviewProvider {
    static var previews: some View {
        RecommendationsView()
    }
}
#endif

#endif // canImport(SwiftUI)
