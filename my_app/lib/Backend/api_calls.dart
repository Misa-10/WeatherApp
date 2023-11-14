import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class ApiCalls {
  static const String baseUrl = 'https://api.open-meteo.com/v1';
  static const String reverseGeocodeUrl =
      'https://api.bigdatacloud.net/data/reverse-geocode-client';
  static const String baseAirUrl = 'https://air-quality-api.open-meteo.com/v1';

  static double longitude = 2.333333;
  static double latitude = 48.866667;

  static Future<void> getCurrentLocation() async {
    await Geolocator.requestPermission();
    final Position position = await Geolocator.getCurrentPosition();
    longitude = position.longitude;
    latitude = position.latitude;
  }

  static Future<Map<String, dynamic>> getWeatherCurrent() async {
     if (longitude == 2.333333 || latitude == 48.866667) {
      await getCurrentLocation();
    }
    final String url = '$baseUrl/forecast?'
        'daily=temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max&'
        'forecast_days=1&timezone=auto&current_weather=True&'
        'longitude=$longitude&latitude=$latitude';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      return data;
    } else {
      throw Exception('Failed to fetch weather data');
    }
  }

  static Future<Map<String, dynamic>> getWeatherDaily() async {
     if (longitude == 2.333333 || latitude == 48.866667) {
      await getCurrentLocation();
    }
    final String url = '$baseUrl/forecast?'
        'daily=weathercode,temperature_2m_max,temperature_2m_min&'
        'timezone=auto&'
        'longitude=$longitude&latitude=$latitude';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      return data;
    } else {
      throw Exception('Failed to fetch weather data');
    }
  }

  static Future<String> getNameCity() async {
    if (longitude == 2.333333 || latitude == 48.866667) {
      await getCurrentLocation();
    }
    final String url =
        '$reverseGeocodeUrl?latitude=$latitude&longitude=$longitude';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final String cityName = data['city'];
      return cityName;
    } else {
      throw Exception('Failed to fetch city name');
    }
  }

  static Future<Map<String, dynamic>> getQualityAir() async {
     if (longitude == 2.333333 || latitude == 48.866667) {
      await getCurrentLocation();
    }
    final String url = '$baseAirUrl/air-quality?'
        'hourly=dust,european_aqi_pm2_5,european_aqi_pm10&'
        'longitude=$longitude&latitude=$latitude';
    
    final response = await http.get(Uri.parse(url));
      
    if (response.statusCode == 200) {
      
      final Map<String, dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to fetch air quality data');
    }
  }

  static Future<Map<String, dynamic>> getPollen() async {
     if (longitude == 2.333333 || latitude == 48.866667) {
      await getCurrentLocation();
    }
    final String url = '$baseAirUrl/air-quality?'
        'hourly=alder_pollen,birch_pollen,grass_pollen,mugwort_pollen,olive_pollen,ragweed_pollen&'
        'longitude=$longitude&latitude=$latitude';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to fetch Pollen data');
    }
  }

  // Add more API calls here...
}
