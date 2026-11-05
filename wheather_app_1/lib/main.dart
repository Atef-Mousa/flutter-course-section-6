// ============================================================
// STEP 4: THE UI
// A simple screen: pick a city, press a button, see the weather.
// It shows 3 states every API app needs: loading, error, success.
// ============================================================
import 'package:flutter/material.dart';
import 'weather.dart';
import 'weather_service.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather with Dio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const WeatherScreen(),
    );
  }
}
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _service = WeatherService();
  final Map<String, List<double>> _cities = {
    'Cairo': [30.04, 31.24],
    'Alexandria': [31.20, 29.92],
    'London': [51.51, -0.13],
    'Tokyo': [35.68, 139.69],
  };

  String _selectedCity = 'Cairo';

  Weather? _weather;
  bool _isLoading = false;
  String? _error;

  Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final coords = _cities[_selectedCity]!;

      final weather = await _service.getCurrentWeather(
        latitude: coords[0],
        longitude: coords[1],
      );

      setState(() => _weather = weather);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather with Dio')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _selectedCity,
              isExpanded: true,
              items: _cities.keys
                  .map((city) => DropdownMenuItem(value: city, child: Text(city)))
                  .toList(),
              onChanged: (city) => setState(() => _selectedCity = city!),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _isLoading ? null : _fetchWeather,
              icon: const Icon(Icons.cloud_download),
              label: const Text('Get weather'),
            ),
            const SizedBox(height: 32),

            Expanded(child: Center(child: _buildResult())),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    if (_isLoading) {
      return const CircularProgressIndicator();
    }
    if (_error != null) {
      return Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 16));
    }
    if (_weather == null) {
      return const Text('Pick a city and press the button.');
    }

    final w = _weather!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_selectedCity, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 8),
        Text(
          '${w.temperature.toStringAsFixed(1)}°C',
          style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold),
        ),
        Text(w.description, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 8),
        Text('Wind: ${w.windSpeed} km/h'),
        Text('Updated: ${w.time}', style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
