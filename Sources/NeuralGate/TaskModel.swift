import Foundation

/// Represents a task to be executed by the AI agent
public struct Task: Identifiable, Codable {
    public let id: UUID
    public let name: String
    public let description: String
    public let priority: Priority
    public let category: TaskCategory
    public var status: TaskStatus
    public let createdAt: Date
    public var completedAt: Date?
    public var metadata: [String: String]
    
    public init(
        id: UUID = UUID(),
        name: String,
        description: String,
        priority: Priority = .medium,
        category: TaskCategory = .general,
        status: TaskStatus = .pending,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.priority = priority
        self.category = category
        self.status = status
        self.createdAt = Date()
        self.metadata = metadata
    }
    
    public enum Priority: String, Codable {
        case low, medium, high, critical
        
        public var weight: Int {
            switch self {
            case .low: return 1
            case .medium: return 2
            case .high: return 3
            case .critical: return 4
            }
        }
    }
    
    public enum TaskCategory: String, Codable, CaseIterable {
        case general
        case communication
        case productivity
        case automation
        case learning
        case analytics
    }
    
    public enum TaskStatus: String, Codable {
        case pending
        case inProgress
        case completed
        case failed
        case cancelled
    }
}

/// Workflow composed of multiple tasks
public struct Workflow: Identifiable, Codable {
    public let id: UUID
    public let name: String
    public let description: String
    public var tasks: [Task]
    public var status: WorkflowStatus
    public let createdAt: Date
    
    public init(
        id: UUID = UUID(),
        name: String,
        description: String,
        tasks: [Task] = []
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.tasks = tasks
        self.status = .pending
        self.createdAt = Date()
    }
    
    public enum WorkflowStatus: String, Codable {
        case pending
        case running
        case completed
        case failed
        case paused
    }
}

/// Execution context for tasks
public struct ExecutionContext {
    public var currentTask: Task?
    public var workflow: Workflow?
    public var startTime: Date
    public var resourceUsage: ResourceUsage
    public var userData: [String: Any]
    
    public init(
        currentTask: Task? = nil,
        workflow: Workflow? = nil,
        userData: [String: Any] = [:]
    ) {
        self.currentTask = currentTask
        self.workflow = workflow
        self.startTime = Date()
        self.resourceUsage = ResourceUsage()
        self.userData = userData
    }
    
    public struct ResourceUsage {
        public var memoryUsed: Int = 0
        public var cpuUsed: Double = 0.0
        public var batteryDrain: Double = 0.0
    }
}
