import 'package:flutter/material.dart';
import 'package:my_app/Components/AirQualityCard.dart';
import 'package:my_app/Components/CurrentWeather.dart';
import 'package:my_app/Components/DailyWeatherCard.dart';
import 'package:my_app/Components/PollenCard.dart';
import 'package:my_app/Components/UV.dart';
import 'dart:core';
import 'package:geolocator/geolocator.dart';
import 'package:sqflite/sqflite.dart';
import './Backend/Database.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'Backend/api_calls.dart';
import 'contacts_page.dart';
import 'package:sensors/sensors.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Geolocator.requestPermission();
  // Fetch air quality data
  Map<String, dynamic> airQualityData = await ApiCalls.getQualityAir();

  // Initialize the FlutterLocalNotificationsPlugin
  await initializeNotifications();

  runApp(
    MaterialApp(
      title: 'Health App',
      theme: ThemeData(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
      ),
      // Start the app with the "/" named route. In this case, the app starts
      // on the FirstScreen widget.
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => HomePage(airQualityData: airQualityData),
        // When navigating to the "/contact" route, build the ContactsPage widget.
        '/contact': (context) => const ContactsPage(),
      },
    ),
  );
}

Future<void> initializeNotifications() async {
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();

  const InitializationSettings initializationSettings = InitializationSettings(
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

class HomePage extends StatefulWidget {
  final PageController _pageController = PageController();
  final Map<String, dynamic> airQualityData;

  HomePage({Key? key, required this.airQualityData}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AccelerometerEvent? _accelerometerData;
  int _activityCounter = 0;
  int _timeNotification = 0;
 

  @override
  void initState() {
    super.initState();
    _accelerometerData =
        AccelerometerEvent(0, 0, 0); // Initialize with default values
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerData = event;
        DateTime now = DateTime.now();
        int currentHour = now.hour;
            final pm25 = widget.airQualityData?['hourly']['european_aqi_pm2_5'][currentHour] ?? '';
            final pm10 = widget.airQualityData?['hourly']['european_aqi_pm10'][currentHour] ?? '';
            final saharaDust = widget.airQualityData?['hourly']['dust'][currentHour] ?? '';

            if (_timeNotification != currentHour && _timeNotification != 0 ) {
              _activityCounter = 0;
              _isNotificationScheduled = false;
            }
  
        // print(isSportsActivity);
        if (isSportsActivity == true) {
          _activityCounter++;
          if (_activityCounter >= 40 && _isNotificationScheduled == false)  { // demo if
          // if (_activityCounter >= 40 && _isNotificationScheduled == false && (pm25 > 50 || pm10 > 50 || saharaDust > 50)) {
            _scheduleNotification();
            print("notification scheduled");
            _isNotificationScheduled = true;
            _timeNotification = currentHour;
          } else {}
        } else {}
      });
    });
  }

  void _sendSMS(String message, List<String> recipients) async {
    String result = await sendSMS(message: message, recipients: recipients)
        .catchError((onError) {
      print(onError);
    });
    print(result);
  }

  Future<List<MyContact>> getContactsFromDatabase() async {
    Database db = await DatabaseHelper().database;
    List<Map<String, dynamic>> maps = await db.query('contact');
    return List.generate(
        maps.length, (index) => MyContact.fromMap(maps[index]));
  }

  bool get isSportsActivity =>
      _accelerometerData!.x.abs() > 10 ||
      _accelerometerData!.y.abs() > 10 ||
      _accelerometerData!.z.abs() > 10;

  bool _isNotificationScheduled = false;

  void _scheduleNotification() async {
    print(isSportsActivity);
    const DarwinNotificationDetails iosPlatformChannelSpecifics =
        DarwinNotificationDetails();
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(iOS: iosPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'Alerte', 'Ralentissez votre exercise la pollution est élevée.', platformChannelSpecifics,
        payload: 'item x');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: PageView(
          controller: widget._pageController,
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          children: const [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    SizedBox(height: 16),
                    CurrentWeather(),
                    SizedBox(height: 16),
                    UV(),
                    SizedBox(height: 16),
                    AirQualityCard(),
                  ],
                ),
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    SizedBox(height: 16),
                    PollenCard(),
                    SizedBox(height: 16),
                    DailyWeatherCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF1C1C1E),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Image.asset('assets/images/mail.png'),
                  onPressed: () async {
                    String message = "Weather Alert!";
                    List<MyContact> contacts = await getContactsFromDatabase();
                    List<String> recipients =
                        contacts.map((contact) => contact.phone).toList();
                    _sendSMS(message, recipients);
                  },
                ),
                const Text(
                  'Send Alert',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Image.asset('assets/images/settings.png'),
                  onPressed: () {
                    Navigator.pushNamed(context, '/contact');
                  },
                ),
                const Text(
                  'Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
