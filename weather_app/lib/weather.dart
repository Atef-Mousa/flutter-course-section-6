
class Weather {
  final double temperature;
  final double windSpeed;
  final int weatherCode;
  final String time;
  Weather({
    required this.temperature,
    required this.windSpeed,
    required this.weatherCode,
    required this.time,
  });

  static  Weather fromJson(Map<String, dynamic> json) {
    final current = json['current'];

    return Weather(
      temperature: (current['temperature_2m'] as num).toDouble(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      weatherCode: current['weather_code'] as int,
      time: current['time'] as String,
    );
  }

  String get description => switch (weatherCode) {
        0 => 'Clear sky ',
        1 || 2 || 3 => 'Partly cloudy',
        45 || 48 => 'Fog ',
        >= 51 && <= 67 => 'Rain ',
        >= 71 && <= 77 => 'Snow ',
        >= 80 && <= 82 => 'Rain showers ',
        >= 95 => 'Thunderstorm',
        _ => 'Unknown',
      };
}
