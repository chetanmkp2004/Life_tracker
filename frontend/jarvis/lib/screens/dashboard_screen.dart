import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:jarvis/providers/theme_provider.dart';
import 'package:jarvis/providers/user_data_provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lottie/lottie.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  // Controllers for animations
  late AnimationController _headerAnimationController;
  late AnimationController _progressAnimationController;
  late AnimationController _insightsAnimationController;
  late AnimationController _activityAnimationController;
  late ConfettiController _confettiController;

  // Flag to show level up celebration
  bool _showLevelUpCelebration = false;

  // For pulse animation on streak
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _headerAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _progressAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    _insightsAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    );

    _activityAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1400),
    );

    _confettiController = ConfettiController(duration: Duration(seconds: 3));

    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animations
    _startAnimations();

    // Start pulse animation on streak
    _pulseAnimationController.repeat(reverse: true);

    // Check if user leveled up
    _checkForLevelUp();
  }

  void _startAnimations() async {
    await Future.delayed(Duration(milliseconds: 100));
    _headerAnimationController.forward();

    await Future.delayed(Duration(milliseconds: 300));
    _progressAnimationController.forward();

    await Future.delayed(Duration(milliseconds: 300));
    _insightsAnimationController.forward();

    await Future.delayed(Duration(milliseconds: 300));
    _activityAnimationController.forward();
  }

  void _checkForLevelUp() {
    // Simulate level up check - in a real app, this would check against user data
    Future.delayed(Duration(seconds: 2), () {
      if (Random().nextInt(5) == 0) {
        // 20% chance to show level up
        setState(() {
          _showLevelUpCelebration = true;
        });
        _confettiController.play();

        // Hide after celebration
        Future.delayed(Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _showLevelUpCelebration = false;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _progressAnimationController.dispose();
    _insightsAnimationController.dispose();
    _activityAnimationController.dispose();
    _confettiController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userData = Provider.of<UserDataProvider>(context);

    double taskProgress = userData.totalTasks == 0
        ? 0
        : userData.completedTasks / userData.totalTasks;
    double budgetUsed = userData.monthlyBudget == 0
        ? 0
        : userData.moneySpent / userData.monthlyBudget;
    double waterProgress = userData.waterGoal == 0
        ? 0
        : userData.waterGlasses / userData.waterGoal;
    double calorieProgress = userData.calorieGoal == 0
        ? 0
        : userData.caloriesConsumed / userData.calorieGoal;
    double xpProgress = userData.nextLevelXP == 0
        ? 0
        : userData.currentXP / userData.nextLevelXP;

    return Scaffold(
      body: Stack(
        children: [
          // Main dashboard content
          CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(context, userData, themeProvider),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section with User Stats
                      SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: Offset(0, 0.2),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _headerAnimationController,
                                curve: Curves.easeOut,
                              ),
                            ),
                        child: FadeTransition(
                          opacity: _headerAnimationController,
                          child: _buildHeaderSection(
                            xpProgress,
                            userData,
                            themeProvider,
                          ),
                        ),
                      ),

                      SizedBox(height: 24),

                      // Today's Progress Overview
                      SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: Offset(0, 0.2),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _progressAnimationController,
                                curve: Curves.easeOut,
                              ),
                            ),
                        child: FadeTransition(
                          opacity: _progressAnimationController,
                          child: _buildProgressOverview(
                            taskProgress,
                            budgetUsed,
                            waterProgress,
                            calorieProgress,
                            themeProvider,
                            userData,
                          ),
                        ),
                      ),

                      SizedBox(height: 24),

                      // Weekly Stats Chart
                      SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: Offset(0, 0.2),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _insightsAnimationController,
                                curve: Curves.easeOut,
                              ),
                            ),
                        child: FadeTransition(
                          opacity: _insightsAnimationController,
                          child: _buildWeeklyStatsChart(context, themeProvider),
                        ),
                      ),

                      SizedBox(height: 24),

                      // AI Insights Section
                      SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: Offset(0, 0.2),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _insightsAnimationController,
                                curve: Curves.easeOut,
                              ),
                            ),
                        child: FadeTransition(
                          opacity: _insightsAnimationController,
                          child: _buildAIInsightsSection(userData.aiInsights),
                        ),
                      ),

                      SizedBox(height: 24),

                      // Recent Activity Section
                      SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: Offset(0, 0.2),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _activityAnimationController,
                                curve: Curves.easeOut,
                              ),
                            ),
                        child: FadeTransition(
                          opacity: _activityAnimationController,
                          child: _buildRecentActivitySection(
                            userData.recentActivity,
                            themeProvider,
                          ),
                        ),
                      ),

                      SizedBox(height: 24),

                      // Quick Actions
                      SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: Offset(0, 0.2),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _activityAnimationController,
                                curve: Curves.easeOut,
                              ),
                            ),
                        child: FadeTransition(
                          opacity: _activityAnimationController,
                          child: _buildQuickActionsSection(themeProvider),
                        ),
                      ),

                      SizedBox(height: 80), // Extra space at bottom
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Level Up Celebration
          if (_showLevelUpCelebration) _buildLevelUpCelebration(),

          // Confetti animation for level up
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2, // straight up
              maxBlastForce: 20,
              minBlastForce: 10,
              emissionFrequency: 0.3,
              numberOfParticles: 20,
              gravity: 0.2,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    UserDataProvider userData,
    ThemeProvider themeProvider,
  ) {
    return SliverAppBar(
      expandedHeight: 110.0,
      floating: false,
      pinned: true,
      backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(left: 20, bottom: 16, right: 20),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Dashboard',
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Row(
              children: [
                _buildIconBadge(
                  Icons.notifications_none_rounded,
                  2,
                  themeProvider,
                  () {
                    // Show notifications
                  },
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    // Navigate to profile
                  },
                  child: Hero(
                    tag: 'profile_avatar',
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: themeProvider.accentColor.withOpacity(
                        0.2,
                      ),
                      child: Icon(
                        Icons.person,
                        color: themeProvider.accentColor,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconBadge(
    IconData icon,
    int count,
    ThemeProvider themeProvider,
    VoidCallback onTap,
  ) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(
            icon,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            size: 24,
          ),
          onPressed: onTap,
        ),
        if (count > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeaderSection(
    double xpProgress,
    UserDataProvider userData,
    ThemeProvider themeProvider,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: themeProvider.isDarkMode
              ? [
                  themeProvider.accentColor.withOpacity(0.6),
                  themeProvider.accentColor.withOpacity(0.3),
                ]
              : [
                  themeProvider.accentColor.withOpacity(0.7),
                  themeProvider.accentColor.withOpacity(0.4),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: themeProvider.accentColor.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${userData.userName}!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Level ${userData.userLevel}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/fire.png',
                        width: 20,
                        height: 20,
                      ),
                      SizedBox(width: 6),
                      Text(
                        '${userData.streakDays} day streak',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'XP Progress',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          SizedBox(height: 8),
          LinearPercentIndicator(
            animation: true,
            animationDuration: 1000,
            lineHeight: 10.0,
            percent: xpProgress.clamp(0.0, 1.0),
            backgroundColor: Colors.white.withOpacity(0.3),
            progressColor: Colors.amber,
            barRadius: Radius.circular(5),
            padding: EdgeInsets.zero,
            center: Text(
              '${(xpProgress * 100).toInt()}%',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${userData.currentXP} XP',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              Text(
                '${userData.nextLevelXP} XP',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressOverview(
    double taskProgress,
    double budgetUsed,
    double waterProgress,
    double calorieProgress,
    ThemeProvider themeProvider,
    UserDataProvider userData,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Progress',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 16),
        AnimationLimiter(
          child: GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
            children: List.generate(4, (index) {
              List<Widget Function()> progressCards = [
                () => _buildAnimatedProgressCard(
                  'Tasks',
                  taskProgress,
                  '${userData.completedTasks}/${userData.totalTasks}',
                  Colors.teal,
                  Icons.check_circle,
                  themeProvider,
                  index * 100,
                ),
                () => _buildAnimatedProgressCard(
                  'Budget',
                  1 - budgetUsed,
                  '\$${(userData.monthlyBudget - userData.moneySpent).toStringAsFixed(0)} left',
                  Colors.green,
                  Icons.account_balance_wallet,
                  themeProvider,
                  index * 100,
                ),
                () => _buildAnimatedProgressCard(
                  'Water',
                  waterProgress,
                  '${userData.waterGlasses}/${userData.waterGoal} glasses',
                  Colors.blue,
                  Icons.water_drop,
                  themeProvider,
                  index * 100,
                ),
                () => _buildAnimatedProgressCard(
                  'Calories',
                  calorieProgress,
                  '${userData.caloriesConsumed}/${userData.calorieGoal} cal',
                  Colors.orange,
                  Icons.restaurant,
                  themeProvider,
                  index * 100,
                ),
              ];
              return AnimationConfiguration.staggeredGrid(
                position: index,
                duration: Duration(milliseconds: 500),
                columnCount: 2,
                child: ScaleAnimation(
                  child: FadeInAnimation(child: progressCards[index]()),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedProgressCard(
    String title,
    double progress,
    String subtitle,
    Color color,
    IconData icon,
    ThemeProvider themeProvider,
    int delay,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: themeProvider.isDarkMode
                ? Colors.black26
                : Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Navigate to detailed view
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: progress),
                  duration: Duration(milliseconds: 1500),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return CircularPercentIndicator(
                      radius: 50.0,
                      lineWidth: 8.0,
                      percent: value.clamp(0.0, 1.0),
                      circularStrokeCap: CircularStrokeCap.round,
                      center: Icon(icon, color: color, size: 28),
                      progressColor: color,
                      backgroundColor: color.withOpacity(0.2),
                      animation: true,
                      animationDuration: 1500,
                    );
                  },
                ),
                SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: themeProvider.isDarkMode
                        ? Colors.grey[300]
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyStatsChart(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    final textColor = themeProvider.isDarkMode ? Colors.white : Colors.black87;

    return Container(
      height: 220,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: themeProvider.isDarkMode
                ? Colors.black26
                : Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Activity',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: themeProvider.isDarkMode
                        ? Colors.grey[800]!
                        : Colors.white,
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.round()}%',
                        TextStyle(
                          color: textColor,
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
                        const titles = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            titles[value.toInt()],
                            style: TextStyle(
                              color: textColor.withOpacity(0.7),
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
                        if (value == 0 || value == 50 || value == 100) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              '${value.toInt()}%',
                              style: TextStyle(
                                color: textColor.withOpacity(0.7),
                                fontSize: 10,
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
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: themeProvider.isDarkMode
                        ? Colors.grey[800]!
                        : Colors.grey[300]!,
                    strokeWidth: 0.5,
                    dashArray: [5, 5],
                  ),
                  getDrawingVerticalLine: (_) =>
                      FlLine(color: Colors.transparent),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _generateBarGroup(0, 65, themeProvider.accentColor),
                  _generateBarGroup(1, 75, themeProvider.accentColor),
                  _generateBarGroup(2, 50, themeProvider.accentColor),
                  _generateBarGroup(3, 80, themeProvider.accentColor),
                  _generateBarGroup(4, 90, themeProvider.accentColor),
                  _generateBarGroup(5, 40, themeProvider.accentColor),
                  _generateBarGroup(6, 60, themeProvider.accentColor),
                ],
              ),
              swapAnimationDuration: Duration(milliseconds: 1000),
              swapAnimationCurve: Curves.easeInOutCubic,
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _generateBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 18,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 100,
            color: color.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildAIInsightsSection(List<String> aiInsights) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.psychology, color: Colors.purple),
            SizedBox(width: 8),
            Text(
              'AI Insights',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 12),
        Container(
          height: 140,
          child: AnimationLimiter(
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: aiInsights.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: Duration(milliseconds: 500),
                  child: SlideAnimation(
                    horizontalOffset: 50,
                    child: FadeInAnimation(
                      child: Container(
                        width: 280,
                        margin: EdgeInsets.only(right: 16),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.purple[400]!, Colors.purple[200]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.3),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.lightbulb_outline,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Insight ${index + 1}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Expanded(
                              child: Text(
                                aiInsights[index],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
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
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection(
    List<Map<String, dynamic>> recentActivity,
    ThemeProvider themeProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 12),
        AnimationLimiter(
          child: Column(
            children: List.generate(
              recentActivity.take(4).length,
              (index) => AnimationConfiguration.staggeredList(
                position: index,
                duration: Duration(milliseconds: 500),
                child: SlideAnimation(
                  verticalOffset: 50,
                  child: FadeInAnimation(
                    child: _buildActivityItem(
                      recentActivity[index],
                      themeProvider,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    Map<String, dynamic> activity,
    ThemeProvider themeProvider,
  ) {
    IconData icon;
    Color color;

    switch (activity['type']) {
      case 'task':
        icon = Icons.check_circle;
        color = Colors.teal;
        break;
      case 'money':
        icon = Icons.attach_money;
        color = Colors.green;
        break;
      case 'health':
        icon = Icons.restaurant;
        color = Colors.orange;
        break;
      default:
        icon = Icons.circle;
        color = Colors.grey;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: themeProvider.isDarkMode
                ? Colors.black26
                : Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate to activity details
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity['text'],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        activity['time'],
                        style: TextStyle(
                          fontSize: 12,
                          color: themeProvider.isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (activity['xp'] > 0)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 14),
                        SizedBox(width: 4),
                        Text(
                          '+${activity['xp']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(ThemeProvider themeProvider) {
    final List<Map<String, dynamic>> actions = [
      {'title': 'Add Task', 'icon': Icons.add_task, 'color': Colors.teal},
      {
        'title': 'Log Expense',
        'icon': Icons.receipt_long,
        'color': Colors.green,
      },
      {
        'title': 'Log Meal',
        'icon': Icons.restaurant_menu,
        'color': Colors.orange,
      },
      {'title': 'Log Water', 'icon': Icons.water_drop, 'color': Colors.blue},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 16),
        AnimationLimiter(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              actions.length,
              (index) => AnimationConfiguration.staggeredList(
                position: index,
                duration: Duration(milliseconds: 500),
                child: SlideAnimation(
                  verticalOffset: 50,
                  child: FadeInAnimation(
                    child: _buildActionButton(
                      actions[index]['title'],
                      actions[index]['icon'],
                      actions[index]['color'],
                      () {
                        // Action logic
                      },
                      themeProvider,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
    ThemeProvider themeProvider,
  ) {
    return Container(
      width: 70,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: themeProvider.isDarkMode
                      ? Colors.white
                      : Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelUpCelebration() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Hero(
          tag: 'level_up',
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 300,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple, Colors.deepPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'assets/animations/level_up.json',
                    width: 150,
                    height: 150,
                    repeat: true,
                  ),
                  Text(
                    'LEVEL UP!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Congratulations! You are now level 16!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'NEW REWARDS UNLOCKED',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildRewardItem(Icons.format_paint, 'New Theme'),
                      _buildRewardItem(Icons.emoji_events, 'Gold Badge'),
                      _buildRewardItem(
                        Icons.notifications_active,
                        'Smart Alerts',
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showLevelUpCelebration = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.purple,
                      padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
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
      ),
    );
  }

  Widget _buildRewardItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white24,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
