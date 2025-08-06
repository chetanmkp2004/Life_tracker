import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDataProvider extends ChangeNotifier {
  // User Profile Data
  String userName = "Alex";
  int userLevel = 15;
  int currentXP = 1480;
  int nextLevelXP = 1600; // Next level at 1600 XP
  int streakDays = 7;

  // Today's Progress Data
  int completedTasks = 2;
  int totalTasks = 4;
  double moneySpent = 1850;
  double monthlyBudget = 3000;
  int waterGlasses = 6;
  int waterGoal = 8;
  int caloriesConsumed = 1420;
  int calorieGoal = 2000;

  // AI Insights
  List<String> aiInsights = [
    "Great job maintaining your 7-day streak! You're 85% to your next level.",
    "Your food spending is 43% under budget this month - consider allocating some to your savings goal.",
    "You've been consistent with water intake this week. Try adding lemon for variety!",
    "Your workout completion rate is 90% this month. Keep up the excellent habit!",
  ];

  // Recent Activity
  List<Map<String, dynamic>> recentActivity = [
    {
      "type": "task",
      "text": "Completed morning workout",
      "time": "30 min ago",
      "xp": 25,
    },
    {
      "type": "money",
      "text": "Added expense: Grocery Store -\$65.50",
      "time": "1 hour ago",
      "xp": 0,
    },
    {
      "type": "health",
      "text": "Logged lunch: Chicken salad",
      "time": "2 hours ago",
      "xp": 15,
    },
    {
      "type": "task",
      "text": "Completed project review",
      "time": "3 hours ago",
      "xp": 30,
    },
  ];

  // Game progress tracking
  Map<String, bool> achievements = {
    'first_task': true,
    'first_transaction': true,
    'water_streak': true,
    'budget_master': false,
    'healthy_eater': false,
    'savings_goal': false,
  };

  // Level thresholds for gamification
  final List<int> levelThresholds = [
    0,
    100,
    200,
    350,
    500,
    700,
    950,
    1200,
    1500,
    1800,
    2150,
    2550,
    3000,
    3500,
    4050,
    4650,
    5300,
    6000,
    6750,
    7550,
  ];

  UserDataProvider() {
    _loadUserData();
  }

  // Load user data from storage
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    userName = prefs.getString('userName') ?? "Alex";
    userLevel = prefs.getInt('userLevel') ?? 15;
    currentXP = prefs.getInt('currentXP') ?? 1480;
    streakDays = prefs.getInt('streakDays') ?? 7;

    // Calculate next level XP threshold
    _updateNextLevelXP();

    notifyListeners();
  }

  // Update user data in storage
  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString('userName', userName);
    prefs.setInt('userLevel', userLevel);
    prefs.setInt('currentXP', currentXP);
    prefs.setInt('streakDays', streakDays);
  }

  // Calculate XP needed for next level
  void _updateNextLevelXP() {
    if (userLevel >= levelThresholds.length) {
      // For levels beyond our predefined thresholds
      nextLevelXP = currentXP + (userLevel * 100);
    } else {
      nextLevelXP = levelThresholds[userLevel];
    }
  }

  // Add XP and handle level ups
  bool addXP(int amount) {
    bool didLevelUp = false;

    currentXP += amount;

    // Check for level up
    while (userLevel < levelThresholds.length &&
        currentXP >= levelThresholds[userLevel]) {
      userLevel++;
      didLevelUp = true;
    }

    // Update next level threshold
    _updateNextLevelXP();

    // Save changes
    _saveUserData();

    notifyListeners();
    return didLevelUp;
  }

  // Update task completion status
  void updateTaskCompletion(int completed, int total) {
    completedTasks = completed;
    totalTasks = total;
    notifyListeners();
  }

  // Update water intake
  void updateWaterIntake(int glasses) {
    waterGlasses = glasses;
    notifyListeners();
  }

  // Update calorie intake
  void updateCalorieIntake(int calories) {
    caloriesConsumed = calories;
    notifyListeners();
  }

  // Update money tracking data
  void updateMoneyData(double spent, double budget) {
    moneySpent = spent;
    monthlyBudget = budget;
    notifyListeners();
  }

  // Add a new activity to recent activity list
  void addActivity(String type, String text, int xp) {
    recentActivity.insert(0, {
      "type": type,
      "text": text,
      "time": "Just now",
      "xp": xp,
    });

    // Keep only the most recent activities
    if (recentActivity.length > 20) {
      recentActivity.removeLast();
    }

    notifyListeners();
  }

  // Update streak days
  void updateStreak(int days) {
    streakDays = days;
    _saveUserData();
    notifyListeners();
  }

  // Unlock an achievement
  void unlockAchievement(String achievementId) {
    if (achievements.containsKey(achievementId) &&
        !achievements[achievementId]!) {
      achievements[achievementId] = true;
      notifyListeners();
    }
  }

  // Check if user has specific achievement
  bool hasAchievement(String achievementId) {
    return achievements.containsKey(achievementId) &&
        achievements[achievementId]!;
  }
}
