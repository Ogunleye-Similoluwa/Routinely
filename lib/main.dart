import 'package:flutter/material.dart';
import 'package:habit_speed_code/pages/habitsPage.dart';
import 'package:habit_speed_code/pages/profilePage.dart';
import 'package:habit_speed_code/pages/progressPage.dart';

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

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomePage(),
      // ProgressPage(habits: habits),
      Habitspage(),
      ProfilePage()
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
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile")
        ],
      ),
    );
  }
}
