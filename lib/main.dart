import 'package:flutter/material.dart';
import 'di.dart';
import 'features/solar_alarm/presentation/pages/solar_alarm_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDi();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SolarAlarmPage(),
    );
  }
}
