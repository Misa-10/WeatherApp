import 'package:intl/intl.dart';


String? formatTime(String? dateTime) {
  if (dateTime == null) return null;
  final parsedDateTime = DateTime.parse(dateTime);
  final formatter = DateFormat.Hm();
  return formatter.format(parsedDateTime);
}
