import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../data/datasources/prayer_times_remote_datasource.dart';
import '../../domain/entities/solar_time_item.dart';
import '../cubit/solar_clock_cubit.dart';
import '../cubit/solar_clock_state.dart';

class SolarClockView extends StatelessWidget {
  const SolarClockView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocConsumer<SolarClockCubit, SolarClockState>(
      listenWhen: (prev, curr) => curr.message != null,
      listener: (context, state) {
        if (state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: colors.card,
              content: Text(
                state.message!,
                style: TextStyle(color: colors.primary),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final cycle = state.cycle;
        if (cycle == null) {
          return Center(child: CircularProgressIndicator(color: colors.primary));
        }

        final next = cycle.nextEvent;
        final timeUntil = cycle.timeUntilNext;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Quyosh & Namoz Soati'),
            actions: [
              // ── Viloyat tanlash ──────────────────────
              BlocBuilder<SolarClockCubit, SolarClockState>(
                buildWhen: (p, c) => p.region != c.region,
                builder: (context, state) {
                  return PopupMenuButton<String>(
                    tooltip: 'Viloyat tanlash',
                    icon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on_rounded, color: colors.primary, size: 18),
                        const SizedBox(width: 2),
                        Text(
                          state.region,
                          style: TextStyle(
                            color: colors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: colors.primary, size: 18),
                      ],
                    ),
                    onSelected: (region) =>
                        context.read<SolarClockCubit>().setRegion(region),
                    itemBuilder: (_) => kUzbekRegions
                        .map((r) => PopupMenuItem(value: r, child: Text(r)))
                        .toList(),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  context.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: colors.primary,
                ),
                tooltip: context.isDark ? 'Yorug\' rejim' : 'Qorong\'u rejim',
                onPressed: () => context.read<ThemeCubit>().toggleTheme(),
              ),
              IconButton(
                icon: Icon(Icons.refresh, color: colors.textMuted),
                tooltip: 'Yangilash',
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
                              style: TextStyle(
                                color: colors.textMuted,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '📍 Toshkent',
                              style: TextStyle(
                                color: colors.primary,
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
                            style: TextStyle(
                              fontSize: 16,
                              color: colors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('HH:mm').format(next.time),
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
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
                                color: colors.primary.withValues(alpha: context.isDark ? 0.15 : 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${timeUntil.inHours}s ${timeUntil.inMinutes % 60}d qoldi',
                                style: TextStyle(
                                  color: colors.primary,
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
                    color: colors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Quyosh Harakati (Kungi sikl)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                          Text(
                            '${(cycle.dayProgress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: colors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: cycle.dayProgress,
                          backgroundColor: context.isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.06),
                          valueColor: AlwaysStoppedAnimation(colors.primary),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // All times list
                Text(
                  'Bugungi Barcha Vaqtlar',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
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
                          ? colors.primary.withValues(alpha: context.isDark ? 0.12 : 0.08)
                          : colors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isNext ? colors.primary : colors.cardBorder,
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
                                  color: colors.textPrimary,
                                ),
                              ),
                              if (isNext)
                                Text(
                                  'Hozirgi / Navbatdagi',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colors.primary,
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
                            color: isNext ? colors.primary : colors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.alarm_add_rounded, size: 20),
                          color: colors.textMuted,
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
    final colors = context.appColors;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return BlocBuilder<SolarClockCubit, SolarClockState>(
          bloc: cubit,
          builder: (context, state) {
            final sheetColors = context.appColors;
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${item.title} uchun budilnik',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: sheetColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Vaqt: ${DateFormat('HH:mm').format(item.time)}',
                    style: TextStyle(color: sheetColors.textMuted),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Siljish: ${state.offsetMinutes >= 0 ? "+${state.offsetMinutes}" : "${state.offsetMinutes}"} daqiqa',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: sheetColors.primary,
                    ),
                  ),
                  Slider(
                    value: state.offsetMinutes.toDouble(),
                    min: -60,
                    max: 60,
                    divisions: 24,
                    activeColor: sheetColors.primary,
                    inactiveColor: sheetColors.cardBorder,
                    label: '${state.offsetMinutes} daq',
                    onChanged: (val) => cubit.setOffset(val.toInt()),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: sheetColors.primary,
                      foregroundColor: Colors.white,
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
