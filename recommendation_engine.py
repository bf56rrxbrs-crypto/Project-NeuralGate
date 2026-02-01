"""
AI-Driven Recommendation Engine
Guides users on optimal project usage and feature discovery
"""

from typing import List, Dict, Any
from dataclasses import dataclass
from datetime import datetime
from ai_config import SUGGESTION_THRESHOLDS


@dataclass
class UserProfile:
    """Represents a user profile with usage characteristics"""
    user_id: str
    experience_level: str  # beginner, intermediate, advanced
    primary_use_cases: List[str]
    feature_adoption: Dict[str, int]  # feature -> usage count
    last_active: datetime


@dataclass
class Recommendation:
    """Represents a personalized recommendation"""
    title: str
    description: str
    recommendation_type: str  # feature, workflow, optimization, learning
    relevance_score: float
    estimated_time_savings: int  # minutes per week
    difficulty: str
    learning_resources: List[str]


class RecommendationEngine:
    """AI-driven engine for personalized recommendations"""
    
    def __init__(self):
        self.user_profiles: Dict[str, UserProfile] = {}
        self.feature_catalog = self._initialize_feature_catalog()
        
    def _initialize_feature_catalog(self) -> Dict[str, Dict[str, Any]]:
        """Initialize catalog of available features"""
        return {
            "workflow_automation": {
                "difficulty": "beginner",
                "time_savings": 120,
                "category": "automation",
                "description": "Automate repetitive tasks with custom workflows"
            },
            "smart_scheduling": {
                "difficulty": "intermediate",
                "time_savings": 60,
                "category": "productivity",
                "description": "AI-powered scheduling optimization"
            },
            "voice_commands": {
                "difficulty": "beginner",
                "time_savings": 30,
                "category": "accessibility",
                "description": "Control workflows using voice commands"
            },
            "batch_processing": {
                "difficulty": "advanced",
                "time_savings": 180,
                "category": "automation",
                "description": "Process multiple tasks simultaneously"
            },
            "predictive_suggestions": {
                "difficulty": "intermediate",
                "time_savings": 45,
                "category": "ai",
                "description": "Get AI-powered action predictions"
            },
            "integration_hub": {
                "difficulty": "intermediate",
                "time_savings": 90,
                "category": "integration",
                "description": "Connect with external services and apps"
            },
            "analytics_dashboard": {
                "difficulty": "beginner",
                "time_savings": 15,
                "category": "insights",
                "description": "Track and analyze your productivity"
            }
        }
    
    def create_user_profile(self, user_id: str, experience_level: str,
                           use_cases: List[str]) -> UserProfile:
        """Create a new user profile"""
        profile = UserProfile(
            user_id=user_id,
            experience_level=experience_level,
            primary_use_cases=use_cases,
            feature_adoption={},
            last_active=datetime.now()
        )
        self.user_profiles[user_id] = profile
        return profile
    
    def update_feature_usage(self, user_id: str, feature: str) -> None:
        """Update feature usage statistics for a user"""
        if user_id in self.user_profiles:
            profile = self.user_profiles[user_id]
            profile.feature_adoption[feature] = profile.feature_adoption.get(feature, 0) + 1
            profile.last_active = datetime.now()
    
    def generate_recommendations(self, user_id: str) -> List[Recommendation]:
        """Generate personalized recommendations for a user"""
        if user_id not in self.user_profiles:
            return self._generate_default_recommendations()
        
        profile = self.user_profiles[user_id]
        recommendations = []
        
        # Recommend unused features appropriate for user level
        for feature_name, feature_info in self.feature_catalog.items():
            if feature_name not in profile.feature_adoption:
                if self._is_feature_appropriate(profile, feature_info):
                    recommendations.append(self._create_recommendation(
                        feature_name, feature_info, profile
                    ))
        
        # Recommend advanced features for experienced users
        if profile.experience_level == "advanced":
            recommendations.extend(self._generate_advanced_recommendations(profile))
        
        # Recommend optimizations based on usage patterns
        recommendations.extend(self._generate_optimization_recommendations(profile))
        
        # Sort by relevance score
        recommendations.sort(key=lambda r: r.relevance_score, reverse=True)
        
        return recommendations[:10]  # Return top 10 recommendations
    
    def _is_feature_appropriate(self, profile: UserProfile, 
                                feature_info: Dict[str, Any]) -> bool:
        """Check if a feature is appropriate for user's level"""
        difficulty_levels = {"beginner": 1, "intermediate": 2, "advanced": 3}
        user_level = difficulty_levels.get(profile.experience_level, 1)
        feature_level = difficulty_levels.get(feature_info["difficulty"], 1)
        
        # Recommend features at user level or one level above
        return feature_level <= user_level + 1
    
    def _create_recommendation(self, feature_name: str, 
                              feature_info: Dict[str, Any],
                              profile: UserProfile) -> Recommendation:
        """Create a recommendation object"""
        # Calculate relevance based on use cases and experience
        relevance = self._calculate_relevance(feature_name, feature_info, profile)
        
        return Recommendation(
            title=f"Try {feature_name.replace('_', ' ').title()}",
            description=feature_info["description"],
            recommendation_type="feature",
            relevance_score=relevance,
            estimated_time_savings=feature_info["time_savings"],
            difficulty=feature_info["difficulty"],
            learning_resources=[]
        )
    
    def _calculate_relevance(self, feature_name: str, 
                            feature_info: Dict[str, Any],
                            profile: UserProfile) -> float:
        """Calculate relevance score for a recommendation"""
        score = 0.5  # Base score
        
        # Increase score for features matching user's use cases
        for use_case in profile.primary_use_cases:
            feature_category = feature_info.get("category")
            if feature_category is not None and use_case == feature_category:
                score += 0.2
        
        # Adjust for difficulty match
        if feature_info["difficulty"] == profile.experience_level:
            score += 0.2
        
        # Boost high time-saving features
        if feature_info["time_savings"] > 90:
            score += 0.1
        
        return min(score, 1.0)
    
    def _generate_advanced_recommendations(self, profile: UserProfile) -> List[Recommendation]:
        """Generate recommendations for advanced users"""
        advanced_recs = []
        
        # Check if user would benefit from advanced automation
        if len(profile.feature_adoption) > 5:
            advanced_recs.append(Recommendation(
                title="Create Complex Multi-Step Workflows",
                description="Combine multiple automations into sophisticated workflows",
                recommendation_type="workflow",
                relevance_score=0.85,
                estimated_time_savings=150,
                difficulty="advanced",
                learning_resources=["docs/advanced_workflows.md"]
            ))
        
        # Recommend API integration for power users
        if "integration" in profile.primary_use_cases:
            advanced_recs.append(Recommendation(
                title="Leverage API Integrations",
                description="Connect custom services via REST API",
                recommendation_type="feature",
                relevance_score=0.80,
                estimated_time_savings=120,
                difficulty="advanced",
                learning_resources=["docs/api_reference.md"]
            ))
        
        return advanced_recs
    
    def _generate_optimization_recommendations(self, profile: UserProfile) -> List[Recommendation]:
        """Generate recommendations for optimizing existing usage"""
        optimization_recs = []
        
        # Find frequently used features that could be optimized
        for feature, count in profile.feature_adoption.items():
            if count > SUGGESTION_THRESHOLDS["frequent_usage_threshold"]:
                optimization_recs.append(Recommendation(
                    title=f"Optimize Your {feature.replace('_', ' ').title()} Usage",
                    description=f"Learn advanced techniques to maximize {feature} efficiency",
                    recommendation_type="optimization",
                    relevance_score=0.75,
                    estimated_time_savings=30,
                    difficulty="intermediate",
                    learning_resources=[f"docs/{feature}_optimization.md"]
                ))
        
        return optimization_recs
    
    def _generate_default_recommendations(self) -> List[Recommendation]:
        """Generate default recommendations for new users"""
        return [
            Recommendation(
                title="Get Started with Workflow Automation",
                description="Learn the basics of automating your daily tasks",
                recommendation_type="learning",
                relevance_score=0.95,
                estimated_time_savings=120,
                difficulty="beginner",
                learning_resources=["docs/getting_started.md", "tutorials/first_workflow.md"]
            ),
            Recommendation(
                title="Explore Voice Commands",
                description="Control NeuralGate hands-free with voice",
                recommendation_type="feature",
                relevance_score=0.85,
                estimated_time_savings=30,
                difficulty="beginner",
                learning_resources=["docs/voice_commands.md"]
            ),
            Recommendation(
                title="Set Up Your First Automation",
                description="Create a simple automation to save time immediately",
                recommendation_type="workflow",
                relevance_score=0.90,
                estimated_time_savings=60,
                difficulty="beginner",
                learning_resources=["tutorials/quick_start.md"]
            )
        ]
    
    def generate_recommendation_report(self, user_id: str) -> str:
        """Generate a formatted report of recommendations"""
        recommendations = self.generate_recommendations(user_id)
        
        report = ["=" * 80]
        report.append("PERSONALIZED RECOMMENDATIONS")
        report.append("=" * 80)
        
        if user_id in self.user_profiles:
            profile = self.user_profiles[user_id]
            report.append(f"\nUser: {user_id}")
            report.append(f"Experience Level: {profile.experience_level}")
            report.append(f"Features Used: {len(profile.feature_adoption)}")
        
        report.append(f"\nTop Recommendations:\n")
        
        for i, rec in enumerate(recommendations, 1):
            report.append(f"{i}. {rec.title}")
            report.append(f"   Type: {rec.recommendation_type} | "
                         f"Difficulty: {rec.difficulty} | "
                         f"Relevance: {rec.relevance_score:.2f}")
            report.append(f"   Time Savings: ~{rec.estimated_time_savings} minutes/week")
            report.append(f"   {rec.description}")
            report.append(f"   Resources: {', '.join(rec.learning_resources)}")
            report.append("")
        
        report.append("=" * 80)
        return "\n".join(report)


def main():
    """Example usage of the Recommendation Engine"""
    engine = RecommendationEngine()
    
    # Create sample user profiles
    engine.create_user_profile(
        user_id="user123",
        experience_level="beginner",
        use_cases=["task_management", "email"]
    )
    
    engine.create_user_profile(
        user_id="user456",
        experience_level="advanced",
        use_cases=["automation", "integration"]
    )
    
    # Simulate some feature usage for advanced user
    for _ in range(25):
        engine.update_feature_usage("user456", "workflow_automation")
    
    # Generate recommendations
    print(engine.generate_recommendation_report("user123"))
    print("\n")
    print(engine.generate_recommendation_report("user456"))


if __name__ == "__main__":
    main()
