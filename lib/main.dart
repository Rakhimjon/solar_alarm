import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'alarm_service.dart';
import 'cubit/solar_alarm_cubit.dart';
import 'solar_calculator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SolarAlarmService.init();
  runApp(
    BlocProvider(
      create: (_) => SolarAlarmCubit(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SolarAlarmPage(),
      ),
    ),
  );
}

class SolarAlarmPage extends StatelessWidget {
  const SolarAlarmPage({super.key});

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
      body: BlocConsumer<SolarAlarmCubit, SolarAlarmState>(
        listenWhen: (previous, current) => current.message != null,
        listener: (context, state) {
          if (state.message != null) {
            final details = state.status == SolarAlarmStatus.scheduled && state.nextAlarm != null
                ? ': ${DateFormat('dd-MMM, HH:mm').format(state.nextAlarm!)}'
                : '';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${state.message}$details')),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<SolarAlarmCubit>();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                  value: state.event,
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
                    if (val != null) cubit.changeEvent(val);
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Siljish: ${state.offsetMinutes >= 0 ? "+${state.offsetMinutes}" : "${state.offsetMinutes}"} daqiqa',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Slider(
                  value: state.offsetMinutes.toDouble(),
                  min: -60,
                  max: 60,
                  divisions: 24,
                  label: '${state.offsetMinutes} daq',
                  onChanged: (val) => cubit.changeOffset(val.toInt()),
                ),
                const SizedBox(height: 20),
                if (state.nextAlarm != null)
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
                          DateFormat('yyyy-MM-dd HH:mm').format(state.nextAlarm!),
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
                  onPressed: () => cubit.scheduleAlarm(),
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
                  onPressed: () => cubit.cancelAlarm(),
                  child: const Text('O\'chirish',
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
