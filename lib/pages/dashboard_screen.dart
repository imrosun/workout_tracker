import 'package:flutter/material.dart';
import 'package:workout_tracker/pages/home_page.dart';
import 'package:workout_tracker/pages/history_page.dart';
import 'package:workout_tracker/auth/auth_service.dart';
import 'package:workout_tracker/pages/login_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_tracker/blocs/theme_bloc.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [HomePage(), HistoryPage()];

  final authService = AuthService();

  // Logout method
  void logout() async {
    await authService.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _pages[_currentIndex],
          Positioned(
            top: 10,
            right: 16,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.brightness_6),
                  onPressed: () {
                    context.read<ThemeCubit>().toggleTheme();
                  },
                ),
                IconButton(icon: Icon(Icons.logout), onPressed: logout),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }
}
