// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Import the date symbol initialization

import '../Backend/api_calls.dart';

class DailyWeatherCard extends StatelessWidget {
  const DailyWeatherCard({super.key});

 

  Future<Map<String, dynamic>> _fetchWeatherDailyData() async {
    try {
      final weatherData = await ApiCalls.getWeatherDaily();
      return weatherData;
    } catch (e) {
      debugPrint('Error fetching weather data: $e');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting(); // Initialize the date symbols

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          FutureBuilder<Map<String, dynamic>>(
            future: _fetchWeatherDailyData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return const Text('Error fetching weather data');
              } else {
                final weatherData = snapshot.data;
                final dailyData = weatherData?['daily'];

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: dailyData?['time']?.length ?? 0,
                  itemBuilder: (context, index) {
                    final dailyWcode = dailyData?['weathercode']?[index]?.toString() ?? '';
                    final tempMax = dailyData?['temperature_2m_max']?[index]?.toString() ?? '';
                    final tempMin = dailyData?['temperature_2m_min']?[index]?.toString() ?? '';
                    final date = dailyData?['time']?[index]?.toString() ?? '';

                    String imageAsset;
                    if (dailyWcode == '0') {
                      imageAsset = 'assets/images/sun.png';
                    } else if (dailyWcode == '1' || dailyWcode == '2' || dailyWcode == '3') {
                      imageAsset = 'assets/images/cloudy.png';
                    } else if (dailyWcode == '45' || dailyWcode == '46' || dailyWcode == '47' || dailyWcode == '48') {
                      imageAsset = 'assets/images/fog.png';
                    } else if (dailyWcode == '51' || dailyWcode == '52' || dailyWcode == '53' || dailyWcode == '54' || dailyWcode == '55' || dailyWcode == '56' || dailyWcode == '57') {
                      imageAsset = 'assets/images/drizzle.png';
                    } else if ((dailyWcode == '61' || dailyWcode == '62' || dailyWcode == '63' || dailyWcode == '64' || dailyWcode == '65' || dailyWcode == '66' || dailyWcode == '67') ||
                        (dailyWcode == '80' || dailyWcode == '81' || dailyWcode == '82')) {
                      imageAsset = 'assets/images/rain.png';
                    } else if ((dailyWcode == '71' || dailyWcode == '72' || dailyWcode == '73' || dailyWcode == '74' || dailyWcode == '75' || dailyWcode == '76' || dailyWcode == '77') ||
                        (dailyWcode == '85' || dailyWcode == '86')) {
                      imageAsset = 'assets/images/snowing.png';
                    } else if (dailyWcode == '95') {
                      imageAsset = 'assets/images/lightning-bolt.png';
                    } else {
                      imageAsset = 'assets/images/default.png';
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1E),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDate(date), // Format date to French version
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          '$tempMax°C',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.arrow_upward,
                                          color: Colors.white,
                                          size: 12,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          '$tempMin°C',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.arrow_downward,
                                          color: Colors.white,
                                          size: 12,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Image.asset(
                                  imageAsset,
                                  width: 30,
                                  height: 30,
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    final dateToFormat = DateTime.parse(date);
    final formattedDate = DateFormat.yMMMMEEEEd('fr_FR').format(dateToFormat);
    return formattedDate;
  }
}
