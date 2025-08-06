import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:jarvis/providers/theme_provider.dart';
import 'package:jarvis/providers/user_data_provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lottie/lottie.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  // Animation controller
  late AnimationController _controller;
  File? _profileImage;
  final _picker = ImagePicker();
  bool _isEditingProfile = false;
  final _nameController = TextEditingController();
  String _selectedTheme = 'System';

  // Color themes
  final List<ColorTheme> _colorThemes = [
    ColorTheme(name: 'Teal', color: Colors.teal),
    ColorTheme(name: 'Purple', color: Colors.purple),
    ColorTheme(name: 'Green', color: Colors.green),
    ColorTheme(name: 'Blue', color: Colors.blue),
    ColorTheme(name: 'Orange', color: Colors.orange),
    ColorTheme(name: 'Pink', color: Colors.pink),
  ];

  // Badges/Achievements
  final List<Achievement> achievements = [
    Achievement(
      name: 'Early Bird',
      description: 'Complete tasks before 9 AM for 7 days',
      icon: Icons.wb_sunny,
      color: Colors.orange,
      isUnlocked: true,
      progress: 1.0,
    ),
    Achievement(
      name: 'Water Champion',
      description: 'Reach water goal for 10 consecutive days',
      icon: Icons.water_drop,
      color: Colors.blue,
      isUnlocked: true,
      progress: 1.0,
    ),
    Achievement(
      name: 'Budget Master',
      description: 'Stay under budget for 30 days',
      icon: Icons.savings,
      color: Colors.green,
      isUnlocked: false,
      progress: 0.7,
    ),
    Achievement(
      name: 'Fitness Enthusiast',
      description: 'Log 20 workouts in a month',
      icon: Icons.fitness_center,
      color: Colors.red,
      isUnlocked: false,
      progress: 0.4,
    ),
    Achievement(
      name: 'Productivity Pro',
      description: 'Complete all tasks for 14 consecutive days',
      icon: Icons.task_alt,
      color: Colors.purple,
      isUnlocked: false,
      progress: 0.35,
    ),
  ];

  // Activity data for the chart
  List<ActivityData> weeklyActivity = [
    ActivityData(day: 'Mon', completion: 0.85),
    ActivityData(day: 'Tue', completion: 0.7),
    ActivityData(day: 'Wed', completion: 0.9),
    ActivityData(day: 'Thu', completion: 0.65),
    ActivityData(day: 'Fri', completion: 0.8),
    ActivityData(day: 'Sat', completion: 0.4),
    ActivityData(day: 'Sun', completion: 0.75),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userData = Provider.of<UserDataProvider>(context, listen: false);
    _nameController.text = userData.userName;
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _toggleEditProfile() {
    setState(() {
      _isEditingProfile = !_isEditingProfile;
      if (!_isEditingProfile) {
        // Save changes
        final userData = Provider.of<UserDataProvider>(context, listen: false);
        if (_nameController.text.trim().isNotEmpty) {
          userData.userName = _nameController.text.trim();
        }
      }
    });
  }

  void _changeAccentColor(Color color) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.setAccentColor(color);
    HapticFeedback.lightImpact();
  }

  void _changeThemeMode(String mode) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    setState(() {
      _selectedTheme = mode;
      if (mode == 'Dark') {
        themeProvider.setDarkMode(true);
      } else if (mode == 'Light') {
        themeProvider.setThemeMode(ThemeMode.light);
      } else {
        // System mode - not implemented in this example
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userData = Provider.of<UserDataProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final accentColor = themeProvider.accentColor;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          // App bar with profile header
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: isDark ? Colors.black : Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [accentColor, accentColor.withOpacity(0.7)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            Hero(
                              tag: 'profile_avatar',
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white.withOpacity(0.9),
                                backgroundImage: _profileImage != null
                                    ? FileImage(_profileImage!) as ImageProvider
                                    : AssetImage(
                                        'assets/images/default_avatar.png',
                                      ),
                                child: _profileImage == null
                                    ? Icon(
                                        Icons.person,
                                        size: 50,
                                        color: accentColor,
                                      )
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark ? Colors.black : Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      if (_isEditingProfile)
                        Container(
                          width: 200,
                          child: TextField(
                            controller: _nameController,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                        )
                      else
                        Text(
                          userData.userName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              titlePadding: EdgeInsets.only(left: 16, bottom: 16),
              title: Container(),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isEditingProfile ? Icons.check : Icons.edit,
                  color: Colors.white,
                ),
                onPressed: _toggleEditProfile,
              ),
            ],
          ),

          // Level and XP Information
          SliverToBoxAdapter(
            child: AnimationConfiguration.synchronized(
              duration: Duration(milliseconds: 500),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Card(
                    margin: EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    color: isDark ? Colors.grey[850] : Colors.white,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Level ${userData.userLevel}',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: accentColor,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '${userData.currentXP}/${userData.nextLevelXP} XP',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.local_fire_department,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '${userData.streakDays} Day Streak',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          LinearProgressIndicator(
                            value: userData.currentXP / userData.nextLevelXP,
                            backgroundColor: accentColor.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              accentColor,
                            ),
                            minHeight: 10,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '${((userData.currentXP / userData.nextLevelXP) * 100).toStringAsFixed(1)}% to Level ${userData.userLevel + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Stats summary section
          SliverToBoxAdapter(
            child: AnimationConfiguration.synchronized(
              duration: Duration(milliseconds: 600),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildStatsSummary(isDark, accentColor),
                ),
              ),
            ),
          ),

          // Weekly activity chart
          SliverToBoxAdapter(
            child: AnimationConfiguration.synchronized(
              duration: Duration(milliseconds: 700),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildWeeklyActivityChart(isDark, accentColor),
                ),
              ),
            ),
          ),

          // Achievements section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Achievements',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),

          // Achievements list
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: Duration(milliseconds: 500),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: _buildAchievementItem(achievements[index], isDark),
                  ),
                ),
              );
            }, childCount: achievements.length),
          ),

          // Settings section
          SliverToBoxAdapter(
            child: AnimationConfiguration.synchronized(
              duration: Duration(milliseconds: 800),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildSettingsSection(isDark, accentColor),
                ),
              ),
            ),
          ),

          // Extra space at bottom
          SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildStatsSummary(bool isDark, Color accentColor) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        color: isDark ? Colors.grey[850] : Colors.white,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Activity Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    'Tasks Completed',
                    '256',
                    Icons.task_alt,
                    Colors.teal,
                    isDark,
                  ),
                  _buildStatItem(
                    'Water Streak',
                    '14 days',
                    Icons.water_drop,
                    Colors.blue,
                    isDark,
                  ),
                  _buildStatItem(
                    'Budget Goals',
                    '3/4 met',
                    Icons.savings,
                    Colors.green,
                    isDark,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(isDark ? 0.2 : 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWeeklyActivityChart(bool isDark, Color accentColor) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        color: isDark ? Colors.grey[850] : Colors.white,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weekly Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: 16),
              Container(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 1,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor:
                            isDark ? Colors.grey[800]! : Colors.white,
                        tooltipRoundedRadius: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final percentage = (rod.toY * 100).round();
                          return BarTooltipItem(
                            '$percentage%',
                            TextStyle(
                              color: isDark ? Colors.white : Colors.black,
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
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                weeklyActivity[value.toInt()].day,
                                style: TextStyle(
                                  color:
                                      isDark ? Colors.white70 : Colors.black54,
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
                            final percentage = (value * 100).round();
                            if (percentage % 25 == 0) {
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(
                                  '$percentage%',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
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
                          reservedSize: 40,
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
                      horizontalInterval: 0.25,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                        strokeWidth: 0.5,
                        dashArray: [5, 5],
                      ),
                      getDrawingVerticalLine: (_) =>
                          FlLine(color: Colors.transparent),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(weeklyActivity.length, (index) {
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: weeklyActivity[index].completion,
                            color: accentColor,
                            width: 16,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(6),
                              topRight: Radius.circular(6),
                            ),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: 1,
                              color: accentColor.withOpacity(0.1),
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
    );
  }

  Widget _buildAchievementItem(Achievement achievement, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        color: isDark ? Colors.grey[850] : Colors.white,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: achievement.isUnlocked
                      ? achievement.color
                      : achievement.color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  achievement.icon,
                  color:
                      achievement.isUnlocked ? Colors.white : achievement.color,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          achievement.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        SizedBox(width: 8),
                        if (achievement.isUnlocked)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Unlocked',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      achievement.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    SizedBox(height: 8),
                    if (!achievement.isUnlocked)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: achievement.progress,
                          backgroundColor: achievement.color.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            achievement.color,
                          ),
                          minHeight: 6,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(bool isDark, Color accentColor) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        color: isDark ? Colors.grey[850] : Colors.white,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: 16),

              // Theme mode selection
              Text(
                'Theme Mode',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildThemeModeButton('Light', Icons.light_mode, isDark),
                  _buildThemeModeButton('Dark', Icons.dark_mode, isDark),
                  _buildThemeModeButton(
                    'System',
                    Icons.settings_suggest,
                    isDark,
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Accent color selection
              Text(
                'Accent Color',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _colorThemes.map((theme) {
                  return GestureDetector(
                    onTap: () => _changeAccentColor(theme.color),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: accentColor == theme.color
                              ? isDark
                                  ? Colors.white
                                  : Colors.black
                              : theme.color,
                          width: accentColor == theme.color ? 2 : 0,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 24),

              // Additional settings
              ListTile(
                title: Text('Notifications'),
                leading: Icon(Icons.notifications, color: accentColor),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {},
                  activeColor: accentColor,
                ),
                contentPadding: EdgeInsets.zero,
              ),
              ListTile(
                title: Text('Sync Data'),
                leading: Icon(Icons.sync, color: accentColor),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                contentPadding: EdgeInsets.zero,
                onTap: () {},
              ),
              ListTile(
                title: Text('Privacy Settings'),
                leading: Icon(Icons.privacy_tip, color: accentColor),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                contentPadding: EdgeInsets.zero,
                onTap: () {},
              ),
              ListTile(
                title: Text('Help & Support'),
                leading: Icon(Icons.help, color: accentColor),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                contentPadding: EdgeInsets.zero,
                onTap: () {},
              ),
              SizedBox(height: 8),
              Center(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text('Sign Out', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeModeButton(String mode, IconData icon, bool isDark) {
    final isSelected = _selectedTheme == mode;

    return InkWell(
      onTap: () => _changeThemeMode(mode),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200])
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? (isDark ? Colors.white : Colors.black)
                : Colors.grey.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? (isDark ? Colors.white : Colors.black)
                  : Colors.grey,
            ),
            SizedBox(height: 4),
            Text(
              mode,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? (isDark ? Colors.white : Colors.black)
                    : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on ThemeProvider {
  void setThemeMode(ThemeMode light) {}

  void setDarkMode(bool bool) {}
}

class ActivityData {
  final String day;
  final double completion;

  ActivityData({required this.day, required this.completion});
}

class Achievement {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final bool isUnlocked;
  final double progress;

  Achievement({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.isUnlocked,
    required this.progress,
  });
}

class ColorTheme {
  final String name;
  final Color color;

  ColorTheme({required this.name, required this.color});
}
