Duration? parseDuration(String str) {
  List<String> parts = str.split(':');
  if (parts.length != 3) {
    return null;
  }

  int hours = int.parse(parts[0]);
  int minutes = int.parse(parts[1]);

  List<String> secondParts = parts[2].split('.');
  if (secondParts.length != 2) {
    return null;
  }

  int seconds = int.parse(secondParts[0]);
  int microseconds = int.parse(secondParts[1]);

  return Duration(
    hours: hours,
    minutes: minutes,
    seconds: seconds,
    microseconds: microseconds,
  );
}
