// ignore_for_file: file_names

import 'package:flutter/material.dart';
import '../Backend/api_calls.dart';

class AirQualityCard extends StatelessWidget {
  const AirQualityCard({super.key});

  Future<Map<String, dynamic>> _fetchAirQuality() async {
    try {
      final airQualityData = await ApiCalls.getQualityAir();
      return airQualityData;
    } catch (e) {
      debugPrint('Error fetching air quality data: $e');
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
        future: _fetchAirQuality(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return const Text('Error fetching air quality data');
          } else {
            final airQualityData = snapshot.data;

            DateTime now = DateTime.now();
            int currentHour = now.hour;

            final pm25 = airQualityData?['hourly']['european_aqi_pm2_5'][currentHour] ?? '';
            final pm10 = airQualityData?['hourly']['european_aqi_pm10'][currentHour] ?? '';
            final saharaDust = airQualityData?['hourly']['dust'][currentHour] ?? '';

            Color colorPm25 = Colors.white;
            Color colorPm10 = Colors.white;
            Color colorSahara = Colors.white;

            if (pm25 <= 20) {
              colorPm25 = Colors.green;
            } else if (pm25 <= 25) {
              colorPm25 = Colors.yellow;
            } else if (pm25 <= 50) {
              colorPm25 = Colors.orange;
            } else if (pm25 <= 75) {
              colorPm25 = Colors.red.shade400;
            } else if (pm25 > 75) {
              colorPm25 = Colors.redAccent.shade400;
            }

            if (pm10 <= 40) {
              colorPm10 = Colors.green;
            } else if (pm10 <= 50) {
              colorPm10 = Colors.yellow;
            } else if (pm10 <= 100) {
              colorPm10 = Colors.orange;
            } else if (pm10 <= 150) {
              colorPm10 = Colors.red.shade400;
            } else if (pm10 > 150) {
              colorPm10 = Colors.redAccent.shade400;
            }

            if (saharaDust < 10) {
              colorSahara = Colors.green;
            } else if (saharaDust < 30) {
              colorSahara = Colors.yellow;
            } else if (saharaDust < 50) {
              colorSahara = Colors.orange;
            } else if (saharaDust < 70) {
              colorSahara = Colors.red.shade400;
            } else {
              colorSahara = Colors.redAccent.shade400;
            }

            String maskImage = '';
            if (pm25 > 25 || pm10 > 50 || saharaDust > 30) {
              maskImage = 'assets/images/mask.png';
            } else {
              maskImage = 'assets/images/mask-transparent.png';
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/atmospheric-pollution.png',
                          width: 50,
                          height: 50,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Qualité de l'air",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Image.asset(
                      maskImage,
                      width: 30,
                      height: 30,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAirQualityColumn('PM2.5', '$pm25', colorPm25),
                    _buildAirQualityColumn('PM10', '$pm10', colorPm10),
                    _buildAirQualityColumn('Poussière du Sahara', '$saharaDust', colorSahara),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildAirQualityColumn(String title, String value, Color color) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
