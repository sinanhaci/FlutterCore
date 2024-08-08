/// [int] EXTENSION
extension IntExtension on int {
  /// Converts to duration object to microseconds of value
  Duration get microseconds => Duration(microseconds: this);

  /// Converts to duration object to milliseconds of value
  Duration get milliseconds => Duration(milliseconds: this);

  /// Converts to duration object to seconds of value
  Duration get seconds => Duration(seconds: this);

  /// Converts to duration object to minutes of value
  Duration get minutes => Duration(minutes: this);

  /// Converts to duration object to hours of value
  Duration get hours => Duration(hours: this);

  /// Converts to duration object to days of value
  Duration get days => Duration(days: this);

  /// Converts to kiloBytes
  int get kiloBytes => this * 1024;

  /// Converts to megaBytes
  int get megaBytes => this * 1024 * 1024;

  /// Converts to gigaBytes
  int get gigaBytes => this * 1024 * 1024 * 1024;
}
