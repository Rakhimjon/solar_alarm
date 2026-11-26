import 'package:flutter_test/flutter_test.dart';
import 'package:solar_alarm/features/habit/domain/entities/habit.dart';

String key(int y, int m, int d) =>
    '$y-${m.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';

void main() {
  group('Habit streak', () {
    test('daily streak counts consecutive done days ending today', () {
      final habit = Habit(
        id: 'h',
        name: 'daily',
        createdAt: DateTime(2026, 11, 20),
        completedDates: {key(2026, 11, 24), key(2026, 11, 25), key(2026, 11, 26)},
      );
      expect(habit.currentStreak(DateTime(2026, 11, 26)), 3);
    });

    test('open today does not break streak (counts from yesterday)', () {
      final habit = Habit(
        id: 'h',
        name: 'daily',
        createdAt: DateTime(2026, 11, 20),
        completedDates: {key(2026, 11, 24), key(2026, 11, 25)},
      );
      expect(habit.currentStreak(DateTime(2026, 11, 26)), 2);
    });

    test('weekday habit keeps streak over weekend', () {
      final habit = Habit(
        id: 'h',
        name: 'weekdays',
        createdAt: DateTime(2026, 11, 23),
        weekdays: const [1, 2, 3, 4, 5],
        completedDates: {
          key(2026, 11, 23), // Du
          key(2026, 11, 24), // Se
          key(2026, 11, 25), // Chor
          key(2026, 11, 26), // Pay
          key(2026, 11, 27), // Jum
        },
      );
      expect(habit.currentStreak(DateTime(2026, 11, 27)), 5);
      expect(habit.currentStreak(DateTime(2026, 11, 28)), 5); // Shanba
      expect(habit.currentStreak(DateTime(2026, 11, 29)), 5); // Yakshanba
    });

    test('best streak survives a gap', () {
      final habit = Habit(
        id: 'h',
        name: 'daily',
        createdAt: DateTime(2026, 11, 20),
        completedDates: {
          key(2026, 11, 20),
          key(2026, 11, 21),
          key(2026, 11, 22),
          // 23 bo'sh
          key(2026, 11, 24),
          key(2026, 11, 25),
          key(2026, 11, 26),
        },
      );
      expect(habit.bestStreak(DateTime(2026, 11, 26)), 3);
    });

    test('empty habit has zero streak', () {
      final habit = Habit(
        id: 'h',
        name: 'empty',
        createdAt: DateTime(2026, 11, 20),
      );
      expect(habit.currentStreak(DateTime(2026, 11, 26)), 0);
      expect(habit.bestStreak(DateTime(2026, 11, 26)), 0);
    });
  });
}
