import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jarvis/providers/theme_provider.dart';
import 'package:jarvis/providers/user_data_provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lottie/lottie.dart';
import 'package:confetti/confetti.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:math';

enum TaskRarity { common, uncommon, rare, epic, legendary }

class TodoQuestScreen extends StatefulWidget {
  @override
  _TodoQuestScreenState createState() => _TodoQuestScreenState();
}

class _TodoQuestScreenState extends State<TodoQuestScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _addTaskController;
  late Animation<double> _addTaskAnimation;

  // Confetti controller for task completion celebration
  late ConfettiController _confettiController;

  // Quest progress animation controllers
  Map<int, AnimationController> _questAnimationControllers = {};

  // Tasks and quests data
  List<Task> tasks = [
    Task(
        text: 'Complete morning workout',
        completed: true,
        xp: 25,
        rarity: TaskRarity.common),
    Task(
        text: 'Review project proposal',
        completed: false,
        xp: 30,
        rarity: TaskRarity.uncommon),
    Task(
        text: 'Schedule team meeting',
        completed: false,
        xp: 20,
        rarity: TaskRarity.common),
    Task(
        text: 'Research new productivity tools',
        completed: false,
        xp: 35,
        rarity: TaskRarity.rare),
  ];

  List<Quest> dailyQuests = [
    Quest(
        text: 'Drink 8 glasses of water',
        progress: 6,
        target: 8,
        xp: 50,
        deadline: 'Today'),
    Quest(
        text: 'Complete 3 work tasks',
        progress: 2,
        target: 3,
        xp: 40,
        deadline: 'Today'),
    Quest(
        text: 'Log all meals',
        progress: 2,
        target: 3,
        xp: 30,
        deadline: 'Today'),
    Quest(
        text: 'Meditate for 10 minutes',
        progress: 0,
        target: 1,
        xp: 25,
        deadline: 'Today'),
  ];

  List<Quest> weeklyQuests = [
    Quest(
        text: 'Exercise 5 times',
        progress: 3,
        target: 5,
        xp: 100,
        deadline: '4 days left'),
    Quest(
        text: 'Save \$100',
        progress: 50,
        target: 100,
        xp: 150,
        deadline: '4 days left'),
  ];

  TextEditingController _taskController = TextEditingController();
  bool _showAddTask = false;
  int _selectedTaskRarity = 0;
  int _selectedTab = 0;

  // Recently completed task animation
  int? _lastCompletedTaskIndex;
  bool _showXpGain = false;
  String _xpGainText = "";
  bool _showQuestCompleted = false;

  @override
  void initState() {
    super.initState();

    // Initialize add task animation
    _addTaskController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _addTaskAnimation = CurvedAnimation(
      parent: _addTaskController,
      curve: Curves.easeOut,
    );

    // Initialize confetti controller
    _confettiController = ConfettiController(duration: Duration(seconds: 2));

    // Initialize quest progress animations
    for (int i = 0; i < dailyQuests.length; i++) {
      _questAnimationControllers[i] = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1500),
      );

      double targetValue = dailyQuests[i].progress / dailyQuests[i].target;
      _questAnimationControllers[i]!.animateTo(targetValue);
    }

    for (int i = 0; i < weeklyQuests.length; i++) {
      _questAnimationControllers[dailyQuests.length + i] = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1500),
      );

      double targetValue = weeklyQuests[i].progress / weeklyQuests[i].target;
      _questAnimationControllers[dailyQuests.length + i]!
          .animateTo(targetValue);
    }
  }

  @override
  void dispose() {
    _addTaskController.dispose();
    _confettiController.dispose();

    _questAnimationControllers.forEach((_, controller) {
      controller.dispose();
    });

    super.dispose();
  }

  void _toggleAddTask() {
    setState(() {
      _showAddTask = !_showAddTask;
      if (_showAddTask) {
        _addTaskController.forward();
      } else {
        _addTaskController.reverse();
        _taskController.clear();
        _selectedTaskRarity = 0;
      }
    });
  }

  void _addTask() {
    if (_taskController.text.isEmpty) return;

    TaskRarity rarity;
    int xp;

    switch (_selectedTaskRarity) {
      case 0:
        rarity = TaskRarity.common;
        xp = 20;
        break;
      case 1:
        rarity = TaskRarity.uncommon;
        xp = 35;
        break;
      case 2:
        rarity = TaskRarity.rare;
        xp = 50;
        break;
      case 3:
        rarity = TaskRarity.epic;
        xp = 75;
        break;
      default:
        rarity = TaskRarity.common;
        xp = 20;
    }

    setState(() {
      tasks.insert(
          0,
          Task(
            text: _taskController.text,
            completed: false,
            xp: xp,
            rarity: rarity,
          ));
      _toggleAddTask();
    });
  }

  void _toggleTask(Task t, int index) {
    setState(() {
      t.completed = !t.completed;
      if (t.completed) {
        _lastCompletedTaskIndex = index;
        _xpGainText = "+${t.xp} XP";
        _showXpGain = true;
        _confettiController.play();

        // Update any related quests
        for (var quest in dailyQuests) {
          if (quest.text.contains('work tasks') &&
              quest.progress < quest.target) {
            quest.progress += 1;
            _updateQuestProgress(dailyQuests.indexOf(quest));

            // Check if quest completed
            if (quest.progress >= quest.target) {
              _showQuestCompleted = true;
              Future.delayed(Duration(seconds: 2), () {
                if (mounted) {
                  setState(() {
                    _showQuestCompleted = false;
                  });
                }
              });
            }
            break;
          }
        }

        // Hide XP gain animation after delay
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _showXpGain = false;
            });
          }
        });
      }
    });
  }

  void _updateQuestProgress(int index) {
    if (_questAnimationControllers.containsKey(index)) {
      double targetValue =
          dailyQuests[index].progress / dailyQuests[index].target;
      _questAnimationControllers[index]!.animateTo(targetValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userData = Provider.of<UserDataProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            themeProvider.isDarkMode ? Colors.grey[900] : Colors.teal,
        title: Text('Quests & Tasks'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Tab selector for Daily/Weekly
              Container(
                color: themeProvider.isDarkMode
                    ? Colors.grey[850]
                    : Colors.teal[50],
                child: Row(
                  children: [
                    _buildTabButton('Daily Quests', 0),
                    _buildTabButton('Weekly Quests', 1),
                    _buildTabButton('My Tasks', 2),
                  ],
                ),
              ),

              // Content based on selected tab
              Expanded(
                child: _selectedTab == 0
                    ? _buildDailyQuestsTab(themeProvider)
                    : _selectedTab == 1
                        ? _buildWeeklyQuestsTab(themeProvider)
                        : _buildTasksTab(themeProvider),
              ),
            ],
          ),

          // Add task panel
          _buildAddTaskPanel(themeProvider),

          // XP gain animation
          if (_showXpGain && _lastCompletedTaskIndex != null)
            _buildXpGainAnimation(),

          // Confetti animation
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 10,
              gravity: 0.1,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
                Colors.teal,
              ],
            ),
          ),

          // Quest completed overlay
          if (_showQuestCompleted) _buildQuestCompletedOverlay(),
        ],
      ),
      floatingActionButton: _selectedTab == 2
          ? FloatingActionButton(
              backgroundColor: themeProvider.accentColor,
              child: Icon(_showAddTask ? Icons.close : Icons.add),
              onPressed: _toggleAddTask,
            )
          : null,
    );
  }

  Widget _buildTabButton(String text, int index) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isSelected = _selectedTab == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color:
                    isSelected ? themeProvider.accentColor : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? themeProvider.accentColor
                  : themeProvider.isDarkMode
                      ? Colors.white70
                      : Colors.black54,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyQuestsTab(ThemeProvider themeProvider) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Daily quest stats
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode
                  ? Colors.grey[800]
                  : Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuestStat(
                    'Completed',
                    '${dailyQuests.where((q) => q.progress >= q.target).length}/${dailyQuests.length}',
                    themeProvider),
                _buildQuestStat(
                    'XP Available',
                    '${dailyQuests.fold(0, (sum, q) => sum + q.xp)}',
                    themeProvider),
                _buildQuestStat('Time Left', '8h 23m', themeProvider),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Quests list
          AnimationLimiter(
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: dailyQuests.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: Duration(milliseconds: 400),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildQuestItem(
                          dailyQuests[index], index, themeProvider),
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

  Widget _buildWeeklyQuestsTab(ThemeProvider themeProvider) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weekly quest stats
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode
                  ? Colors.grey[800]
                  : Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: themeProvider.isDarkMode
                    ? Colors.transparent
                    : Colors.blue.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuestStat(
                    'Completed',
                    '${weeklyQuests.where((q) => q.progress >= q.target).length}/${weeklyQuests.length}',
                    themeProvider),
                _buildQuestStat(
                    'XP Available',
                    '${weeklyQuests.fold(0, (sum, q) => sum + q.xp)}',
                    themeProvider),
                _buildQuestStat('Resets In', '4d 12h', themeProvider),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Quests list
          AnimationLimiter(
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: weeklyQuests.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: Duration(milliseconds: 400),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildQuestItem(
                        weeklyQuests[index],
                        dailyQuests.length + index,
                        themeProvider,
                        isWeekly: true,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 20),

          // Upcoming weekly quests
          Text(
            'Upcoming Challenges',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),

          SizedBox(height: 12),

          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode
                  ? Colors.grey[850]!.withOpacity(0.5)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_clock,
                    color: Colors.purple,
                  ),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Milestone Challenge',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                    Text(
                      'Unlocks in 2 days',
                      style: TextStyle(
                        color: themeProvider.isDarkMode
                            ? Colors.grey[400]
                            : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.purple.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '200 XP',
                    style: TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksTab(ThemeProvider themeProvider) {
    return tasks.isEmpty
        ? _buildEmptyTasksView(themeProvider)
        : AnimationLimiter(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              physics: BouncingScrollPhysics(),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: Duration(milliseconds: 400),
                  child: SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildTaskItem(tasks[index], index, themeProvider),
                    ),
                  ),
                );
              },
            ),
          );
  }

  Widget _buildEmptyTasksView(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/empty_tasks.json',
            width: 200,
            height: 200,
            repeat: true,
          ),
          Text(
            'No tasks yet!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add your first task using the + button',
            style: TextStyle(
              color: themeProvider.isDarkMode
                  ? Colors.grey[400]
                  : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestStat(
      String label, String value, ThemeProvider themeProvider) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color:
                themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestItem(Quest quest, int index, ThemeProvider themeProvider,
      {bool isWeekly = false}) {
    final bool isCompleted = quest.progress >= quest.target;
    final double progress = quest.progress / quest.target;

    Color questColor = isWeekly ? Colors.blue : Colors.teal;
    if (isCompleted) {
      questColor = Colors.green;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Handle quest tap - show details or increment progress
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: questColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCompleted
                            ? Icons.check_circle
                            : isWeekly
                                ? Icons.calendar_today
                                : Icons.star_outline,
                        color: questColor,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quest.text,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 14,
                                color: themeProvider.isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                              SizedBox(width: 4),
                              Text(
                                quest.deadline,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: themeProvider.isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                              ),
                              Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.amber.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 12,
                                      color: Colors.amber,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '${quest.xp} XP',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber,
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
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _questAnimationControllers[index] ??
                            AnimationController(vsync: this),
                        builder: (context, child) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _questAnimationControllers[index]?.value ??
                                  progress,
                              backgroundColor: questColor.withOpacity(0.1),
                              color: questColor,
                              minHeight: 10,
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      '${quest.progress}/${quest.target}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskItem(Task task, int index, ThemeProvider themeProvider) {
    Color rarityColor;
    IconData rarityIcon;

    switch (task.rarity) {
      case TaskRarity.common:
        rarityColor = Colors.grey;
        rarityIcon = Icons.circle;
        break;
      case TaskRarity.uncommon:
        rarityColor = Colors.green;
        rarityIcon = Icons.check_circle;
        break;
      case TaskRarity.rare:
        rarityColor = Colors.blue;
        rarityIcon = Icons.star;
        break;
      case TaskRarity.epic:
        rarityColor = Colors.purple;
        rarityIcon = Icons.auto_awesome;
        break;
      case TaskRarity.legendary:
        rarityColor = Colors.orange;
        rarityIcon = Icons.whatshot;
        break;
    }

    return Dismissible(
      key: Key(task.text + index.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        setState(() {
          tasks.removeAt(index);
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
          border: task.rarity != TaskRarity.common
              ? Border.all(color: rarityColor.withOpacity(0.5))
              : null,
        ),
        child: InkWell(
          onTap: () => _toggleTask(task, index),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Theme(
                  data: Theme.of(context).copyWith(
                    unselectedWidgetColor: themeProvider.isDarkMode
                        ? Colors.grey[600]
                        : Colors.grey[400],
                  ),
                  child: Checkbox(
                    value: task.completed,
                    onChanged: (_) => _toggleTask(task, index),
                    activeColor: themeProvider.accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task.text,
                    style: TextStyle(
                      decoration:
                          task.completed ? TextDecoration.lineThrough : null,
                      color: task.completed
                          ? themeProvider.isDarkMode
                              ? Colors.grey[600]
                              : Colors.grey[500]
                          : themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: rarityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            rarityIcon,
                            size: 12,
                            color: rarityColor,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${task.xp} XP',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: rarityColor,
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
        ),
      ),
    );
  }

  Widget _buildAddTaskPanel(ThemeProvider themeProvider) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      bottom: _showAddTask ? 0 : -300,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 15,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add New Task',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: _toggleAddTask,
                ),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: _taskController,
              decoration: InputDecoration(
                hintText: 'Task description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: themeProvider.isDarkMode
                        ? Colors.grey[700]!
                        : Colors.grey[300]!,
                  ),
                ),
                filled: true,
                fillColor: themeProvider.isDarkMode
                    ? Colors.grey[800]
                    : Colors.grey[100],
              ),
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Task Difficulty',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildRarityButton('Easy', Colors.grey, 0),
                  _buildRarityButton('Medium', Colors.green, 1),
                  _buildRarityButton('Hard', Colors.blue, 2),
                  _buildRarityButton('Very Hard', Colors.purple, 3),
                ],
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeProvider.accentColor,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Create Task',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRarityButton(String label, Color color, int rarityIndex) {
    final isSelected = _selectedTaskRarity == rarityIndex;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTaskRarity = rarityIndex;
        });
      },
      child: Container(
        margin: EdgeInsets.only(right: 10),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildXpGainAnimation() {
    return Positioned(
      top: 150 + (_lastCompletedTaskIndex ?? 0) * 60,
      right: 20,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 500),
        builder: (context, value, child) {
          return Opacity(
            opacity: value > 0.5 ? 2 - 2 * value : 2 * value,
            child: Transform.translate(
              offset: Offset(0, -20 * value),
              child: child,
            ),
          );
        },
        child: Shimmer.fromColors(
          baseColor: Colors.amber,
          highlightColor: Colors.white,
          child: Text(
            _xpGainText,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestCompletedOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.teal.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.teal.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/quest_complete.json',
                width: 150,
                height: 150,
                repeat: true,
              ),
              Text(
                'QUEST COMPLETED!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'You earned 40 XP',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Complete 3 work tasks',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Task {
  String text;
  bool completed;
  int xp;
  TaskRarity rarity;

  Task({
    required this.text,
    this.completed = false,
    this.xp = 10,
    this.rarity = TaskRarity.common,
  });
}

class Quest {
  String text;
  int progress;
  int target;
  int xp;
  String deadline;

  Quest({
    required this.text,
    required this.progress,
    required this.target,
    required this.xp,
    required this.deadline,
  });
}
