// ignore_for_file: file_names

import 'package:flutter/material.dart';
import '../Backend/api_calls.dart';

class UV extends StatelessWidget {
  const UV({super.key});

  

  Future<Map<String, dynamic>> _fetchWeatherCurrentData() async {
    try {
      final weatherData = await ApiCalls.getWeatherCurrent();
      return weatherData;
    } catch (e) {
      debugPrint('Error fetching weather data: $e');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<Map<String, dynamic>>(
        future: _fetchWeatherCurrentData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return const Text('Error fetching city name');
          } else {
            final weatherData = snapshot.data;
            final uv = weatherData?['daily']['uv_index_max'][0] ?? '';

            String imageUV = '';
            if (uv >= 4) {
              imageUV = 'assets/images/sunscreen.png';
            } else if (uv <= 3) {
              imageUV = 'assets/images/sunscreen-transparent.png';
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/uv.png',
                      width: 50,
                      height: 50,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$uv',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Image.asset(
                      imageUV, // Replace with the actual image asset path
                      width: 40,
                      height: 40,
                    ),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
