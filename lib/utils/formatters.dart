class MessageFormatter {
  String formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate =
        DateTime(timestamp.year, timestamp.month, timestamp.day);

    String period = timestamp.hour >= 12 ? 'PM' : 'AM';
    int hour12 = timestamp.hour > 12 ? timestamp.hour - 12 : timestamp.hour;
    hour12 = hour12 == 0 ? 12 : hour12;

    if (messageDate == today) {
      return 'Today at $hour12:${timestamp.minute.toString().padLeft(2, '0')} $period';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday at $hour12:${timestamp.minute.toString().padLeft(2, '0')} $period';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year} $hour12:${timestamp.minute.toString().padLeft(2, '0')} $period';
    }
  }

  String formatGenerationTime(Duration duration) {
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds}s';
    } else {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    }
  }
}
