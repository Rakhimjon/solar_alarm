import 'package:get_it/get_it.dart';
import 'features/solar_alarm/data/datasources/alarm_local_datasource.dart';
import 'features/solar_alarm/data/datasources/solar_calculator_datasource.dart';
import 'features/solar_alarm/data/repositories/solar_alarm_repository_impl.dart';
import 'features/solar_alarm/domain/repositories/solar_alarm_repository.dart';
import 'features/solar_alarm/presentation/cubit/solar_alarm_cubit.dart';

final sl = GetIt.instance;

Future<void> initDi() async {
  // Data Sources
  final alarmDataSource = AlarmLocalDataSource();
  await alarmDataSource.init();
  sl.registerLazySingleton<AlarmLocalDataSource>(() => alarmDataSource);

  sl.registerLazySingleton<SolarCalculatorDataSource>(
    () => SolarCalculatorDataSource(),
  );

  // Repositories
  sl.registerLazySingleton<SolarAlarmRepository>(
    () => SolarAlarmRepositoryImpl(
      calculatorDataSource: sl<SolarCalculatorDataSource>(),
      alarmDataSource: sl<AlarmLocalDataSource>(),
    ),
  );

  // Cubits
  sl.registerFactory<SolarAlarmCubit>(
    () => SolarAlarmCubit(repository: sl<SolarAlarmRepository>()),
  );
}
