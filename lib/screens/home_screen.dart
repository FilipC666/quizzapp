import 'package:flutter/material.dart';
import '../models.dart';
import '../services.dart';
import 'quiz_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final FirebaseService _firebaseService = FirebaseService();
  List<Category> _categories = [];
  bool _isLoading = true;
  bool _isOffline = false;

  final List<Color> _categoryColors = [
    Colors.deepPurple,
    Colors.blue,
    Colors.teal,
    Colors.green,
    Colors.orange,
    Colors.redAccent,
    Colors.indigo,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _isOffline = false;
    });

    try {
      final fetchedCategories = await _apiService.fetchCategories();
      await HiveService.saveCategories(fetchedCategories);
      setState(() {
        _categories = fetchedCategories;
        _isLoading = false;
      });
    } catch (e) {
      final cachedCategories = HiveService.getCategories();
      setState(() {
        _categories = cachedCategories;
        _isOffline = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    await _firebaseService.logCategoryRefreshed();
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StatsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isOffline)
            Container(
              color: Colors.redAccent,
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              child: const Text(
                'Offline mode. Showing cached categories.',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
              onRefresh: _handleRefresh,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final color = _categoryColors[index % _categoryColors.length];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizScreen(category: category),
                          ),
                        );
                      },
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color.withOpacity(0.8), color],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -20,
                              top: -20,
                              child: Icon(
                                Icons.category,
                                size: 100,
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            Center(
                              child: Text(
                                category.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 4.0,
                                      color: Colors.black26,
                                      offset: Offset(2.0, 2.0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}