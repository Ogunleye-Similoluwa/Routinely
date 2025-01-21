import 'package:flutter/material.dart';
import 'package:habit_speed_code/pages/habitsPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'pages/homePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Routinely',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NavigationScreen(
        currentIndex: 0,
      ),
    );
  }
}

class NavigationScreen extends StatefulWidget {
  NavigationScreen({required this.currentIndex});
  int currentIndex;
  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  List<Map<String, dynamic>> habits = [];
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final storedHabits = prefs.getString('habits');
    if (storedHabits != null) {
      setState(() {
        habits = List<Map<String, dynamic>>.from(
          json.decode(storedHabits).map((x) => Map<String, dynamic>.from(x)),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomePage(habits: habits, onHabitsChanged: _loadHabits),
      Habitspage(habits: habits, onHabitsChanged: _loadHabits),
    ];

    return Scaffold(
      body: IndexedStack(
        index: widget.currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.deepPurpleAccent,
        currentIndex: widget.currentIndex,
        onTap: (index) {
          setState(() {
            widget.currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          // BottomNavigationBarItem(
          //     icon: Icon(Icons.calendar_today), label: "Progress"),
          BottomNavigationBarItem(icon: Icon(Icons.timeline), label: "Habits"),
          // BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile")
        ],
      ),
    );
  }
}
