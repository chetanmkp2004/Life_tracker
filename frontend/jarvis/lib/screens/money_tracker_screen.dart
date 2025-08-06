import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lottie/lottie.dart';
import 'package:confetti/confetti.dart';
import 'package:jarvis/providers/theme_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:math' as math;

class MoneyTrackerScreen extends StatefulWidget {
  @override
  _MoneyTrackerScreenState createState() => _MoneyTrackerScreenState();
}

class _MoneyTrackerScreenState extends State<MoneyTrackerScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _summaryCardController;
  late AnimationController _chartController;
  late AnimationController _transactionController;
  late AnimationController _addFormController;
  late ConfettiController _confettiController;

  // Tracking UI state
  bool _showAddTransactionForm = false;
  bool _showChart = true;
  int _selectedChartPeriod = 1; // 0: Week, 1: Month, 2: Year
  String _selectedCategory = 'All';

  // For budget milestone celebration
  bool _showBudgetMilestone = false;

  // Transaction data
  List<Transaction> transactions = [
    Transaction(
      id: '1',
      desc: 'Grocery Shopping',
      amount: -85.75,
      category: 'Food',
      date: DateTime.now().subtract(Duration(days: 1)),
      iconData: Icons.shopping_cart,
    ),
    Transaction(
      id: '2',
      desc: 'Monthly Salary',
      amount: 3200.00,
      category: 'Income',
      date: DateTime.now().subtract(Duration(days: 2)),
      iconData: Icons.account_balance,
    ),
    Transaction(
      id: '3',
      desc: 'Electric Bill',
      amount: -124.50,
      category: 'Bills',
      date: DateTime.now().subtract(Duration(days: 3)),
      iconData: Icons.bolt,
    ),
    Transaction(
      id: '4',
      desc: 'Restaurant Dinner',
      amount: -78.90,
      category: 'Food',
      date: DateTime.now().subtract(Duration(days: 4)),
      iconData: Icons.restaurant,
    ),
    Transaction(
      id: '5',
      desc: 'Movie Tickets',
      amount: -32.50,
      category: 'Entertainment',
      date: DateTime.now().subtract(Duration(days: 5)),
      iconData: Icons.movie,
    ),
    Transaction(
      id: '6',
      desc: 'Uber Ride',
      amount: -18.75,
      category: 'Transport',
      date: DateTime.now().subtract(Duration(days: 6)),
      iconData: Icons.directions_car,
    ),
    Transaction(
      id: '7',
      desc: 'Freelance Work',
      amount: 450.00,
      category: 'Income',
      date: DateTime.now().subtract(Duration(days: 7)),
      iconData: Icons.work,
    ),
    Transaction(
      id: '8',
      desc: 'Phone Bill',
      amount: -55.00,
      category: 'Bills',
      date: DateTime.now().subtract(Duration(days: 8)),
      iconData: Icons.phone_android,
    ),
  ];

  // Budget and goals data
  List<BudgetGoal> budgetGoals = [
    BudgetGoal(
      category: 'Food',
      currentSpent: 164.65,
      budgetLimit: 350.00,
      iconData: Icons.restaurant,
      color: Colors.orange,
    ),
    BudgetGoal(
      category: 'Transport',
      currentSpent: 18.75,
      budgetLimit: 200.00,
      iconData: Icons.directions_car,
      color: Colors.blue,
    ),
    BudgetGoal(
      category: 'Entertainment',
      currentSpent: 32.50,
      budgetLimit: 150.00,
      iconData: Icons.movie,
      color: Colors.purple,
    ),
    BudgetGoal(
      category: 'Bills',
      currentSpent: 179.50,
      budgetLimit: 500.00,
      iconData: Icons.receipt,
      color: Colors.red,
    ),
  ];

  // Financial achievements
  List<Achievement> achievements = [
    Achievement(
      title: "Budget Master",
      description: "Stay under budget for 3 consecutive months",
      progress: 0.66,
      iconData: Icons.emoji_events,
      color: Colors.amber,
      xpReward: 150,
    ),
    Achievement(
      title: "Savings Champion",
      description: "Save 20% of income for 2 months",
      progress: 0.5,
      iconData: Icons.savings,
      color: Colors.green,
      xpReward: 200,
    ),
    Achievement(
      title: "Expense Tracker",
      description: "Log expenses daily for a week",
      progress: 1.0,
      iconData: Icons.done_all,
      color: Colors.blue,
      xpReward: 50,
      completed: true,
    ),
  ];

  // Form controllers
  final _descCtrl = TextEditingController();
  final _amtCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  String _cat = 'Food';
  DateTime _selectedDate = DateTime.now();

  // Category data with icons
  final Map<String, IconData> categoryIcons = {
    'Food': Icons.restaurant,
    'Transport': Icons.directions_car,
    'Entertainment': Icons.movie,
    'Bills': Icons.receipt,
    'Income': Icons.account_balance,
    'Shopping': Icons.shopping_bag,
    'Health': Icons.medical_services,
    'Education': Icons.school,
    'Other': Icons.category,
  };

  // Budget and financial goals
  double monthlyBudget = 3000.00;
  double savingsGoal = 10000.00;
  double currentSavings = 6540.00;

  // Get financial statistics
  double get spending =>
      transactions.where((t) => t.amount < 0).fold(0.0, (a, t) => a + t.amount);
  double get income =>
      transactions.where((t) => t.amount > 0).fold(0.0, (a, t) => a + t.amount);
  double get savingsRate =>
      income == 0 ? 0 : (income + spending) / income * 100;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _summaryCardController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _chartController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    _transactionController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    );

    _addFormController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _confettiController = ConfettiController(duration: Duration(seconds: 3));

    // Set current date in the form
    _dateCtrl.text = DateFormat('MMM dd, yyyy').format(_selectedDate);

    // Start animations in sequence
    _startAnimations();

    // Check for budget milestone
    _checkBudgetMilestones();
  }

  void _startAnimations() async {
    await Future.delayed(Duration(milliseconds: 100));
    _summaryCardController.forward();

    await Future.delayed(Duration(milliseconds: 300));
    _chartController.forward();

    await Future.delayed(Duration(milliseconds: 300));
    _transactionController.forward();
  }

  void _checkBudgetMilestones() {
    // For demo, randomly show milestone celebration
    Future.delayed(Duration(seconds: 2), () {
      if (math.Random().nextInt(5) == 0) {
        // 20% chance
        setState(() {
          _showBudgetMilestone = true;
        });
        _confettiController.play();

        // Hide after celebration
        Future.delayed(Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _showBudgetMilestone = false;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _summaryCardController.dispose();
    _chartController.dispose();
    _transactionController.dispose();
    _addFormController.dispose();
    _confettiController.dispose();
    _descCtrl.dispose();
    _amtCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  void _addTransaction() {
    final amt = double.tryParse(_amtCtrl.text);
    if (_descCtrl.text.isNotEmpty && amt != null) {
      // Haptic feedback
      HapticFeedback.mediumImpact();

      setState(() {
        transactions.insert(
          0,
          Transaction(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            desc: _descCtrl.text,
            amount: amt,
            category: _cat,
            date: _selectedDate,
            iconData: categoryIcons[_cat] ?? Icons.attach_money,
          ),
        );

        // Check if this transaction affects any budget goals
        if (amt < 0) {
          for (var goal in budgetGoals) {
            if (goal.category == _cat) {
              goal.currentSpent += -amt;
            }
          }
        }

        // Clear form
        _descCtrl.clear();
        _amtCtrl.clear();
        _selectedDate = DateTime.now();
        _dateCtrl.text = DateFormat('MMM dd, yyyy').format(_selectedDate);

        // Hide form
        _toggleAddTransactionForm();
      });
    }
  }

  void _toggleAddTransactionForm() {
    setState(() {
      _showAddTransactionForm = !_showAddTransactionForm;
      if (_showAddTransactionForm) {
        _addFormController.forward();
      } else {
        _addFormController.reverse();
      }
    });
  }

  void _showDatePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
        _dateCtrl.text = DateFormat('MMM dd, yyyy').format(date);
      });
    }
  }

  void _deleteTransaction(String id) {
    setState(() {
      transactions.removeWhere((tx) => tx.id == id);
    });
  }

  // Get categorized spending data for pie chart
  Map<String, double> getCategorizedSpending() {
    Map<String, double> result = {};

    for (var tx in transactions) {
      if (tx.amount < 0) {
        if (result.containsKey(tx.category)) {
          result[tx.category] = result[tx.category]! + (-tx.amount);
        } else {
          result[tx.category] = -tx.amount;
        }
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    final accentColor = themeProvider.accentColor;

    final budgetLeft = monthlyBudget + spending;
    final categorizedSpending = getCategorizedSpending();

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      body: Stack(
        children: [
          // Main content
          CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
              // App bar
              SliverAppBar(
                expandedHeight: 100.0,
                floating: false,
                pinned: true,
                backgroundColor: isDark ? Colors.black : Colors.white,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: EdgeInsets.only(
                    left: 20,
                    bottom: 16,
                    right: 20,
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Money Tracker',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.savings_outlined,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        onPressed: () {
                          // Show goals and savings
                          _showSavingsGoalsModal();
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Financial summary
              SliverToBoxAdapter(
                child: SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _summaryCardController,
                          curve: Curves.easeOut,
                        ),
                      ),
                  child: FadeTransition(
                    opacity: _summaryCardController,
                    child: _buildFinancialSummaryCards(
                      budgetLeft,
                      isDark,
                      accentColor,
                    ),
                  ),
                ),
              ),

              // Spending breakdown chart
              SliverToBoxAdapter(
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  height: _showChart ? 350 : 60,
                  curve: Curves.easeInOut,
                  child: Column(
                    children: [
                      // Chart header with toggle button
                      ListTile(
                        title: Text(
                          'Spending Breakdown',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            _showChart
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                          onPressed: () {
                            setState(() {
                              _showChart = !_showChart;
                            });
                          },
                        ),
                      ),

                      // Charts
                      if (_showChart)
                        SlideTransition(
                          position:
                              Tween<Offset>(
                                begin: Offset(0, 0.2),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: _chartController,
                                  curve: Curves.easeOut,
                                ),
                              ),
                          child: FadeTransition(
                            opacity: _chartController,
                            child: _buildCharts(
                              categorizedSpending,
                              isDark,
                              accentColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Budget goals
              SliverToBoxAdapter(
                child: SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _chartController,
                          curve: Curves.easeOut,
                        ),
                      ),
                  child: FadeTransition(
                    opacity: _chartController,
                    child: _buildBudgetGoalsSection(isDark),
                  ),
                ),
              ),

              // Transactions list header with filters
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transactions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      DropdownButton<String>(
                        value: _selectedCategory,
                        icon: Icon(Icons.filter_list, size: 18),
                        underline: Container(height: 0),
                        items: [
                          DropdownMenuItem(value: 'All', child: Text('All')),
                          ...categoryIcons.keys
                              .map(
                                (cat) => DropdownMenuItem(
                                  value: cat,
                                  child: Text(cat),
                                ),
                              )
                              .toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Transactions list
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    // Filter transactions by category if needed
                    List<Transaction> filteredTransactions =
                        _selectedCategory == 'All'
                        ? transactions
                        : transactions
                              .where((tx) => tx.category == _selectedCategory)
                              .toList();

                    if (index >= filteredTransactions.length) return null;

                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: Duration(milliseconds: 500),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: _buildTransactionItem(
                            filteredTransactions[index],
                            isDark,
                            accentColor,
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: _selectedCategory == 'All'
                      ? transactions.length
                      : transactions
                            .where((tx) => tx.category == _selectedCategory)
                            .length,
                ),
              ),

              // Extra space at bottom
              SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),

          // Add transaction form overlay
          _buildAddTransactionForm(isDark, accentColor),

          // Budget milestone celebration overlay
          if (_showBudgetMilestone) _buildBudgetMilestoneOverlay(),

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
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),

          // Floating action button
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: _toggleAddTransactionForm,
              backgroundColor: accentColor,
              child: Icon(_showAddTransactionForm ? Icons.close : Icons.add),
              elevation: 4,
              heroTag: 'addTransaction',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummaryCards(
    double budgetLeft,
    bool isDark,
    Color accentColor,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Monthly overview card
          Card(
            elevation: 8,
            shadowColor: isDark ? Colors.black : Colors.green.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: isDark ? Colors.grey[850] : Colors.white,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Overview',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildFinancialMetric(
                        'Income',
                        '\$${income.toStringAsFixed(2)}',
                        Icons.arrow_upward,
                        Colors.green,
                        isDark,
                      ),
                      _buildFinancialMetric(
                        'Spending',
                        '\$${(-spending).toStringAsFixed(2)}',
                        Icons.arrow_downward,
                        Colors.red,
                        isDark,
                      ),
                      _buildFinancialMetric(
                        'Savings Rate',
                        '${savingsRate.toStringAsFixed(1)}%',
                        Icons.savings,
                        Colors.blue,
                        isDark,
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Budget Progress',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 1200),
                      curve: Curves.easeOutCubic,
                      tween: Tween<double>(
                        begin: 0,
                        end: (monthlyBudget - budgetLeft) / monthlyBudget,
                      ),
                      builder: (context, value, _) {
                        return LinearProgressIndicator(
                          value: value.clamp(0.0, 1.0),
                          backgroundColor: isDark
                              ? Colors.grey[700]
                              : Colors.green.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            value > 0.9 ? Colors.red : Colors.green,
                          ),
                          minHeight: 10,
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Budget Left:',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 1200),
                        curve: Curves.easeOutCubic,
                        tween: Tween<double>(begin: 0, end: budgetLeft),
                        builder: (context, value, _) {
                          return Text(
                            '\$${value.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: value < 300
                                  ? Colors.red
                                  : (isDark
                                        ? Colors.green[300]
                                        : Colors.green[700]),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFinancialMetric(
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
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        SizedBox(height: 4),
        TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 1200),
          curve: Curves.easeOutCubic,
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, value, _) {
            return Opacity(
              opacity: value,
              child: Text(
                value == 1 ? value.toString() : '...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCharts(
    Map<String, double> categorizedSpending,
    bool isDark,
    Color accentColor,
  ) {
    final List<Color> chartColors = [
      Colors.green.shade400,
      Colors.blue.shade400,
      Colors.purple.shade400,
      Colors.orange.shade400,
      Colors.red.shade400,
      Colors.teal.shade400,
      Colors.amber.shade400,
      Colors.pink.shade400,
      Colors.indigo.shade400,
    ];

    return Column(
      children: [
        // Chart period selector
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildPeriodButton("Week", 0),
              SizedBox(width: 8),
              _buildPeriodButton("Month", 1),
              SizedBox(width: 8),
              _buildPeriodButton("Year", 2),
            ],
          ),
        ),

        SizedBox(height: 16),

        // Charts container
        Container(
          height: 220,
          child: Row(
            children: [
              // Pie chart
              Expanded(
                flex: 5,
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          // Handle touch interactions
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: _getPieChartSections(
                        categorizedSpending,
                        chartColors,
                      ),
                    ),
                    swapAnimationDuration: Duration(milliseconds: 800),
                  ),
                ),
              ),

              // Legend
              Expanded(
                flex: 4,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(categorizedSpending.length, (
                      index,
                    ) {
                      String category = categorizedSpending.keys.elementAt(
                        index,
                      );
                      double amount = categorizedSpending.values.elementAt(
                        index,
                      );
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: chartColors[index % chartColors.length],
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                category,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '\$${amount.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _getPieChartSections(
    Map<String, double> categorizedSpending,
    List<Color> chartColors,
  ) {
    return List.generate(categorizedSpending.length, (index) {
      final category = categorizedSpending.keys.elementAt(index);
      final value = categorizedSpending.values.elementAt(index);
      final total = categorizedSpending.values.reduce((a, b) => a + b);
      final percentage = total > 0 ? value / total * 100 : 0;

      return PieChartSectionData(
        color: chartColors[index % chartColors.length],
        value: value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  Widget _buildPeriodButton(String title, int index) {
    return Expanded(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _selectedChartPeriod == index
              ? Colors.green.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _selectedChartPeriod == index
                ? Colors.green
                : Colors.grey.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              setState(() {
                _selectedChartPeriod = index;
              });
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _selectedChartPeriod == index
                      ? Colors.green
                      : Colors.grey,
                  fontWeight: _selectedChartPeriod == index
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetGoalsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Budget Goals',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),

        Container(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 8),
            itemCount: budgetGoals.length,
            itemBuilder: (context, index) {
              return _buildBudgetGoalCard(budgetGoals[index], isDark, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetGoalCard(BudgetGoal goal, bool isDark, int index) {
    final progress = goal.currentSpent / goal.budgetLimit;
    final isOverBudget = progress > 0.9;

    return Container(
      width: 160,
      margin: EdgeInsets.all(8),
      child: Card(
        elevation: 4,
        shadowColor: isDark ? Colors.black : goal.color.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: isDark ? Colors.grey[850] : Colors.white,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: goal.color.withOpacity(isDark ? 0.2 : 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(goal.iconData, color: goal.color, size: 20),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      goal.category,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 1500),
                curve: Curves.easeOutCubic,
                tween: Tween<double>(begin: 0, end: progress),
                builder: (context, value, _) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: value.clamp(0.0, 1.0),
                      backgroundColor: isDark
                          ? Colors.grey[700]
                          : goal.color.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isOverBudget ? Colors.red : goal.color,
                      ),
                      minHeight: 8,
                    ),
                  );
                },
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${goal.currentSpent.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isOverBudget
                          ? Colors.red
                          : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  Text(
                    '\$${goal.budgetLimit.toStringAsFixed(0)}',
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
      ),
    );
  }

  Widget _buildTransactionItem(Transaction tx, bool isDark, Color accentColor) {
    final isIncome = tx.amount >= 0;
    final formattedDate = DateFormat('MMM dd').format(tx.date);

    return Dismissible(
      key: Key(tx.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        color: Colors.red,
        child: Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _deleteTransaction(tx.id),
      child: Card(
        elevation: 2,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: isDark ? Colors.grey[850] : Colors.white,
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (isIncome ? Colors.green : Colors.red).withOpacity(
                isDark ? 0.2 : 0.1,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              tx.iconData,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
          title: Text(
            tx.desc,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          subtitle: Row(
            children: [
              Text(
                tx.category,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              Text(
                ' · $formattedDate',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
          trailing: Text(
            '\$${tx.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
          onTap: () {
            // Show transaction details
            _showTransactionDetails(tx);
          },
        ),
      ),
    );
  }

  Widget _buildAddTransactionForm(bool isDark, Color accentColor) {
    return Positioned.fill(
      child: AnimatedOpacity(
        opacity: _showAddTransactionForm ? 1.0 : 0.0,
        duration: Duration(milliseconds: 300),
        child: IgnorePointer(
          ignoring: !_showAddTransactionForm,
          child: Container(
            color: isDark
                ? Colors.black.withOpacity(0.8)
                : Colors.grey.withOpacity(0.8),
            child: Center(
              child: SizeTransition(
                sizeFactor: _addFormController,
                axis: Axis.vertical,
                child: ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _addFormController,
                    curve: Curves.easeOutCubic,
                  ),
                  child: Card(
                    elevation: 10,
                    shadowColor: isDark ? Colors.black : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: EdgeInsets.all(20),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.receipt_long, color: accentColor),
                              SizedBox(width: 8),
                              Text(
                                'Add Transaction',
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
                            controller: _descCtrl,
                            decoration: InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(Icons.description),
                            ),
                          ),
                          SizedBox(height: 12),
                          TextField(
                            controller: _amtCtrl,
                            decoration: InputDecoration(
                              labelText: 'Amount (negative for spending)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                          ),
                          SizedBox(height: 12),
                          GestureDetector(
                            onTap: _showDatePicker,
                            child: AbsorbPointer(
                              child: TextField(
                                controller: _dateCtrl,
                                decoration: InputDecoration(
                                  labelText: 'Date',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          FormField<String>(
                            builder: (FormFieldState<String> state) {
                              return InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Category',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: Icon(
                                    categoryIcons[_cat] ?? Icons.category,
                                  ),
                                ),
                                isEmpty: _cat == '',
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _cat,
                                    isDense: true,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _cat = newValue!;
                                      });
                                    },
                                    items: categoryIcons.keys.map((
                                      String value,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Row(
                                          children: [
                                            Icon(
                                              categoryIcons[value],
                                              size: 18,
                                            ),
                                            SizedBox(width: 8),
                                            Text(value),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 24),
                          ElevatedButton.icon(
                            icon: Icon(Icons.add),
                            label: Text('Add Transaction'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: accentColor,
                            ),
                            onPressed: _addTransaction,
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

  Widget _buildBudgetMilestoneOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          elevation: 10,
          shadowColor: Colors.green.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 300,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade700, Colors.green.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/animations/achievement.json',
                  width: 150,
                  height: 150,
                  repeat: true,
                ),
                SizedBox(height: 8),
                Shimmer.fromColors(
                  baseColor: Colors.white,
                  highlightColor: Colors.amber,
                  child: Text(
                    'BUDGET ACHIEVEMENT!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'You\'ve been under budget for 30 days in a row!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '+100 XP Earned',
                      style: TextStyle(
                        color: Colors.white,
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
                      _showBudgetMilestone = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green.shade700,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Awesome!',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTransactionDetails(Transaction tx) {
    final isIncome = tx.amount >= 0;
    final formattedDate = DateFormat('MMMM dd, yyyy').format(tx.date);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: (isIncome ? Colors.green : Colors.red).withOpacity(
                    0.1,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  tx.iconData,
                  color: isIncome ? Colors.green : Colors.red,
                  size: 36,
                ),
              ),
              SizedBox(height: 16),
              Text(
                tx.desc,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '\$${tx.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: isIncome ? Colors.green : Colors.red,
                ),
              ),
              SizedBox(height: 24),
              _detailRow('Category', tx.category),
              _detailRow('Date', formattedDate),
              _detailRow('Transaction ID', '#' + tx.id.substring(0, 8)),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    icon: Icon(Icons.edit),
                    label: Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      // Edit transaction logic
                    },
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.delete),
                    label: Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteTransaction(tx.id);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showSavingsGoalsModal() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 10),
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.savings, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Savings & Financial Goals',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Savings progress card
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Emergency Fund',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 100,
                              width: double.infinity,
                              child: TweenAnimationBuilder<double>(
                                duration: Duration(milliseconds: 1500),
                                curve: Curves.easeOutCubic,
                                tween: Tween<double>(
                                  begin: 0,
                                  end: currentSavings / savingsGoal,
                                ),
                                builder: (context, value, _) {
                                  return CircularProgressIndicator(
                                    value: value,
                                    strokeWidth: 12,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.green,
                                    ),
                                  );
                                },
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  '${(currentSavings / savingsGoal * 100).toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                Text(
                                  'Completed',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Current',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Text(
                              'Goal',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$${currentSavings.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$${savingsGoal.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Achievements section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Financial Achievements',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: achievements.length,
                  itemBuilder: (context, index) {
                    return _buildAchievementItem(achievements[index], isDark);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAchievementItem(Achievement achievement, bool isDark) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: achievement.color.withOpacity(isDark ? 0.2 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                achievement.iconData,
                color: achievement.completed ? Colors.amber : achievement.color,
                size: 24,
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
                        achievement.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (achievement.completed)
                        Container(
                          margin: EdgeInsets.only(left: 8),
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'COMPLETED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: achievement.progress,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              achievement.completed
                                  ? Colors.amber
                                  : achievement.color,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 12),
                            SizedBox(width: 4),
                            Text(
                              '${achievement.xpReward} XP',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced Transaction class with more data fields
class Transaction {
  final String id;
  final String desc;
  final double amount;
  final String category;
  final DateTime date;
  final IconData iconData;

  Transaction({
    required this.id,
    required this.desc,
    required this.amount,
    required this.category,
    required this.date,
    required this.iconData,
  });
}

// Budget goal class
class BudgetGoal {
  final String category;
  double currentSpent;
  final double budgetLimit;
  final IconData iconData;
  final Color color;

  BudgetGoal({
    required this.category,
    required this.currentSpent,
    required this.budgetLimit,
    required this.iconData,
    required this.color,
  });
}

// Achievement class for gamification
class Achievement {
  final String title;
  final String description;
  final double progress;
  final IconData iconData;
  final Color color;
  final int xpReward;
  final bool completed;

  Achievement({
    required this.title,
    required this.description,
    required this.progress,
    required this.iconData,
    required this.color,
    required this.xpReward,
    this.completed = false,
  });
}

// Create the necessary provider files for theme management
