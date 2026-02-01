"""
Usage Pattern Analyzer
Tracks and analyzes user behavior to identify improvement opportunities
"""

from typing import Dict, List, Any, Tuple
from datetime import datetime
from collections import defaultdict
import json
from ai_config import SUGGESTION_THRESHOLDS


class UsagePatternAnalyzer:
    """Analyzes usage patterns to identify opportunities for improvement"""
    
    def __init__(self):
        self.events: List[Dict[str, Any]] = []
        self.user_sessions: Dict[str, List[Dict]] = defaultdict(list)
        self.feature_usage: Dict[str, int] = defaultdict(int)
        self.error_patterns: Dict[str, List[Dict]] = defaultdict(list)
        
    def track_event(self, event_type: str, user_id: str, 
                   metadata: Dict[str, Any] = None) -> None:
        """Track a usage event"""
        event = {
            "type": event_type,
            "user_id": user_id,
            "timestamp": datetime.now().isoformat(),
            "metadata": metadata or {}
        }
        self.events.append(event)
        self.user_sessions[user_id].append(event)
        
        if event_type.startswith("feature_"):
            feature_name = event_type.replace("feature_", "")
            self.feature_usage[feature_name] += 1
    
    def track_error(self, error_type: str, user_id: str, 
                   context: Dict[str, Any] = None) -> None:
        """Track an error occurrence"""
        error = {
            "user_id": user_id,
            "timestamp": datetime.now().isoformat(),
            "context": context or {}
        }
        self.error_patterns[error_type].append(error)
    
    def analyze_feature_adoption(self) -> Dict[str, Any]:
        """Analyze which features are adopted and which are not"""
        total_users = len(self.user_sessions)
        if total_users == 0:
            return {"error": "No usage data available"}
        
        adoption_rates = {}
        for feature, count in self.feature_usage.items():
            # Calculate how many unique users used this feature
            users_using_feature = set()
            for user_id, sessions in self.user_sessions.items():
                for event in sessions:
                    if event["type"] == f"feature_{feature}":
                        users_using_feature.add(user_id)
            
            adoption_rate = len(users_using_feature) / total_users
            adoption_rates[feature] = {
                "total_uses": count,
                "unique_users": len(users_using_feature),
                "adoption_rate": adoption_rate,
                "status": self._get_adoption_status(adoption_rate)
            }
        
        return {
            "total_features": len(adoption_rates),
            "features": adoption_rates,
            "insights": self._generate_adoption_insights(adoption_rates)
        }
    
    def _get_adoption_status(self, rate: float) -> str:
        """Categorize adoption rate"""
        if rate >= 0.7:
            return "high_adoption"
        elif rate >= 0.3:
            return "moderate_adoption"
        else:
            return "low_adoption"
    
    def _generate_adoption_insights(self, adoption_rates: Dict) -> List[str]:
        """Generate insights from adoption data"""
        insights = []
        
        low_adoption_features = [
            f for f, data in adoption_rates.items() 
            if data["adoption_rate"] < 0.3
        ]
        
        if low_adoption_features:
            insights.append(
                f"Low adoption detected for: {', '.join(low_adoption_features)}. "
                f"Consider improving discoverability or user education."
            )
        
        high_value_features = [
            f for f, data in adoption_rates.items() 
            if data["adoption_rate"] > 0.7 and data["total_uses"] > 100
        ]
        
        if high_value_features:
            insights.append(
                f"High-value features: {', '.join(high_value_features)}. "
                f"Consider expanding these capabilities."
            )
        
        return insights
    
    def analyze_user_journeys(self) -> Dict[str, Any]:
        """Analyze common user journey patterns"""
        journey_patterns = defaultdict(int)
        
        for user_id, events in self.user_sessions.items():
            if len(events) < 2:
                continue
            
            # Look at sequences of events
            for i in range(len(events) - 1):
                pattern = f"{events[i]['type']} -> {events[i+1]['type']}"
                journey_patterns[pattern] += 1
        
        # Find most common patterns
        sorted_patterns = sorted(
            journey_patterns.items(),
            key=lambda x: x[1],
            reverse=True
        )
        
        return {
            "total_patterns": len(journey_patterns),
            "most_common_patterns": sorted_patterns[:10],
            "insights": self._generate_journey_insights(sorted_patterns[:10])
        }
    
    def _generate_journey_insights(self, patterns: List[Tuple[str, int]]) -> List[str]:
        """Generate insights from journey patterns"""
        insights = []
        
        for pattern, count in patterns:
            if count > SUGGESTION_THRESHOLDS["pattern_frequency_threshold"]:
                insights.append(
                    f"Common pattern '{pattern}' occurs {count} times. "
                    f"Consider optimizing this workflow."
                )
        
        return insights
    
    def analyze_error_patterns(self) -> Dict[str, Any]:
        """Analyze error patterns to identify pain points"""
        error_analysis = {}
        
        for error_type, occurrences in self.error_patterns.items():
            affected_users = set(e["user_id"] for e in occurrences)
            
            # Find time-based patterns
            timestamps = [
                datetime.fromisoformat(e["timestamp"]) 
                for e in occurrences
            ]
            
            if timestamps:
                time_span = max(timestamps) - min(timestamps)
                # Use total_seconds to handle sub-day time spans correctly
                days = time_span.total_seconds() / 86400
                frequency = len(occurrences) / max(days, 1)
            else:
                frequency = 0
            
            error_analysis[error_type] = {
                "occurrences": len(occurrences),
                "affected_users": len(affected_users),
                "frequency_per_day": frequency,
                "severity": self._assess_error_severity(len(occurrences), len(affected_users))
            }
        
        return {
            "total_error_types": len(error_analysis),
            "errors": error_analysis,
            "insights": self._generate_error_insights(error_analysis)
        }
    
    def _assess_error_severity(self, occurrences: int, affected_users: int) -> str:
        """Assess the severity of an error"""
        if occurrences > 50 or affected_users > 10:
            return "critical"
        elif occurrences > 20 or affected_users > 5:
            return "high"
        elif occurrences > 5:
            return "medium"
        else:
            return "low"
    
    def _generate_error_insights(self, error_analysis: Dict) -> List[str]:
        """Generate insights from error patterns"""
        insights = []
        
        critical_errors = [
            error for error, data in error_analysis.items()
            if data["severity"] in ["critical", "high"]
        ]
        
        if critical_errors:
            insights.append(
                f"Critical/High severity errors detected: {', '.join(critical_errors)}. "
                f"Immediate attention required."
            )
        
        return insights
    
    def analyze_time_patterns(self) -> Dict[str, Any]:
        """Analyze when users are most active"""
        hourly_activity = defaultdict(int)
        daily_activity = defaultdict(int)
        
        for event in self.events:
            timestamp = datetime.fromisoformat(event["timestamp"])
            hourly_activity[timestamp.hour] += 1
            daily_activity[timestamp.strftime("%A")] += 1
        
        peak_hour = max(hourly_activity.items(), key=lambda x: x[1]) if hourly_activity else (0, 0)
        peak_day = max(daily_activity.items(), key=lambda x: x[1]) if daily_activity else ("", 0)
        
        return {
            "hourly_distribution": dict(hourly_activity),
            "daily_distribution": dict(daily_activity),
            "peak_hour": peak_hour[0],
            "peak_day": peak_day[0],
            "insights": [
                f"Peak usage hour: {peak_hour[0]}:00 with {peak_hour[1]} events",
                f"Peak usage day: {peak_day[0]} with {peak_day[1]} events",
                "Consider scheduling maintenance during low-activity periods"
            ]
        }
    
    def generate_comprehensive_report(self) -> str:
        """Generate a comprehensive usage analysis report"""
        report = ["=" * 80]
        report.append("USAGE PATTERN ANALYSIS REPORT")
        report.append("=" * 80)
        report.append(f"\nGenerated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        report.append(f"Total Events Tracked: {len(self.events)}")
        report.append(f"Unique Users: {len(self.user_sessions)}\n")
        
        # Feature Adoption Analysis
        report.append("\n" + "=" * 80)
        report.append("FEATURE ADOPTION ANALYSIS")
        report.append("=" * 80)
        adoption = self.analyze_feature_adoption()
        if "features" in adoption:
            for feature, data in adoption["features"].items():
                report.append(f"\n{feature}:")
                report.append(f"  Total Uses: {data['total_uses']}")
                report.append(f"  Unique Users: {data['unique_users']}")
                report.append(f"  Adoption Rate: {data['adoption_rate']:.1%}")
                report.append(f"  Status: {data['status']}")
        
        if "insights" in adoption:
            report.append("\nKey Insights:")
            for insight in adoption["insights"]:
                report.append(f"  • {insight}")
        
        # User Journey Analysis
        report.append("\n" + "=" * 80)
        report.append("USER JOURNEY PATTERNS")
        report.append("=" * 80)
        journeys = self.analyze_user_journeys()
        report.append(f"\nTotal Unique Patterns: {journeys['total_patterns']}")
        report.append("\nMost Common Patterns:")
        for pattern, count in journeys["most_common_patterns"][:5]:
            report.append(f"  {count}x: {pattern}")
        
        # Error Pattern Analysis
        report.append("\n" + "=" * 80)
        report.append("ERROR PATTERN ANALYSIS")
        report.append("=" * 80)
        errors = self.analyze_error_patterns()
        report.append(f"\nTotal Error Types: {errors['total_error_types']}")
        if "errors" in errors:
            for error_type, data in errors["errors"].items():
                report.append(f"\n{error_type}:")
                report.append(f"  Occurrences: {data['occurrences']}")
                report.append(f"  Affected Users: {data['affected_users']}")
                report.append(f"  Severity: {data['severity']}")
        
        # Time Pattern Analysis
        report.append("\n" + "=" * 80)
        report.append("TIME PATTERN ANALYSIS")
        report.append("=" * 80)
        time_patterns = self.analyze_time_patterns()
        for insight in time_patterns["insights"]:
            report.append(f"  • {insight}")
        
        report.append("\n" + "=" * 80)
        return "\n".join(report)
    
    def export_analysis(self, filename: str = "usage_analysis.json") -> None:
        """Export analysis results to JSON"""
        analysis_data = {
            "generated_at": datetime.now().isoformat(),
            "summary": {
                "total_events": len(self.events),
                "unique_users": len(self.user_sessions),
                "features_tracked": len(self.feature_usage)
            },
            "feature_adoption": self.analyze_feature_adoption(),
            "user_journeys": self.analyze_user_journeys(),
            "error_patterns": self.analyze_error_patterns(),
            "time_patterns": self.analyze_time_patterns()
        }
        
        with open(filename, 'w') as f:
            json.dump(analysis_data, f, indent=2)


def main():
    """Example usage of the Usage Pattern Analyzer"""
    analyzer = UsagePatternAnalyzer()
    
    # Simulate user activity
    users = ["user1", "user2", "user3"]
    features = ["automation", "scheduling", "voice_commands", "analytics"]
    
    # Track various events
    for user in users:
        for feature in features[:2]:  # Each user uses first 2 features
            for _ in range(10):
                analyzer.track_event(f"feature_{feature}", user)
    
    # Track some errors
    analyzer.track_error("connection_timeout", "user1", {"endpoint": "/api/workflows"})
    analyzer.track_error("connection_timeout", "user2", {"endpoint": "/api/workflows"})
    analyzer.track_error("validation_error", "user1", {"field": "schedule"})
    
    # Generate and print report
    print(analyzer.generate_comprehensive_report())
    
    # Export analysis
    analyzer.export_analysis("usage_analysis.json")
    print("\n✓ Analysis exported to usage_analysis.json")


if __name__ == "__main__":
    main()
