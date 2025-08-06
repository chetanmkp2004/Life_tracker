import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:jarvis/providers/theme_provider.dart';
import 'package:jarvis/providers/user_data_provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:confetti/confetti.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:math' as math;

class FoodWaterTrackerScreen extends StatefulWidget {
  @override
  _FoodWaterTrackerScreenState createState() => _FoodWaterTrackerScreenState();
}

class _FoodWaterTrackerScreenState extends State<FoodWaterTrackerScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _waterController;
  late AnimationController _summaryController;
  late AnimationController _mealsController;
  late AnimationController _addMealController;
  late ConfettiController _confettiController;

  // Water tracker data
  int water = 6, goalWater = 8;
  List<int> weeklyWaterData = [5, 7, 6, 8, 4, 6, 6];

  // Nutritional data
  Map<String, double> nutritionData = {
    'Proteins': 65,
    'Carbs': 240,
    'Fats': 55,
  };

  // Calorie data
  int dailyCalories = 1420;
  int calorieGoal = 2000;

  // Form controllers
  final _mealCtrl = TextEditingController();
  final _calCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _carbsCtrl = TextEditingController();
  final _fatsCtrl = TextEditingController();

  // UI state
  bool _showAddMeal = false;
  bool _showWaterCelebration = false;
  bool _showCalendar = false;
  DateTime _selectedDate = DateTime.now();
  int _activeTabIndex = 0;

  // Food categories with icons
  Map<String, IconData> foodCategories = {
    'Breakfast': Icons.wb_sunny,
    'Lunch': Icons.lunch_dining,
    'Dinner': Icons.nights_stay,
    'Snack': Icons.cookie,
  };
  String _selectedCategory = 'Lunch';

  // Meals data
  List<Meal> meals = [
    Meal(
      name: "Oatmeal with Berries",
      calories: 320,
      category: "Breakfast",
      time: "08:15 AM",
      protein: 12,
      carbs: 55,
      fats: 8,
      imageUrl: "assets/images/meals/oatmeal.jpg",
    ),
    Meal(
      name: "Grilled Chicken Salad",
      calories: 450,
      category: "Lunch",
      time: "12:30 PM",
      protein: 35,
      carbs: 15,
      fats: 22,
      imageUrl: "assets/images/meals/chicken_salad.jpg",
    ),
    Meal(
      name: "Protein Bar",
      calories: 210,
      category: "Snack",
      time: "03:45 PM",
      protein: 18,
      carbs: 25,
      fats: 5,
      imageUrl: "assets/images/meals/protein_bar.jpg",
    ),
    Meal(
      name: "Salmon with Vegetables",
      calories: 440,
      category: "Dinner",
      time: "07:00 PM",
      protein: 32,
      carbs: 25,
      fats: 20,
      imageUrl: "assets/images/meals/salmon.jpg",
    ),
  ];

  // Health streaks and achievements
  int waterStreakDays = 4;
  int calorieStreakDays = 3;

  // Health insights based on data
  List<String> healthInsights = [
    "Great job keeping up with your water intake! You're above your weekly average.",
    "You've been under your calorie goal for 3 days in a row!",
    "Your protein intake is on target. Keep it up for muscle recovery!",
    "Consider adding more vegetables to increase your fiber intake.",
  ];

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _waterController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _summaryController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    _mealsController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    );

    _addMealController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _confettiController = ConfettiController(
      duration: Duration(seconds: 3),
    );

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(Duration(milliseconds: 100));
    _waterController.forward();

    await Future.delayed(Duration(milliseconds: 300));
    _summaryController.forward();

    await Future.delayed(Duration(milliseconds: 300));
    _mealsController.forward();
  }

  @override
  void dispose() {
    _waterController.dispose();
    _summaryController.dispose();
    _mealsController.dispose();
    _addMealController.dispose();
    _confettiController.dispose();
    _mealCtrl.dispose();
    _calCtrl.dispose();
    _proteinCtrl.dispose();
    _carbsCtrl.dispose();
    _fatsCtrl.dispose();
    super.dispose();
  }

  void _toggleAddMeal() {
    setState(() {
      _showAddMeal = !_showAddMeal;
      if (_showAddMeal) {
        _addMealController.forward();
      } else {
        _addMealController.reverse();
        _mealCtrl.clear();
        _calCtrl.clear();
        _proteinCtrl.clear();
        _carbsCtrl.clear();
        _fatsCtrl.clear();
      }
    });
  }

  void _addMeal() {
    final cal = int.tryParse(_calCtrl.text);
    final protein = double.tryParse(_proteinCtrl.text) ?? 0;
    final carbs = double.tryParse(_carbsCtrl.text) ?? 0;
    final fats = double.tryParse(_fatsCtrl.text) ?? 0;

    if (_mealCtrl.text.isNotEmpty && cal != null) {
      // Haptic feedback
      HapticFeedback.mediumImpact();

      setState(() {
        meals.add(Meal(
          name: _mealCtrl.text,
          calories: cal,
          category: _selectedCategory,
          time: DateFormat('hh:mm a').format(DateTime.now()),
          protein: protein,
          carbs: carbs,
          fats: fats,
        ));

        // Update nutritional data
        nutritionData['Proteins'] = (nutritionData['Proteins'] ?? 0) + protein;
        nutritionData['Carbs'] = (nutritionData['Carbs'] ?? 0) + carbs;
        nutritionData['Fats'] = (nutritionData['Fats'] ?? 0) + fats;

        // Update calories
        dailyCalories += cal;

        // Clear form and close it
        _toggleAddMeal();
      });
    }
  }

  void _incrementWater() {
    // Haptic feedback for tactile response
    HapticFeedback.lightImpact();

    setState(() {
      if (water < goalWater) {
        water++;

        // Show celebration if goal reached
        if (water == goalWater) {
          _showWaterCelebration = true;
          _confettiController.play();

          // Hide celebration after a delay
          Future.delayed(Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _showWaterCelebration = false;
              });
            }
          });
        }
      }
    });
  }

  void _decrementWater() {
    // Haptic feedback
    HapticFeedback.lightImpact();

    setState(() {
      if (water > 0) {
        water--;
      }
    });
  }

  int get totalCalories => meals.fold(0, (sum, meal) => sum + meal.calories);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final accentColor = themeProvider.accentColor;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      body: Stack(
        children: [
          // Main content
          CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
              // App Bar with date selection
              SliverAppBar(
                expandedHeight: 110.0,
                floating: false,
                pinned: true,
                backgroundColor: isDark ? Colors.black : Colors.white,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding:
                      EdgeInsets.only(left: 20, bottom: 16, right: 20),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nutrition & Hydration',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showCalendar = !_showCalendar;
                          });
                        },
                        child: Row(
                          children: [
                            Text(
                              DateFormat('MMM dd').format(_selectedDate),
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                            Icon(
                              _showCalendar
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: isDark ? Colors.white70 : Colors.black54,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Calendar (collapsible)
              SliverToBoxAdapter(
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  height: _showCalendar ? 300 : 0,
                  color: isDark ? Colors.grey[850] : Colors.grey[100],
                  child: _showCalendar
                      ? TableCalendar(
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: _selectedDate,
                          calendarFormat: CalendarFormat.month,
                          selectedDayPredicate: (day) {
                            return isSameDay(_selectedDate, day);
                          },
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDate = selectedDay;
                              _showCalendar = false;
                            });
                          },
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                          ),
                          calendarStyle: CalendarStyle(
                            selectedDecoration: BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                            ),
                            todayDecoration: BoxDecoration(
                              color: accentColor.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : Container(),
                ),
              ),

              // Water tracker
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _waterController,
                    curve: Curves.easeOut,
                  )),
                  child: FadeTransition(
                    opacity: _waterController,
                    child: _buildWaterTracker(isDark, accentColor),
                  ),
                ),
              ),

              // Daily Nutrition Summary
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _summaryController,
                    curve: Curves.easeOut,
                  )),
                  child: FadeTransition(
                    opacity: _summaryController,
                    child: _buildNutritionSummary(isDark, accentColor),
                  ),
                ),
              ),

              // Health Insights
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _summaryController,
                    curve: Curves.easeOut,
                  )),
                  child: FadeTransition(
                    opacity: _summaryController,
                    child: _buildHealthInsights(isDark, accentColor),
                  ),
                ),
              ),

              // Meals Logged
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Meals Logged',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        'Total: ${dailyCalories} / ${calorieGoal} cal',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Meal category tabs
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _buildMealCategoryTabs(isDark, accentColor),
                ),
              ),

              // Meals list
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    // Filter meals by category if needed
                    List<Meal> filteredMeals = _activeTabIndex == 0
                        ? meals
                        : meals
                            .where((meal) =>
                                meal.category ==
                                foodCategories.keys
                                    .elementAt(_activeTabIndex - 1))
                            .toList();

                    if (index >= filteredMeals.length) return null;

                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: Duration(milliseconds: 500),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: _buildMealItem(
                              filteredMeals[index], isDark, accentColor),
                        ),
                      ),
                    );
                  },
                  childCount: _activeTabIndex == 0
                      ? meals.length
                      : meals
                          .where((meal) =>
                              meal.category ==
                              foodCategories.keys
                                  .elementAt(_activeTabIndex - 1))
                          .length,
                ),
              ),

              // Extra space at bottom
              SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          ),

          // Add meal form overlay
          _buildAddMealForm(isDark, accentColor),

          // Water goal celebration overlay
          if (_showWaterCelebration) _buildWaterCelebrationOverlay(),

          // Confetti animation
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: math.pi / 2, // straight up
              maxBlastForce: 20,
              minBlastForce: 10,
              emissionFrequency: 0.3,
              numberOfParticles: 20,
              gravity: 0.2,
              colors: const [
                Colors.blue,
                Colors.lightBlue,
                Colors.cyan,
                Colors.white,
              ],
            ),
          ),

          // Floating action button
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: _toggleAddMeal,
              backgroundColor: accentColor,
              child: Icon(
                _showAddMeal ? Icons.close : Icons.add,
              ),
              elevation: 4,
              heroTag: 'addMeal',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterTracker(bool isDark, Color accentColor) {
    final waterProgress = water / goalWater;

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Water Progress Card
          Card(
            elevation: 8,
            shadowColor: isDark ? Colors.black : Colors.blue.withOpacity(0.4),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: isDark ? Colors.grey[850] : Colors.white,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.water_drop, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Water Intake',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: Colors.blue.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              color: Colors.orange,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '$waterStreakDays day streak',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Water bottles visualization
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < goalWater; i++)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: TweenAnimationBuilder<double>(
                              duration: Duration(milliseconds: 300 + (i * 100)),
                              curve: Curves.elasticOut,
                              tween: Tween<double>(
                                begin: 0,
                                end: i < water ? 1.0 : 0.0,
                              ),
                              builder: (context, value, _) {
                                return Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    Container(
                                      height: 130,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Colors.grey[700]
                                            : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    AnimatedContainer(
                                      duration: Duration(milliseconds: 500),
                                      height: 130 * value,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.blue[300]!,
                                            Colors.blue[600]!,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    Container(
                                      height: 130,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isDark
                                              ? Colors.grey[600]!
                                              : Colors.grey[300]!,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      child: Text(
                                        '${i + 1}',
                                        style: TextStyle(
                                          color: i < water
                                              ? Colors.white
                                              : (isDark
                                                  ? Colors.grey[400]
                                                  : Colors.grey[600]),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 24),
                  // Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${water} / ${goalWater} glasses',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: _decrementWater,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isDark ? Colors.grey[800] : Colors.grey[200],
                              foregroundColor: Colors.blue,
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(12),
                              elevation: 2,
                            ),
                            child: Icon(Icons.remove),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _incrementWater,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(12),
                              elevation: 4,
                            ),
                            child: Icon(Icons.add, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Weekly Water Trend Chart
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: isDark ? Colors.grey[850] : Colors.white,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Hydration Trend',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    height: 180,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 10,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipBgColor:
                                isDark ? Colors.grey[800]! : Colors.white,
                            tooltipRoundedRadius: 8,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                '${rod.toY.round()} glasses',
                                TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const titles = [
                                  'M',
                                  'T',
                                  'W',
                                  'T',
                                  'F',
                                  'S',
                                  'S'
                                ];
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: Text(
                                    titles[value.toInt()],
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              },
                              reservedSize: 30,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value % 2 == 0) {
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    child: Text(
                                      '${value.toInt()}',
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                }
                                return const SideTitleWidget(
                                  axisSide: AxisSide.left,
                                  child: Text(''),
                                );
                              },
                              reservedSize: 30,
                            ),
                          ),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(
                          show: true,
                          horizontalInterval: 2,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color:
                                isDark ? Colors.grey[800]! : Colors.grey[300]!,
                            strokeWidth: 0.5,
                            dashArray: [5, 5],
                          ),
                          getDrawingVerticalLine: (_) => FlLine(
                            color: Colors.transparent,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups:
                            List.generate(weeklyWaterData.length, (index) {
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: weeklyWaterData[index].toDouble(),
                                color: index == weeklyWaterData.length - 1
                                    ? Colors.blue
                                    : Colors.blue.withOpacity(0.7),
                                width: 16,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                ),
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: goalWater.toDouble(),
                                  color: isDark
                                      ? Colors.grey[700]
                                      : Colors.blue.withOpacity(0.1),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                      swapAnimationDuration: Duration(milliseconds: 800),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionSummary(bool isDark, Color accentColor) {
    final calorieProgress = dailyCalories / calorieGoal;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: isDark ? Colors.grey[850] : Colors.white,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.restaurant, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        'Nutrition Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '+20 XP today',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Calorie progress
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Calories',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '$dailyCalories',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: ' / $calorieGoal',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 1200),
                      curve: Curves.easeOutCubic,
                      tween: Tween<double>(
                        begin: 0,
                        end: calorieProgress.clamp(0.0, 1.0),
                      ),
                      builder: (context, value, _) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: value,
                            backgroundColor:
                                isDark ? Colors.grey[700] : Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              calorieProgress > 0.9
                                  ? Colors.red
                                  : Colors.orange,
                            ),
                            minHeight: 12,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Macronutrients
              Text(
                'Macronutrients',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: 12),

              // Macronutrients bars
              _buildNutrientProgressBar(
                'Proteins',
                nutritionData['Proteins']!,
                70, // goal
                Colors.green,
                isDark,
              ),
              SizedBox(height: 12),
              _buildNutrientProgressBar(
                'Carbs',
                nutritionData['Carbs']!,
                250, // goal
                Colors.blue,
                isDark,
              ),
              SizedBox(height: 12),
              _buildNutrientProgressBar(
                'Fats',
                nutritionData['Fats']!,
                65, // goal
                Colors.orange,
                isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientProgressBar(
    String label,
    double value,
    double goal,
    Color color,
    bool isDark,
  ) {
    final progress = (value / goal).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            Text(
              '${value.toStringAsFixed(1)}g / ${goal.toStringAsFixed(0)}g',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 1200),
          curve: Curves.easeOutCubic,
          tween: Tween<double>(
            begin: 0,
            end: progress,
          ),
          builder: (context, value, _) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor:
                    isDark ? Colors.grey[700] : color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHealthInsights(bool isDark, Color accentColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates, color: Colors.purple),
              SizedBox(width: 8),
              Text(
                'Health Insights',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              itemCount: healthInsights.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: Duration(milliseconds: 500),
                  child: SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Container(
                        width: 260,
                        margin: EdgeInsets.only(right: 12),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: index % 2 == 0
                                ? [
                                    Colors.purple.shade300,
                                    Colors.purple.shade100
                                  ]
                                : [Colors.blue.shade300, Colors.blue.shade100],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (index % 2 == 0 ? Colors.purple : Colors.blue)
                                      .withOpacity(0.3),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              index % 2 == 0 ? Icons.lightbulb : Icons.insights,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(height: 12),
                            Text(
                              healthInsights[index],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCategoryTabs(bool isDark, Color accentColor) {
    return Container(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCategoryTab(
              0, "All", Icons.restaurant_menu, isDark, accentColor),
          ...List.generate(
            foodCategories.length,
            (index) => _buildCategoryTab(
              index + 1,
              foodCategories.keys.elementAt(index),
              foodCategories.values.elementAt(index),
              isDark,
              accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(
      int index, String title, IconData icon, bool isDark, Color accentColor) {
    final isActive = _activeTabIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTabIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        margin: EdgeInsets.only(right: 10),
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isActive
              ? accentColor
              : (isDark ? Colors.grey[800] : Colors.grey[200]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive
                  ? Colors.white
                  : (isDark ? Colors.white70 : Colors.black54),
            ),
            SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: isActive
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black54),
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealItem(Meal meal, bool isDark, Color accentColor) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? Colors.grey[850] : Colors.white,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            // Meal image or icon placeholder
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: _getCategoryColor(meal.category)
                    .withOpacity(isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(12),
                image: meal.imageUrl != null
                    ? DecorationImage(
                        image: AssetImage(meal.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: meal.imageUrl == null
                  ? Icon(
                      foodCategories[meal.category] ?? Icons.restaurant,
                      color: _getCategoryColor(meal.category),
                      size: 30,
                    )
                  : null,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              _getCategoryColor(meal.category).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          meal.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: _getCategoryColor(meal.category),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        meal.time,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      _buildNutrientLabel('P', meal.protein, Colors.green),
                      SizedBox(width: 8),
                      _buildNutrientLabel('C', meal.carbs, Colors.blue),
                      SizedBox(width: 8),
                      _buildNutrientLabel('F', meal.fats, Colors.orange),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${meal.calories}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  'cal',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientLabel(String label, double value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(width: 2),
          Text(
            '${value.toStringAsFixed(0)}g',
            style: TextStyle(
              fontSize: 10,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Breakfast':
        return Colors.orange;
      case 'Lunch':
        return Colors.green;
      case 'Dinner':
        return Colors.indigo;
      case 'Snack':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  Widget _buildAddMealForm(bool isDark, Color accentColor) {
    return Positioned.fill(
      child: AnimatedOpacity(
        opacity: _showAddMeal ? 1.0 : 0.0,
        duration: Duration(milliseconds: 300),
        child: IgnorePointer(
          ignoring: !_showAddMeal,
          child: Container(
            color: isDark
                ? Colors.black.withOpacity(0.8)
                : Colors.grey.withOpacity(0.8),
            child: Center(
              child: SizeTransition(
                sizeFactor: _addMealController,
                axis: Axis.vertical,
                child: ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _addMealController,
                    curve: Curves.easeOutCubic,
                  ),
                  child: Card(
                    elevation: 10,
                    shadowColor: isDark ? Colors.black : Colors.grey,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    margin: EdgeInsets.all(20),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.restaurant_menu, color: accentColor),
                              SizedBox(width: 8),
                              Text(
                                'Log a Meal',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          TextField(
                            controller: _mealCtrl,
                            decoration: InputDecoration(
                              labelText: 'Meal Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(Icons.restaurant),
                            ),
                          ),
                          SizedBox(height: 12),
                          TextField(
                            controller: _calCtrl,
                            decoration: InputDecoration(
                              labelText: 'Calories',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(Icons.local_fire_department),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Category',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            height: 45,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: foodCategories.keys.map((category) {
                                final isSelected =
                                    _selectedCategory == category;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedCategory = category;
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(right: 10),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? _getCategoryColor(category)
                                          : _getCategoryColor(category)
                                              .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          foodCategories[category],
                                          size: 16,
                                          color: isSelected
                                              ? Colors.white
                                              : _getCategoryColor(category),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          category,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : _getCategoryColor(category),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Nutrition Details (optional)',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _proteinCtrl,
                                  decoration: InputDecoration(
                                    labelText: 'Protein (g)',
                                    prefixIcon: Container(
                                      margin: EdgeInsets.all(8),
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'P',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _carbsCtrl,
                                  decoration: InputDecoration(
                                    labelText: 'Carbs (g)',
                                    prefixIcon: Container(
                                      margin: EdgeInsets.all(8),
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'C',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _fatsCtrl,
                                  decoration: InputDecoration(
                                    labelText: 'Fats (g)',
                                    prefixIcon: Container(
                                      margin: EdgeInsets.all(8),
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'F',
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                          ElevatedButton.icon(
                            icon: Icon(Icons.add),
                            label: Text('Add Meal'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: accentColor,
                            ),
                            onPressed: _addMeal,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWaterCelebrationOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          elevation: 10,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 300,
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/animations/water_goal.json',
                  width: 150,
                  height: 150,
                  repeat: true,
                ),
                SizedBox(height: 16),
                Text(
                  'Hydration Goal Achieved!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'You reached your daily water intake goal of $goalWater glasses! Keep up the good work!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '+15 XP Earned',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showWaterCelebration = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Awesome!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Meal {
  final String name;
  final int calories;
  final String category;
  final String time;
  final double protein;
  final double carbs;
  final double fats;
  final String? imageUrl;

  Meal({
    required this.name,
    required this.calories,
    required this.category,
    required this.time,
    this.protein = 0,
    this.carbs = 0,
    this.fats = 0,
    this.imageUrl,
  });
}
