import 'package:flutter/material.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/HomePage/nearby_mosques_screen.dart';
import 'package:mosque_finder/SRC/Presentation/Widgets/tasbih_screen/tasbih_screen.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  final ValueNotifier<int> currentPage = ValueNotifier(0);
  List<Widget> pages = [
    NearbyMosquesScreen(),
    Container(color: Colors.red),
    Container(color: Colors.white),
    const TasbihScreen(),
    Container(color: Colors.blueGrey),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF5E35B1), // deep purple
              Color(0xFF283593), // indigo
              Color(0xFF1A237E), // dark blue
            ],
          ),
        ),
        child: ValueListenableBuilder(
          valueListenable: currentPage,
          builder: (context, value, child) {
            return pages[currentPage.value];
          },
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: currentPage,
        builder: (context, value, child) {
          return BottomNavigationBar(
            backgroundColor: const Color(
              0xFF1A237E,
            ).withAlpha((255 * 0.9).toInt()),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            onTap: (value) {
              currentPage.value = value;
            },
            currentIndex: currentPage.value, // Home
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: "Search",
              ),
              BottomNavigationBarItem(icon: Icon(Icons.book), label: "Quran"),
              BottomNavigationBarItem(
                icon: Icon(Icons.calculate),
                label: "Tasbih",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.more_horiz),
                label: "More",
              ),
            ],
          );
        },
      ),
    );
  }
}
