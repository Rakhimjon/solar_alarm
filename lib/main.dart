import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'alarm_service.dart';
import 'solar_calculator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SolarAlarmService.init();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SolarAlarmPage(),
  ));
}

class SolarAlarmPage extends StatefulWidget {
  const SolarAlarmPage({super.key});

  @override
  State<SolarAlarmPage> createState() => _SolarAlarmPageState();
}

class _SolarAlarmPageState extends State<SolarAlarmPage> {
  DateTime? _nextAlarm;
  SolarEvent _event = SolarEvent.sunrise;
  int _offsetMinutes = -15;

  @override
  void initState() {
    super.initState();
    _refreshTimes();
  }

  void _refreshTimes() {
    setState(() {
      _nextAlarm = SolarCalculator.getNextAlarmTime(
        lat: SolarAlarmService.defaultLat,
        lng: SolarAlarmService.defaultLng,
        event: _event,
        offsetMinutes: _offsetMinutes,
      );
    });
  }

  Future<void> _setAlarm() async {
    final messenger = ScaffoldMessenger.of(context);
    final time = await SolarAlarmService.scheduleNextSolarAlarm(
      event: _event,
      offsetMinutes: _offsetMinutes,
    );
    if (!mounted) return;
    setState(() => _nextAlarm = time);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
            'Budilnik qo\'yildi: ${DateFormat('dd-MMM, HH:mm').format(time)}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final sunrise = SolarCalculator.getSolarTime(
      date: now,
      lat: SolarAlarmService.defaultLat,
      lng: SolarAlarmService.defaultLng,
      event: SolarEvent.sunrise,
    );
    final sunset = SolarCalculator.getSolarTime(
      date: now,
      lat: SolarAlarmService.defaultLat,
      lng: SolarAlarmService.defaultLng,
      event: SolarEvent.sunset,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quyosh Budilnik'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Bugungi quyosh vaqtlari (Toshkent)',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('☀️ Chiqish: ${DateFormat.Hm().format(sunrise)}'),
                        Text('🌙 Botish: ${DateFormat.Hm().format(sunset)}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<SolarEvent>(
              initialValue: _event,
              decoration: const InputDecoration(
                labelText: 'Hodisa turi',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: SolarEvent.sunrise,
                  child: Text('Quyosh chiqishi'),
                ),
                DropdownMenuItem(
                  value: SolarEvent.sunset,
                  child: Text('Quyosh botishi'),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _event = val;
                    _refreshTimes();
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Siljish: ${_offsetMinutes >= 0 ? "+$_offsetMinutes" : "$_offsetMinutes"} daqiqa',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Slider(
              value: _offsetMinutes.toDouble(),
              min: -60,
              max: 60,
              divisions: 24,
              label: '$_offsetMinutes daq',
              onChanged: (val) => setState(() {
                _offsetMinutes = val.toInt();
                _refreshTimes();
              }),
            ),
            const SizedBox(height: 20),
            if (_nextAlarm != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const Text('Keyingi chalinish vaqti:'),
                    Text(
                      DateFormat('yyyy-MM-dd HH:mm').format(_nextAlarm!),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            const Spacer(),
            ElevatedButton(
              onPressed: _setAlarm,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.amber.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Budilnikni Yoqish',
                  style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                await SolarAlarmService.cancelAlarm();
                if (!mounted) return;
                messenger.showSnackBar(
                  const SnackBar(content: Text('Budilnik o\'chirildi')),
                );
              },
              child: const Text('O\'chirish',
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
