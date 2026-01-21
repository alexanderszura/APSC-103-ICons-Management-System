abstract class TimeHelper {

  static String shorten(DateTime t) => "${t.year}-${t.month}-${t.day} ${t.hour}:${t.minute}";
  
  static DateTime fromString(String time) {
    // "2026-01-20 16:48:02.522"
    int year, month, day, hour, minute;

    var times = time.split("-");
    year = int.tryParse(times[0]) ?? -1;
    month = int.tryParse(times[1]) ?? -1;

    String buffer = times[2];

    //20 16:48:02.522
    day = int.tryParse(buffer.substring(0, buffer.indexOf(' '))) ?? -1;

    buffer = buffer.substring(buffer.indexOf(' '));
    times = buffer.split(":");

    hour = int.tryParse(times[0]) ?? -1;
    minute = int.tryParse(times[1]) ?? -1;

    if (!_passCheck([year, month, day, hour, minute])) {
      throw ArgumentError("Illegal String input in TimeHelper.fromString");
    }

    return DateTime(
      year,
      month,
      day,
      hour,
      minute
    );
  }

  static bool _passCheck(List<int> args) {
    for (int value in args) {
      if (value == -1) {
        return false;
      }
    }

    return true;
  }
}