import Foundation

/// Represents a task to be executed by the AI agent.
///
/// A task is the fundamental unit of work in NeuralGate. It encapsulates
/// all information needed to understand, schedule, and execute a user's
/// request through the AI automation system.
///
/// Example:
/// ```swift
/// let task = Task(
///     name: "Send email reminder",
///     description: "Send email to team about meeting",
///     priority: .high,
///     category: .communication
/// )
/// ```
public struct Task: Identifiable, Codable {
    /// Unique identifier for the task
    public let id: UUID
    
    /// Human-readable name of the task
    public let name: String
    
    /// Detailed description of what the task should accomplish
    public let description: String
    
    /// Priority level determining execution order
    public let priority: Priority
    
    /// Category for organizing and filtering tasks
    public let category: TaskCategory
    
    /// Current execution status of the task
    public var status: TaskStatus
    
    /// Timestamp when the task was created
    public let createdAt: Date
    
    /// Timestamp when the task was completed (if applicable)
    public var completedAt: Date?
    
    /// Additional key-value metadata for task customization
    public var metadata: [String: String]
    
    /// Creates a new task with the specified parameters.
    ///
    /// - Parameters:
    ///   - id: Unique identifier (auto-generated if not provided)
    ///   - name: Human-readable task name
    ///   - description: Detailed task description
    ///   - priority: Task priority level (default: .medium)
    ///   - category: Task category (default: .general)
    ///   - status: Initial status (default: .pending)
    ///   - metadata: Additional metadata dictionary (default: empty)
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
    
    /// Priority levels for task execution ordering.
    ///
    /// Higher priority tasks are executed before lower priority ones.
    /// Each priority has an associated weight for numerical comparisons.
    public enum Priority: String, Codable {
        /// Low priority - executed when resources available
        case low
        
        /// Medium priority - standard execution priority
        case medium
        
        /// High priority - prioritized execution
        case high
        
        /// Critical priority - immediate execution required
        case critical
        
        /// Numerical weight for priority comparison
        public var weight: Int {
            switch self {
            case .low: return 1
            case .medium: return 2
            case .high: return 3
            case .critical: return 4
            }
        }
    }
    
    /// Categories for organizing tasks by functional area
    public enum TaskCategory: String, Codable, CaseIterable {
        /// General purpose tasks
        case general
        
        /// Communication-related tasks (emails, messages, calls)
        case communication
        
        /// Productivity tasks (documents, organization)
        case productivity
        
        /// Automation and workflow tasks
        case automation
        
        /// Learning and self-improvement tasks
        case learning
        
        /// Analytics and reporting tasks
        case analytics
    }
    
    /// Current execution status of a task
    public enum TaskStatus: String, Codable {
        /// Task is waiting to be executed
        case pending
        
        /// Task is currently being executed
        case inProgress
        
        /// Task completed successfully
        case completed
        
        /// Task execution failed
        case failed
        
        /// Task was cancelled before completion
        case cancelled
    }
}

/// A workflow composed of multiple tasks executed in sequence or parallel.
///
/// Workflows enable complex automation by orchestrating multiple related tasks.
/// They maintain their own state and can be paused, resumed, or cancelled.
///
/// Example:
/// ```swift
/// let workflow = Workflow(
///     name: "Morning Routine",
///     description: "Automated morning tasks",
///     tasks: [checkEmailTask, weatherTask, newsTask]
/// )
/// ```
public struct Workflow: Identifiable, Codable {
    /// Unique identifier for the workflow
    public let id: UUID
    
    /// Human-readable name of the workflow
    public let name: String
    
    /// Detailed description of the workflow's purpose
    public let description: String
    
    /// Ordered list of tasks in the workflow
    public var tasks: [Task]
    
    /// Current execution status of the workflow
    public var status: WorkflowStatus
    
    /// Timestamp when the workflow was created
    public let createdAt: Date
    
    /// Creates a new workflow with the specified parameters.
    ///
    /// - Parameters:
    ///   - id: Unique identifier (auto-generated if not provided)
    ///   - name: Human-readable workflow name
    ///   - description: Detailed workflow description
    ///   - tasks: Array of tasks to execute (default: empty)
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
    
    /// Execution status of a workflow
    public enum WorkflowStatus: String, Codable {
        /// Workflow is waiting to start
        case pending
        
        /// Workflow is currently executing
        case running
        
        /// Workflow completed successfully
        case completed
        
        /// Workflow execution failed
        case failed
        
        /// Workflow is paused and can be resumed
        case paused
    }
}

/// Execution context tracking resources and state during task execution.
///
/// The execution context provides runtime information about ongoing
/// task or workflow execution, including resource usage metrics and
/// custom user data.
public struct ExecutionContext {
    /// Currently executing task (if any)
    public var currentTask: Task?
    
    /// Currently executing workflow (if any)
    public var workflow: Workflow?
    
    /// Timestamp when execution started
    public var startTime: Date
    
    /// Resource usage metrics during execution
    public var resourceUsage: ResourceUsage
    
    /// Custom user-provided data for execution context
    public var userData: [String: Any]
    
    /// Creates a new execution context.
    ///
    /// - Parameters:
    ///   - currentTask: Task being executed (optional)
    ///   - workflow: Workflow being executed (optional)
    ///   - userData: Custom context data (default: empty)
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
    
    /// Resource usage metrics for monitoring execution efficiency
    public struct ResourceUsage {
        /// Memory used in bytes
        public var memoryUsed: Int = 0
        
        /// CPU usage as a percentage (0.0 to 1.0)
        public var cpuUsed: Double = 0.0
        
        /// Battery drain percentage during execution
        public var batteryDrain: Double = 0.0
    }
}
