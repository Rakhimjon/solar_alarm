import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:solar_alarm/core/theme/app_theme.dart';
import '../../domain/entities/solar_time_item.dart';
import '../cubit/solar_clock_cubit.dart';
import '../cubit/solar_clock_state.dart';

class SolarClockView extends StatelessWidget {
  const SolarClockView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SolarClockCubit, SolarClockState>(
      listenWhen: (prev, curr) => curr.message != null,
      listener: (context, state) {
        if (state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppTheme.cardColor,
              content: Text(
                state.message!,
                style: const TextStyle(color: AppTheme.primaryAmber),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final cycle = state.cycle;
        if (cycle == null) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryAmber));
        }

        final next = cycle.nextEvent;
        final timeUntil = cycle.timeUntilNext;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Quyosh & Namoz Soati'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: AppTheme.textMuted),
                onPressed: () => context.read<SolarClockCubit>().refreshCycle(),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero Next Event Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('EEEE, d MMMM').format(cycle.date),
                              style: const TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 13,
                              ),
                            ),
                            const Text(
                              '📍 Toshkent',
                              style: TextStyle(
                                color: AppTheme.primaryAmber,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (next != null) ...[
                          Text(
                            next.icon,
                            style: const TextStyle(fontSize: 40),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Keyingi vaqt: ${next.title}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('HH:mm').format(next.time),
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textLight,
                              letterSpacing: 1.2,
                            ),
                          ),
                          if (timeUntil != null)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryAmber.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${timeUntil.inHours}s ${timeUntil.inMinutes % 60}d qoldi',
                                style: const TextStyle(
                                  color: AppTheme.primaryAmber,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Solar Daylight Progress Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Quyosh Harakati (Kungi sikl)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textLight,
                            ),
                          ),
                          Text(
                            '${(cycle.dayProgress * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryAmber,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: cycle.dayProgress,
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          valueColor: const AlwaysStoppedAnimation(AppTheme.primaryAmber),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // All times list
                const Text(
                  'Bugungi Barcha Vaqtlar',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: 10),
                ...cycle.items.map((item) {
                  final isNext = next?.type == item.type;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isNext
                          ? AppTheme.primaryAmber.withValues(alpha: 0.12)
                          : AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isNext ? AppTheme.primaryAmber : AppTheme.cardBorder,
                        width: isNext ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(item.icon, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
                                  color: AppTheme.textLight,
                                ),
                              ),
                              if (isNext)
                                const Text(
                                  'Hozirgi / Navbatdagi',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.primaryAmber,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Text(
                          DateFormat('HH:mm').format(item.time),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isNext ? AppTheme.primaryAmber : AppTheme.textLight,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.alarm_add_rounded, size: 20),
                          color: AppTheme.textMuted,
                          onPressed: () => _showAlarmSheet(context, item),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAlarmSheet(BuildContext context, SolarTimeItem item) {
    final cubit = context.read<SolarClockCubit>();
    cubit.selectEvent(item.type);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return BlocBuilder<SolarClockCubit, SolarClockState>(
          bloc: cubit,
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${item.title} uchun budilnik',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Vaqt: ${DateFormat('HH:mm').format(item.time)}',
                    style: const TextStyle(color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Siljish: ${state.offsetMinutes >= 0 ? "+${state.offsetMinutes}" : "${state.offsetMinutes}"} daqiqa',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryAmber,
                    ),
                  ),
                  Slider(
                    value: state.offsetMinutes.toDouble(),
                    min: -60,
                    max: 60,
                    divisions: 24,
                    activeColor: AppTheme.primaryAmber,
                    inactiveColor: AppTheme.cardBorder,
                    label: '${state.offsetMinutes} daq',
                    onChanged: (val) => cubit.setOffset(val.toInt()),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryAmber,
                      foregroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      cubit.scheduleAlarm();
                      Navigator.pop(sheetContext);
                    },
                    child: const Text('Budilnikni Yoqish', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      cubit.cancelAlarm();
                      Navigator.pop(sheetContext);
                    },
                    child: const Text('Budilnikni O\'chirish', style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
