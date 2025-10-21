import 'package:flutter/material.dart';

// These are USED below in _pages, so the analyzer won’t flag them.
import 'pages/home_page.dart';
import 'pages/sensors_page.dart';
import 'pages/routines_page.dart';
import 'pages/calculator_page.dart';
import 'pages/flutter3Dviewer.dart';
import 'app_store.dart';

void main() => runApp(const LidaApp());

class LidaApp extends StatelessWidget {
  const LidaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lida Demo',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF00A36C),
        useMaterial3: true,
      ),
      home: const _RootShell(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class _RootShell extends StatefulWidget {
  const _RootShell();
  @override
  State<_RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<_RootShell> {
  final _pages = const <Widget>[
    HomePage(),
    SensorsPage(),
    RoutinesPage(),
    Flutter3DAnimationScreen(),
    CalculatorPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppNav.index,
      builder: (_, idx, __) {
        return Scaffold(
          body: SafeArea(child: _pages[idx]),
          bottomNavigationBar: NavigationBar(
            selectedIndex: idx,
            onDestinationSelected: (i) => AppNav.index.value = i,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.sensors),
                label: 'Sensors',
              ),
              NavigationDestination(
                icon: Icon(Icons.play_circle_outline),
                label: 'Routines',
              ),
              NavigationDestination(
                icon: Icon(Icons.threed_rotation),
                label: '3D',
              ),
              NavigationDestination(
                icon: Icon(Icons.calculate_outlined),
                label: 'Calculation',
              ),
            ],
          ),
        );
      },
    );
  }
}
