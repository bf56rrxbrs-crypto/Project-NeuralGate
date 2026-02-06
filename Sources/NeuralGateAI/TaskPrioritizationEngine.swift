// TaskPrioritizationEngine.swift
// NeuralGateAI - Automated Task Prioritization
//
// ML-based task prioritization using custom parameters like deadlines,
// complexity, and dependency mappings.

import Foundation

/// Parameters used for task prioritization
public struct PrioritizationParameters: Codable {
    public let deadline: Date?
    public let complexity: ComplexityLevel
    public let estimatedDuration: TimeInterval
    public let dependencies: [UUID]
    public let importance: ImportanceLevel
    public let urgency: UrgencyLevel
    public let resourceRequirements: ResourceRequirements
    
    public init(
        deadline: Date? = nil,
        complexity: ComplexityLevel = .medium,
        estimatedDuration: TimeInterval = 1800,
        dependencies: [UUID] = [],
        importance: ImportanceLevel = .medium,
        urgency: UrgencyLevel = .medium,
        resourceRequirements: ResourceRequirements = ResourceRequirements()
    ) {
        self.deadline = deadline
        self.complexity = complexity
        self.estimatedDuration = estimatedDuration
        self.dependencies = dependencies
        self.importance = importance
        self.urgency = urgency
        self.resourceRequirements = resourceRequirements
    }
    
    public enum ComplexityLevel: String, Codable {
        case trivial, low, medium, high, veryHigh
        
        public var score: Double {
            switch self {
            case .trivial: return 1.0
            case .low: return 2.0
            case .medium: return 3.0
            case .high: return 4.0
            case .veryHigh: return 5.0
            }
        }
    }
    
    public enum ImportanceLevel: String, Codable {
        case low, medium, high, critical
        
        public var score: Double {
            switch self {
            case .low: return 1.0
            case .medium: return 2.0
            case .high: return 3.0
            case .critical: return 4.0
            }
        }
    }
    
    public enum UrgencyLevel: String, Codable {
        case low, medium, high, immediate
        
        public var score: Double {
            switch self {
            case .low: return 1.0
            case .medium: return 2.0
            case .high: return 3.0
            case .immediate: return 4.0
            }
        }
    }
    
    public struct ResourceRequirements: Codable {
        public let cpuIntensive: Bool
        public let networkRequired: Bool
        public let batteryImpact: Double  // 0.0 to 1.0
        public let memoryRequired: Int    // in MB
        
        public init(
            cpuIntensive: Bool = false,
            networkRequired: Bool = false,
            batteryImpact: Double = 0.3,
            memoryRequired: Int = 50
        ) {
            self.cpuIntensive = cpuIntensive
            self.networkRequired = networkRequired
            self.batteryImpact = batteryImpact
            self.memoryRequired = memoryRequired
        }
    }
}

/// Task with prioritization metadata
public struct PrioritizedTask: Identifiable, Codable {
    public let id: UUID
    public let name: String
    public let description: String
    public let parameters: PrioritizationParameters
    public var priorityScore: Double
    public var rank: Int?
    public let createdAt: Date
    public var scheduledFor: Date?
    
    public init(
        id: UUID = UUID(),
        name: String,
        description: String,
        parameters: PrioritizationParameters,
        priorityScore: Double = 0.0
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.parameters = parameters
        self.priorityScore = priorityScore
        self.createdAt = Date()
    }
}

/// Result of prioritization with explanation
public struct PrioritizationResult {
    public let tasks: [PrioritizedTask]
    public let totalScore: Double
    public let reasoning: [UUID: String]  // Task ID -> explanation
    public let suggestedSchedule: [UUID: Date]  // Task ID -> suggested time
    public let warnings: [String]
    
    public init(
        tasks: [PrioritizedTask],
        totalScore: Double,
        reasoning: [UUID: String],
        suggestedSchedule: [UUID: Date],
        warnings: [String] = []
    ) {
        self.tasks = tasks
        self.totalScore = totalScore
        self.reasoning = reasoning
        self.suggestedSchedule = suggestedSchedule
        self.warnings = warnings
    }
}

/// ML-based task prioritization engine
public actor TaskPrioritizationEngine {
    
    // Configuration
    private let weights: PrioritizationWeights
    private var taskHistory: [PrioritizedTask] = []
    private var dependencyGraph: [UUID: Set<UUID>] = [:]
    
    // Performance tracking
    private var successfulCompletions: [UUID: Bool] = [:]
    private var adaptiveWeights: PrioritizationWeights
    
    public struct PrioritizationWeights {
        public var deadline: Double = 0.30
        public var importance: Double = 0.25
        public var urgency: Double = 0.20
        public var complexity: Double = 0.10
        public var dependencies: Double = 0.10
        public var resources: Double = 0.05
        
        public init() {}
        
        public mutating func normalize() {
            let sum = deadline + importance + urgency + complexity + dependencies + resources
            if sum > 0 {
                deadline /= sum
                importance /= sum
                urgency /= sum
                complexity /= sum
                dependencies /= sum
                resources /= sum
            }
        }
    }
    
    public init(weights: PrioritizationWeights = PrioritizationWeights()) {
        var normalizedWeights = weights
        normalizedWeights.normalize()
        self.weights = normalizedWeights
        self.adaptiveWeights = normalizedWeights
    }
    
    // MARK: - Public API
    
    /// Prioritize a list of tasks using ML algorithms
    public func prioritizeTasks(
        _ tasks: [PrioritizedTask],
        context: EnvironmentContext = EnvironmentContext()
    ) async -> PrioritizationResult {
        
        // Build dependency graph
        buildDependencyGraph(from: tasks)
        
        // Calculate priority scores for each task
        var scoredTasks: [PrioritizedTask] = []
        var reasoning: [UUID: String] = [:]
        var warnings: [String] = []
        
        for var task in tasks {
            let score = await calculatePriorityScore(for: task, context: context)
            task.priorityScore = score.value
            scoredTasks.append(task)
            reasoning[task.id] = score.explanation
            
            // Generate warnings
            if let deadline = task.parameters.deadline,
               deadline < Date().addingTimeInterval(3600) {  // Less than 1 hour
                warnings.append("Task '\(task.name)' has an imminent deadline")
            }
        }
        
        // Sort by priority score (highest first)
        scoredTasks.sort { $0.priorityScore > $1.priorityScore }
        
        // Assign ranks
        for (index, task) in scoredTasks.enumerated() {
            if let taskIndex = scoredTasks.firstIndex(where: { $0.id == task.id }) {
                scoredTasks[taskIndex].rank = index + 1
            }
        }
        
        // Generate suggested schedule
        let schedule = generateSchedule(for: scoredTasks, context: context)
        
        // Calculate total system score
        let totalScore = scoredTasks.reduce(0.0) { $0 + $1.priorityScore }
        
        // Store in history
        taskHistory.append(contentsOf: scoredTasks)
        
        return PrioritizationResult(
            tasks: scoredTasks,
            totalScore: totalScore,
            reasoning: reasoning,
            suggestedSchedule: schedule,
            warnings: warnings
        )
    }
    
    /// Record completion of a task for adaptive learning
    public func recordCompletion(taskId: UUID, success: Bool, actualDuration: TimeInterval) {
        successfulCompletions[taskId] = success
        
        // Adapt weights based on outcomes
        adaptWeightsBasedOnHistory()
    }
    
    /// Get dependency chain for a task
    public func getDependencyChain(for taskId: UUID) -> [UUID] {
        var chain: [UUID] = []
        var visited: Set<UUID> = []
        
        func traverse(_ id: UUID) {
            if visited.contains(id) { return }
            visited.insert(id)
            
            if let dependencies = dependencyGraph[id] {
                for dep in dependencies {
                    traverse(dep)
                    chain.append(dep)
                }
            }
        }
        
        traverse(taskId)
        return chain
    }
    
    /// Get prioritization statistics
    public func getStatistics() -> [String: Any] {
        let totalTasks = taskHistory.count
        let completedTasks = successfulCompletions.values.filter { $0 }.count
        let successRate = totalTasks > 0 ? Double(completedTasks) / Double(totalTasks) : 0.0
        
        return [
            "totalTasks": totalTasks,
            "completedTasks": completedTasks,
            "successRate": successRate,
            "currentWeights": [
                "deadline": adaptiveWeights.deadline,
                "importance": adaptiveWeights.importance,
                "urgency": adaptiveWeights.urgency,
                "complexity": adaptiveWeights.complexity,
                "dependencies": adaptiveWeights.dependencies,
                "resources": adaptiveWeights.resources
            ]
        ]
    }
    
    // MARK: - Private Methods
    
    private func calculatePriorityScore(
        for task: PrioritizedTask,
        context: EnvironmentContext
    ) async -> (value: Double, explanation: String) {
        
        var score: Double = 0.0
        var factors: [String] = []
        
        // Deadline score (higher if closer to deadline)
        if let deadline = task.parameters.deadline {
            let timeUntilDeadline = deadline.timeIntervalSinceNow
            let deadlineScore: Double
            
            if timeUntilDeadline < 0 {
                deadlineScore = 1.0  // Overdue - maximum urgency
                factors.append("overdue")
            } else if timeUntilDeadline < 3600 {  // < 1 hour
                deadlineScore = 0.9
                factors.append("imminent deadline")
            } else if timeUntilDeadline < 86400 {  // < 1 day
                deadlineScore = 0.7
                factors.append("due today")
            } else if timeUntilDeadline < 604800 {  // < 1 week
                deadlineScore = 0.5
                factors.append("due this week")
            } else {
                deadlineScore = 0.3
                factors.append("future deadline")
            }
            
            score += deadlineScore * adaptiveWeights.deadline
        } else {
            score += 0.2 * adaptiveWeights.deadline  // No deadline = lower urgency
            factors.append("no deadline")
        }
        
        // Importance score
        let importanceScore = task.parameters.importance.score / 4.0
        score += importanceScore * adaptiveWeights.importance
        factors.append("importance: \(task.parameters.importance.rawValue)")
        
        // Urgency score
        let urgencyScore = task.parameters.urgency.score / 4.0
        score += urgencyScore * adaptiveWeights.urgency
        factors.append("urgency: \(task.parameters.urgency.rawValue)")
        
        // Complexity score (inverse - simpler tasks score higher for quick wins)
        let complexityScore = (6.0 - task.parameters.complexity.score) / 5.0
        score += complexityScore * adaptiveWeights.complexity
        factors.append("complexity: \(task.parameters.complexity.rawValue)")
        
        // Dependency score (tasks with no dependencies score higher)
        let dependencyCount = task.parameters.dependencies.count
        let dependencyScore = dependencyCount == 0 ? 1.0 : max(0.0, 1.0 - (Double(dependencyCount) * 0.2))
        score += dependencyScore * adaptiveWeights.dependencies
        if dependencyCount > 0 {
            factors.append("\(dependencyCount) dependencies")
        }
        
        // Resource score (considering current device state)
        let resourceScore = calculateResourceScore(
            requirements: task.parameters.resourceRequirements,
            context: context
        )
        score += resourceScore * adaptiveWeights.resources
        
        // Normalize score to 0-100 range
        score = min(max(score * 100, 0), 100)
        
        let explanation = "Priority: \(Int(score))/100 based on: \(factors.joined(separator: ", "))"
        
        return (score, explanation)
    }
    
    private func calculateResourceScore(
        requirements: PrioritizationParameters.ResourceRequirements,
        context: EnvironmentContext
    ) -> Double {
        var score: Double = 1.0
        
        // Penalize CPU-intensive tasks on low battery
        if requirements.cpuIntensive && context.batteryLevel < 0.3 {
            score *= 0.5
        }
        
        // Penalize network tasks when offline
        if requirements.networkRequired && !context.isOnline {
            score *= 0.3
        }
        
        // Penalize memory-intensive tasks if memory is constrained
        if requirements.memoryRequired > context.availableMemoryMB {
            score *= 0.4
        }
        
        return score
    }
    
    private func buildDependencyGraph(from tasks: [PrioritizedTask]) {
        dependencyGraph.removeAll()
        
        for task in tasks {
            dependencyGraph[task.id] = Set(task.parameters.dependencies)
        }
    }
    
    private func generateSchedule(
        for tasks: [PrioritizedTask],
        context: EnvironmentContext
    ) -> [UUID: Date] {
        var schedule: [UUID: Date] = [:]
        var currentTime = Date()
        
        for task in tasks {
            // Skip if dependencies not met
            let unmetDependencies = task.parameters.dependencies.filter { depId in
                schedule[depId] == nil || schedule[depId]! > currentTime
            }
            
            if !unmetDependencies.isEmpty {
                // Schedule after dependencies
                let maxDepTime = unmetDependencies.compactMap { schedule[$0] }.max() ?? currentTime
                currentTime = maxDepTime.addingTimeInterval(task.parameters.estimatedDuration)
            }
            
            schedule[task.id] = currentTime
            currentTime = currentTime.addingTimeInterval(task.parameters.estimatedDuration)
        }
        
        return schedule
    }
    
    private func adaptWeightsBasedOnHistory() {
        // Simple adaptive learning: increase weights for factors that led to successful completions
        // In a real implementation, this would use more sophisticated ML techniques
        
        let successCount = successfulCompletions.values.filter { $0 }.count
        let totalCount = successfulCompletions.count
        
        guard totalCount > 10 else { return }  // Need enough data
        
        let successRate = Double(successCount) / Double(totalCount)
        
        if successRate < 0.7 {
            // Poor success rate - adjust weights
            adaptiveWeights.deadline *= 1.1
            adaptiveWeights.importance *= 1.05
            adaptiveWeights.complexity *= 0.95
            adaptiveWeights.normalize()
        }
    }
}

/// Environment context for prioritization decisions
public struct EnvironmentContext {
    public let batteryLevel: Double        // 0.0 to 1.0
    public let isOnline: Bool
    public let availableMemoryMB: Int
    public let currentHour: Int            // 0-23
    public let isWorkingHours: Bool
    
    public init(
        batteryLevel: Double = 1.0,
        isOnline: Bool = true,
        availableMemoryMB: Int = 1000,
        currentHour: Int = Calendar.current.component(.hour, from: Date()),
        isWorkingHours: Bool = true
    ) {
        self.batteryLevel = batteryLevel
        self.isOnline = isOnline
        self.availableMemoryMB = availableMemoryMB
        self.currentHour = currentHour
        self.isWorkingHours = isWorkingHours
    }
}
