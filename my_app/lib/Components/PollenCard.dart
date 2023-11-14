// ignore_for_file: file_names

import 'package:flutter/material.dart';
import '../Backend/api_calls.dart';

class PollenCard extends StatelessWidget {
  const PollenCard({Key? key}) : super(key: key);

  Future<Map<String, dynamic>> _fetchPollen() async {
    try {
      final pollenData = await ApiCalls.getPollen();
      return pollenData;
    } catch (e) {
      debugPrint('Error fetching airQuality data: $e');
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
        future: _fetchPollen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return const Text('Error fetching air quality data');
          } else {
            final pollenData = snapshot.data;

            DateTime now = DateTime.now();
            int currentHour = now.hour;

            final alderPollen =
                (pollenData?['hourly']['alder_pollen'][currentHour] ?? 0.0).toString();
            final birchPollen =
                (pollenData?['hourly']['birch_pollen'][currentHour] ?? 0.0).toString();
            final grassPollen =
                (pollenData?['hourly']['grass_pollen'][currentHour] ?? 0.0).toString();

            final mugwortPollen =
                (pollenData?['hourly']['mugwort_pollen'][currentHour] ?? 0.0).toString();

            final olivePollen =
                (pollenData?['hourly']['olive_pollen'][currentHour] ?? 0.0).toString();

            final ragweedPollen =
                (pollenData?['hourly']['ragweed_pollen'][currentHour] ?? 0.0).toString();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/pollen.png',
                          width: 50,
                          height: 50,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Pollen",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _buildPollenColumn(
                        label: 'Aulne',
                        value: alderPollen,
                      ),
                    ),
                    Expanded(
                      child: _buildPollenColumn(
                        label: 'Bouleau',
                        value: birchPollen,
                      ),
                    ),
                    Expanded(
                      child: _buildPollenColumn(
                        label: 'Graminées',
                        value: grassPollen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _buildPollenColumn(
                        label: 'Armoise',
                        value: mugwortPollen,
                      ),
                    ),
                    Expanded(
                      child: _buildPollenColumn(
                        label: 'Olivier',
                        value: olivePollen,
                      ),
                    ),
                    Expanded(
                      child: _buildPollenColumn(
                        label: 'Ambroisie',
                        value: ragweedPollen,
                      ),
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

  Column _buildPollenColumn({required String label, required String value}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
