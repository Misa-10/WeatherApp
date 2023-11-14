// ignore_for_file: file_names

import 'package:flutter/material.dart';
import '../Backend/api_calls.dart';
import '../custom_functions.dart';

class CurrentWeather extends StatelessWidget {
  const CurrentWeather({super.key});

  Future<Map<String, dynamic>> _fetchWeatherCurrentData() async {
    try {
      final weatherData = await ApiCalls.getWeatherCurrent();
      return weatherData;
    } catch (e) {
      debugPrint('Error fetching weather data: $e');
      return {};
    }
  }

  Future<String> _fetchCityName() async {
    try {
      final cityName = await ApiCalls.getNameCity();
      return cityName;
    } catch (e) {
      debugPrint('Error fetching city name: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<String>(
          future: _fetchCityName(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text('Error fetching city name');
            } else {
              final cityName = snapshot.data;
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    '$cityName',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }
          },
        ),
        const SizedBox(height: 16),
        FutureBuilder<Map<String, dynamic>>(
          future: _fetchWeatherCurrentData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text('Error fetching city name');
            } else {
              final weatherData = snapshot.data;
              final currentTemp =
                  weatherData?['current_weather']['temperature'] ?? '';
              final currentWcode =
                  weatherData?['current_weather']['weathercode'] ?? '';

              String imageAsset;
              if (currentWcode == 0) {
                imageAsset = 'assets/images/sun.png';
              } else if (currentWcode >= 1 && currentWcode <= 3) {
                imageAsset = 'assets/images/cloudy.png';
              } else if (currentWcode >= 45 && currentWcode <= 48) {
                imageAsset = 'assets/images/fog.png';
              } else if (currentWcode >= 51 && currentWcode <= 57) {
                imageAsset = 'assets/images/drizzle.png';
              } else if (currentWcode >= 61 && currentWcode <= 67 ||
                  currentWcode >= 80 && currentWcode <= 82) {
                imageAsset = 'assets/images/rain.png';
              } else if (currentWcode >= 71 && currentWcode <= 77 ||
                  currentWcode >= 85 && currentWcode <= 86) {
                imageAsset = 'assets/images/snowing.png';
              } else if (currentWcode >= 95) {
                imageAsset = 'assets/images/lightning-bolt.png';
              } else {
                imageAsset = 'assets/images/default.png';
              }

              return Column(
                children: [
                  Text(
                    '$currentTemp°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Image.asset(
                    imageAsset,
                    width: 80,
                    height: 80,
                  ),
                ],
              );
            }
          },
        ),
        const SizedBox(height: 16),
        FutureBuilder<Map<String, dynamic>>(
          future: _fetchWeatherCurrentData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text('Error fetching city name');
            } else {
              final weatherData = snapshot.data;
              final tempMax =
                  weatherData?['daily']['temperature_2m_max'][0] ?? '';
              final tempMin =
                  weatherData?['daily']['temperature_2m_min'][0] ?? '';

              const arrowUp =
                  'assets/images/up-arrow.png'; // Replace with the actual image asset
              const arrowDown =
                  'assets/images/down-arrow.png'; // Replace with the actual image asset

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Image.asset(
                        arrowUp,
                        width: 15,
                        height: 15,
                      ),
                      Text(
                        '$tempMax°',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Image.asset(
                        arrowDown,
                        width: 15,
                        height: 15,
                      ),
                      Text(
                        '$tempMin°',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
          },
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset(
              'assets/images/sunrise.png',
              width: 30,
              height: 30,
            ),
            Image.asset(
              'assets/images/sunset.png',
              width: 30,
              height: 30,
            ),
          ],
        ),
        const SizedBox(height: 8),
        FutureBuilder<Map<String, dynamic>>(
          future: _fetchWeatherCurrentData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text('Error fetching city name');
            } else {
              final weatherData = snapshot.data;
              final sunrise = weatherData?['daily']['sunrise'][0] ?? '';
              final sunset = weatherData?['daily']['sunset'][0] ?? '';
              final sunriseTime = formatTime(sunrise);
              final sunsetTime = formatTime(sunset);

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'Sunrise: $sunriseTime',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Sunset: $sunsetTime',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }
}
