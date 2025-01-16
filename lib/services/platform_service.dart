import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' as io;

class PlatformService {
  static bool get isWeb => kIsWeb;
  static bool get isDesktop {
    if (kIsWeb) return false;
    return io.Platform.isWindows || io.Platform.isMacOS || io.Platform.isLinux;
  }

  static bool get isMobile {
    if (kIsWeb) return false;
    return io.Platform.isAndroid || io.Platform.isIOS;
  }

  static String getBaseUrl() {
    if (isWeb) {
      // For web, use a proxy server or cloud-hosted Ollama instance
      // Don't forget to update!!!

      return 'https://your-ollama-proxy.com';
    } else if (!isWeb && io.Platform.isAndroid) {
      return 'http://10.0.2.2:11434';
    } else {
      return 'http://localhost:11434';
    }
  }
}
