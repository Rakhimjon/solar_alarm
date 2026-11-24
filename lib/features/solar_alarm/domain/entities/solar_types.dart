enum SolarEvent { sunrise, sunset }

class SolarTimes {
  final DateTime sunrise;
  final DateTime sunset;

  const SolarTimes({
    required this.sunrise,
    required this.sunset,
  });
}
