class StreamService {
  static Stream<String> simulateStream(String text, {int delayMs = 70}) async* {
    final words = text.split(' ');
    String buffer = '';

    for (final word in words) {
      buffer += (buffer.isEmpty ? '' : ' ') + word;
      await Future.delayed(Duration(milliseconds: delayMs));
      yield buffer;
    }
  }
}
