import 'dart:async';
import 'dart:math';

import 'package:alarm/alarm.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/alarm_item.dart';
import '../../domain/repositories/alarm_repository.dart';
import 'alarm_state.dart';

class AlarmCubit extends Cubit<AlarmState> {
  final AlarmRepository repository;
  StreamSubscription? _ringSubscription;

  static const List<String> _affirmations = [
    'Xayrli tong! Bugun yangi imkoniyatlar va baraka kuni.',
    'Har bir yangi kun — yangi muvaffaqiyatlar boshlanishi.',
    'Salomatlik, xotirjamlik va unumli mehnat bilan boshlang.',
    'Bugungi kun orzularingiz sari intilish uchun ajoyib fursat.',
    'Bismillah, yangi kunni yuksak maqsadlar bilan boshlaymiz.',
  ];

  AlarmCubit({required this.repository}) : super(const AlarmState()) {
    loadAlarms(reschedule: true);
    _initRingListener();
  }

  void _initRingListener() {
    _ringSubscription = Alarm.ringing.listen((alarmSet) {
      if (alarmSet.alarms.isNotEmpty) {
        final ringingAlarm = alarmSet.alarms.first;
        final match = state.alarms
            .where((a) => a.id == ringingAlarm.id)
            .firstOrNull;

        final affirmation =
            _affirmations[Random().nextInt(_affirmations.length)];

        emit(
          state.copyWith(
            ringingAlarmId: ringingAlarm.id,
            ringingAlarmLabel:
                match?.label ?? ringingAlarm.notificationSettings.title,
            ringingRequireMath: match?.requireMathMission ?? false,
            remainingSunTaps: 5,
            morningAffirmation: affirmation,
          ),
        );
      } else if (state.isRinging) {
        emit(state.copyWith(clearRinging: true));
      }
    });
  }

  Future<void> loadAlarms({bool reschedule = false}) async {
    emit(state.copyWith(isLoading: true));
    try {
      if (reschedule) await repository.rescheduleAlarms();
      final alarms = await repository.getAlarms();
      if (isClosed) return;
      alarms.sort(
        (a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute),
      );
      emit(state.copyWith(alarms: alarms, isLoading: false));
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isLoading: false,
          message: 'Uyg\'otgichlarni yuklash imkoni bo\'lmadi',
        ),
      );
    }
  }

  Future<void> saveAlarm({
    required int hour,
    required int minute,
    required String label,
    required String soundPath,
    required String soundTitle,
    required List<int> repeatDays,
    required bool vibrate,
    bool requireMathMission = false,
    String? linkedSolarType,
    int solarOffsetMinutes = 0,
    double lat = 41.311081,
    double lng = 69.240562,
    String region = 'Toshkent',
    int? existingId,
  }) async {
    final id = existingId ?? DateTime.now().millisecondsSinceEpoch % 100000;
    final alarm = AlarmItem(
      id: id,
      hour: hour,
      minute: minute,
      label: label.isEmpty ? 'Uyg\'otgich' : label,
      soundPath: soundPath,
      soundTitle: soundTitle,
      repeatDays: repeatDays,
      vibrate: vibrate,
      requireMathMission: requireMathMission,
      linkedSolarType: linkedSolarType,
      solarOffsetMinutes: solarOffsetMinutes,
      lat: lat,
      lng: lng,
      region: region,
      isEnabled: true,
    );

    await repository.saveAlarm(alarm);
    await loadAlarms();
    emit(state.copyWith(message: 'Uyg\'otgich saqlandi'));
  }

  Future<void> toggleAlarm(int id) async {
    try {
      await repository.toggleAlarm(id);
      await loadAlarms();
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          message: 'Uyg\'otgich holatini o\'zgartirish imkoni bo\'lmadi',
        ),
      );
    }
  }

  Future<void> deleteAlarm(int id) async {
    await repository.deleteAlarm(id);
    await loadAlarms();
    emit(state.copyWith(message: 'Uyg\'otgich o\'chirildi'));
  }

  void tapSunRay() {
    if (state.remainingSunTaps > 1) {
      emit(state.copyWith(remainingSunTaps: state.remainingSunTaps - 1));
    } else {
      emit(state.copyWith(remainingSunTaps: 0));
      dismissRinging();
    }
  }

  Future<void> dismissRinging() async {
    final id = state.ringingAlarmId;
    if (id != null) {
      await repository.stopRinging(id);
      await loadAlarms();
    }
    if (isClosed) return;
    emit(state.copyWith(clearRinging: true));
  }

  Future<void> snoozeRinging({int minutes = 5}) async {
    final id = state.ringingAlarmId;
    if (id != null) {
      await repository.snoozeAlarm(id, minutes: minutes);
    }
    emit(
      state.copyWith(
        clearRinging: true,
        message: 'Uyg\'otgich $minutes daqiqaga kechiktirildi',
      ),
    );
  }

  @override
  Future<void> close() {
    _ringSubscription?.cancel();
    return super.close();
  }
}
