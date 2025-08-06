import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:jarvis/screens/ai_assistant_screen.dart';
import 'package:jarvis/screens/food_water_tracker_screen.dart';
import 'package:jarvis/screens/money_tracker_screen.dart' as money;
import 'package:jarvis/screens/todo_quest_screen.dart';
import 'package:jarvis/screens/dashboard_screen.dart';
import 'package:jarvis/providers/theme_provider.dart';
import 'package:jarvis/providers/user_data_provider.dart';
import 'package:lottie/lottie.dart';

// Entry Point
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserDataProvider()),
      ],
      child: SplashScreen(),
    ),
  );
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AnimatedSplashScreen(
        duration: 2500,
        splash: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/life_tracker_splash.json',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            Text(
              'Life Tracker',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.teal[700],
              ),
            ),
          ],
        ),
        nextScreen: LifeTrackerApp(),
        splashTransition: SplashTransition.fadeTransition,
        pageTransitionType: PageTransitionType.fade,
        backgroundColor: Colors.white,
      ),
    );
  }
}

// Main app with bottom navigation to switch between feature screens
class LifeTrackerApp extends StatefulWidget {
  @override
  _LifeTrackerAppState createState() => _LifeTrackerAppState();
}

class _LifeTrackerAppState extends State<LifeTrackerApp>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  static List<Widget> _screens = <Widget>[
    DashboardScreen(),
    TodoQuestScreen(),
    money.MoneyTrackerScreen(),
    FoodWaterTrackerScreen(),
    AIAssistantScreen(),
  ];

  final List<IconData> _iconList = [
    Icons.dashboard_rounded,
    Icons.check_circle_outline,
    Icons.attach_money,
    Icons.restaurant_menu,
    Icons.chat,
  ];

  final List<String> _labelList = [
    'Dashboard',
    'Quests',
    'Money',
    'Health',
    'AI Help',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _animationController.reset();
      _selectedIndex = index;
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Life Tracker',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentThemeData,
      home: Scaffold(
        body: FadeTransition(
          opacity: _animation,
          child: _screens.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            canvasColor:
                themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 12,
            unselectedFontSize: 10,
            selectedItemColor: themeProvider.accentColor,
            unselectedItemColor: Colors.grey,
            elevation: 16,
            items: List.generate(
              _iconList.length,
              (index) => BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _selectedIndex == index
                        ? themeProvider.accentColor.withOpacity(0.1)
                        : Colors.transparent,
                  ),
                  child: Icon(_iconList[index]),
                ),
                label: _labelList[index],
              ),
            ),
          ),
        ),
        floatingActionButton: AnimatedOpacity(
          duration: Duration(milliseconds: 300),
          opacity: _selectedIndex == 0 ? 1.0 : 0.0,
          child: _selectedIndex == 0
              ? FloatingActionButton(
                  onPressed: () {
                    // Show quick add action modal
                    _showQuickAddModal(context);
                  },
                  backgroundColor: themeProvider.accentColor,
                  child: Icon(Icons.add),
                  elevation: 4,
                )
              : null,
        ),
      ),
    );
  }

  void _showQuickAddModal(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode ? Colors.grey[850] : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
            ],
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Text(
                "Quick Add",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  padding: EdgeInsets.all(20),
                  children: [
                    _buildQuickAddTile(
                      context,
                      Icons.task_alt,
                      "Task",
                      Colors.teal,
                      () {
                        Navigator.pop(context);
                        _onItemTapped(1);
                      },
                    ),
                    _buildQuickAddTile(
                      context,
                      Icons.receipt_long,
                      "Expense",
                      Colors.green,
                      () {
                        Navigator.pop(context);
                        _onItemTapped(2);
                      },
                    ),
                    _buildQuickAddTile(
                      context,
                      Icons.food_bank,
                      "Meal",
                      Colors.orange,
                      () {
                        Navigator.pop(context);
                        _onItemTapped(3);
                      },
                    ),
                    _buildQuickAddTile(
                      context,
                      Icons.water_drop,
                      "Water",
                      Colors.blue,
                      () {
                        Navigator.pop(context);
                        _onItemTapped(3);
                      },
                    ),
                    _buildQuickAddTile(
                      context,
                      Icons.chat_bubble_outline,
                      "Ask AI",
                      Colors.purple,
                      () {
                        Navigator.pop(context);
                        _onItemTapped(4);
                      },
                    ),
                    _buildQuickAddTile(
                      context,
                      Icons.settings,
                      "Settings",
                      Colors.grey,
                      () {
                        // Navigate to settings
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickAddTile(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
