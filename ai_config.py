# AI Configuration
# Configuration for AI models and suggestion parameters

# Model Configuration
AI_MODELS = {
    "suggestion_engine": {
        "model_type": "recommendation",
        "version": "1.0",
        "parameters": {
            "suggestion_threshold": 0.6,  # Minimum relevance score
            "max_suggestions": 20,
            "prioritize_high_impact": True
        }
    },
    "pattern_analyzer": {
        "model_type": "analytics",
        "version": "1.0",
        "parameters": {
            "min_pattern_frequency": 5,
            "time_window_days": 30,
            "outlier_threshold": 2.0  # Standard deviations
        }
    },
    "recommendation_engine": {
        "model_type": "personalization",
        "version": "1.0",
        "parameters": {
            "relevance_threshold": 0.5,
            "max_recommendations": 10,
            "learning_rate": 0.01
        }
    }
}

# Feature Categories
FEATURE_CATEGORIES = {
    "automation": {
        "priority": "high",
        "target_users": ["all"],
        "complexity": "medium"
    },
    "integration": {
        "priority": "high",
        "target_users": ["intermediate", "advanced"],
        "complexity": "medium"
    },
    "ai_enhancement": {
        "priority": "critical",
        "target_users": ["all"],
        "complexity": "high"
    },
    "user_experience": {
        "priority": "high",
        "target_users": ["all"],
        "complexity": "low"
    },
    "performance": {
        "priority": "critical",
        "target_users": ["all"],
        "complexity": "high"
    }
}

# Suggestion Thresholds
SUGGESTION_THRESHOLDS = {
    "feature_usage_high": 100,  # Operations per week
    "feature_usage_low": 10,
    "error_rate_critical": 0.05,  # 5% error rate
    "error_rate_warning": 0.02,  # 2% error rate
    "response_time_critical": 2000,  # milliseconds
    "response_time_warning": 1000,
    "adoption_rate_low": 0.3,  # 30% of users
    "adoption_rate_high": 0.7  # 70% of users
}

# Enhancement Priorities
ENHANCEMENT_PRIORITIES = {
    "security": 10,
    "performance": 9,
    "core_functionality": 8,
    "user_experience": 7,
    "automation": 6,
    "integration": 5,
    "analytics": 4,
    "documentation": 3
}

# AI-Powered Feature Flags
FEATURE_FLAGS = {
    "predictive_suggestions": True,
    "automated_optimization": True,
    "real_time_analytics": True,
    "adaptive_learning": True,
    "contextual_automation": True,
    "intelligent_error_handling": True
}

# Analysis Parameters
ANALYSIS_PARAMETERS = {
    "min_data_points": 10,
    "confidence_level": 0.95,
    "update_frequency_hours": 24,
    "retention_days": 90
}
