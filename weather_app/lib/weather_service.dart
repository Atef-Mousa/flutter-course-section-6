// ============================================================
// STEP 3: THE SERVICE (where the API call happens)
// This class is the ONLY place that talks to the internet.
// The UI never uses Dio directly; it just asks this service.
// ============================================================


//    https://api.open-meteo.com/v1/forecast
//       ?latitude=30.04&longitude=31.24
//       &current=temperature_2m,wind_speed_10m,weather_code
import 'package:dio/dio.dart'; // the Dio package (HTTP client)
import 'weather.dart'; // our model from Step 2

class WeatherService {
  final Dio _dio = Dio(
    BaseOptions(

      baseUrl: 'https://api.open-meteo.com/v1',

      connectTimeout: const Duration(seconds: 10),

      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<Weather> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.get(
        '/forecast',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'current': 'temperature_2m,wind_speed_10m,weather_code',
        },
      );

      return Weather.fromJson(response.data);
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          throw Exception('The server took too long. Try again.');
        case DioExceptionType.connectionError:
          throw Exception('No internet connection.');
        case DioExceptionType.badResponse:
          throw Exception('Server error: ${e.response?.statusCode}');
        default:
          throw Exception('Something went wrong: ${e.message}');
      }
    }
  }
}
