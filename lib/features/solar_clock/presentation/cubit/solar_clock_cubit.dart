import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solar_alarm/core/services/alarm_permissions.dart';

import '../../domain/entities/solar_time_item.dart';
import '../../domain/repositories/solar_clock_repository.dart';
import 'solar_clock_state.dart';

class SolarClockCubit extends Cubit<SolarClockState> {
  final SolarClockRepository repository;
  Timer? _ticker;

  SolarClockCubit({required this.repository}) : super(const SolarClockState()) {
    loadCycle();
    // Update every minute to refresh progress and next upcoming event
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) => refreshCycle());
  }

  void loadCycle() async {
    emit(state.copyWith(status: SolarClockStatus.loading));
    await refreshCycle();
  }

  Future<void> refreshCycle() async {
    final cycle = await repository.getDayCycle(
      date: DateTime.now(),
      lat: state.lat,
      lng: state.lng,
      region: state.region,
    );
    emit(state.copyWith(status: SolarClockStatus.loaded, cycle: cycle));
  }

  void selectEvent(SolarEventType event) {
    emit(state.copyWith(selectedEvent: event));
  }

  void setOffset(int offset) {
    emit(state.copyWith(offsetMinutes: offset));
  }

  void setRegion(String region) {
    emit(state.copyWith(region: region, status: SolarClockStatus.loading));
    refreshCycle();
  }

  Future<void> scheduleAlarm() async {
    final cycle = state.cycle;
    if (cycle == null) return;

    try {
      final permissionsGranted = await AlarmPermissions.ensure();
      if (isClosed) return;
      if (!permissionsGranted) {
        emit(
          state.copyWith(
            message: 'Bildirishnoma va aniq uyg\'otgich ruxsatlarini bering',
          ),
        );
        return;
      }

      final targetItem = cycle.items.firstWhere(
        (item) => item.type == state.selectedEvent,
        orElse: () => cycle.items.first,
      );
      final scheduled = await repository.scheduleAlarm(
        eventType: targetItem.type,
        eventTime: targetItem.time,
        offsetMinutes: state.offsetMinutes,
      );

      if (isClosed) return;
      emit(
        state.copyWith(
          activeAlarmTime: scheduled,
          message: 'Budilnik muvaffaqiyatli saqlandi',
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(message: 'Budilnikni saqlash imkoni bo\'lmadi'));
    }
  }

  Future<void> cancelAlarm() async {
    await repository.cancelAlarm();
    emit(
      state.copyWith(
        clearActiveAlarmTime: true,
        message: 'Budilnik o\'chirildi',
      ),
    );
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
