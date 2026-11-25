import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/services/kiosk_service.dart';
import 'core/theme/theme_cubit.dart';
import 'features/alarm/data/datasources/alarm_local_storage.dart';
import 'features/alarm/data/repositories/alarm_repository_impl.dart';
import 'features/alarm/domain/repositories/alarm_repository.dart';
import 'features/alarm/presentation/cubit/alarm_cubit.dart';
import 'features/focus_timer/presentation/cubit/focus_timer_cubit.dart';
import 'features/planner/data/datasources/planner_local_datasource.dart';
import 'features/planner/data/repositories/plan_repository_impl.dart';
import 'features/planner/domain/repositories/plan_repository.dart';
import 'features/planner/presentation/cubit/planner_cubit.dart';
import 'core/services/alarm_local_datasource.dart';
import 'features/solar_clock/data/datasources/astronomical_calculator.dart';
import 'features/solar_clock/data/datasources/prayer_times_remote_datasource.dart';
import 'features/solar_clock/data/repositories/solar_clock_repository_impl.dart';
import 'features/solar_clock/domain/repositories/solar_clock_repository.dart';
import 'features/solar_clock/presentation/cubit/solar_clock_cubit.dart';

final sl = GetIt.instance;

Future<void> initDi() async {
  // 1. Core & External Local DB
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);

  final alarmLocalDataSource = AlarmLocalDataSource();
  await alarmLocalDataSource.init();
  sl.registerLazySingleton<AlarmLocalDataSource>(() => alarmLocalDataSource);

  sl.registerLazySingleton<KioskService>(() => KioskService());

  // 2. Data Sources
  sl.registerLazySingleton<AstronomicalCalculator>(
    () => AstronomicalCalculator(),
  );
  sl.registerLazySingleton<PrayerTimesRemoteDataSource>(
    () => PrayerTimesRemoteDataSourceImpl(prefs: sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<PlannerLocalDataSource>(
    () => PlannerLocalDataSource(prefs: sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<AlarmLocalStorage>(
    () => AlarmLocalStorageImpl(
      prefs: sl<SharedPreferences>(),
      solarClockRepository: sl<SolarClockRepository>(),
    ),
  );

  // 3. Repositories
  sl.registerLazySingleton<SolarClockRepository>(
    () => SolarClockRepositoryImpl(
      calculator: sl<AstronomicalCalculator>(),
      remoteDataSource: sl<PrayerTimesRemoteDataSource>(),
      alarmDataSource: sl<AlarmLocalDataSource>(),
    ),
  );
  sl.registerLazySingleton<PlanRepository>(
    () => PlanRepositoryImpl(localDataSource: sl<PlannerLocalDataSource>()),
  );
  sl.registerLazySingleton<AlarmRepository>(
    () => AlarmRepositoryImpl(localStorage: sl<AlarmLocalStorage>()),
  );

  // 4. Cubits
  sl.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(prefs: sl<SharedPreferences>()),
  );
  sl.registerFactory<SolarClockCubit>(
    () => SolarClockCubit(repository: sl<SolarClockRepository>()),
  );
  sl.registerLazySingleton<PlannerCubit>(
    () => PlannerCubit(repository: sl<PlanRepository>()),
  );
  sl.registerFactory<FocusTimerCubit>(
    () => FocusTimerCubit(
      plannerCubit: sl<PlannerCubit>(),
      kioskService: sl<KioskService>(),
    ),
  );
  sl.registerFactory<AlarmCubit>(
    () => AlarmCubit(repository: sl<AlarmRepository>()),
  );
}
