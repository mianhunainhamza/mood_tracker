
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/mood_controller.dart';
import 'views/home_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MoodTrackerApp());
}

class MoodTrackerApp extends StatelessWidget {
  const MoodTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Mood Tracker',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFD166),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0D1117),
      ),
      initialBinding: BindingsBuilder(() {
        Get.lazyPut<MoodController>(
          () => MoodController(),
          fenix: true,
        );
      }),
      home: const HomeView(),
    );
  }
}
