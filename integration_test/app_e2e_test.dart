import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:solar_alarm/main.dart';
import 'package:solar_alarm/di.dart';

void main() {
  patrolTest(
    'Full Solar Alarm E2E Flow: Navigation, Focus Timer, Planner, and Alarm',
    ($) async {
      WidgetsFlutterBinding.ensureInitialized();
      await initDi();
      await $.pumpWidgetAndSettle(const SolarFocusApp());

      // 1. Verify Solar Clock View
      expect($('Quyosh'), findsWidgets);
      expect($('Toshkent'), findsWidgets);

      // 2. Test Qumsoat Focus Timer
      await $('Qumsoat').tap();
      expect($('Qumsoat Fokus'), findsOneWidget);
      expect($("Qat'iy rejim (Deep Work)"), findsOneWidget);

      // Tap 25 min preset and start/pause
      if ($('25 daq').exists) {
        await $('25 daq').tap();
      }
      await $('Boshlash').tap();
      await $.pump(const Duration(milliseconds: 600));
      expect($('Pauza'), findsOneWidget);

      await $('Pauza').tap();
      await $.pump(const Duration(milliseconds: 600));
      expect($('Boshlash'), findsOneWidget);

      // 3. Test Rejalar (Planner) Navigation
      await $('Rejalar').tap();
      expect($('Kunlik Rejalar'), findsOneWidget);

      // 4. Test Uyg'otgich Navigation
      await $("Uyg'otgich").tap();
      expect($("Uyg'otgich"), findsWidgets);
    },
  );

  patrolTest("Alarm Create and List Flow", ($) async {
    WidgetsFlutterBinding.ensureInitialized();
    await initDi();
    await $.pumpWidgetAndSettle(const SolarFocusApp());

    // Navigate to Uyg'otgich tab
    await $("Uyg'otgich").tap();
    await $.pumpAndSettle();

    // Open add alarm page via AppBar icon
    await $(Icons.add_rounded).tap();
    await $.pumpAndSettle();

    // AddEditAlarmPage opened
    expect($('Yangi Uyg\'otgich'), findsWidgets);

    // Save with defaults (label = 'Ertalabki uyg\'onish')
    await $('Saqlash').tap();
    await $.pumpAndSettle();

    // Alarm appears in list
    expect($("Ertalabki uyg'onish"), findsWidgets);

    // Toggle the alarm switch
    await $(CupertinoSwitch).tap();
    await $.pumpAndSettle();
  });
}
