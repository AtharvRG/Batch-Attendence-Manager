import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import for Provider definition

// Service class to handle launching external URLs, particularly WhatsApp.
class UrlLauncherService {

  // Launches the WhatsApp chat interface with a pre-filled message.
  Future<bool> launchWhatsApp(String phoneNumber, String message) async {
    // Basic cleaning: remove common formatting characters but keep leading '+' if present
    String cleanedPhone = phoneNumber.replaceAll(RegExp(r'[\s()-]'), '');

    // Encode the message text to be URL-safe
    final encodedMessage = Uri.encodeComponent(message);

    // Construct the wa.me URL. Using https is standard.
    final url = Uri.parse('https://wa.me/$cleanedPhone?text=$encodedMessage');

    print("--- UrlLauncherService: Attempting to launch WhatsApp URL: $url");

    // Check if the operating system can handle this URL scheme.
    if (await canLaunchUrl(url)) {
      try {
        // Attempt to launch the URL, requesting it open in an external application
        // (i.e., the WhatsApp app itself, not an in-app browser).
        final bool launched = await launchUrl(url, mode: LaunchMode.externalApplication);

        if (!launched) {
          // This case might occur on some platforms or configurations
          print("--- UrlLauncherService: launchUrl returned false for WhatsApp URL: $url");
          return false;
        }
        print("--- UrlLauncherService: WhatsApp URL launched successfully.");
        return true; // Launch successful
      } catch (e) {
        // Catch any exceptions thrown during the launch process.
        print("--- UrlLauncherService: ERROR launching WhatsApp URL $url: $e");
        return false; // Indicate failure
      }
    } else {
      // If the OS reports it cannot launch the URL (e.g., WhatsApp not installed).
      print("--- UrlLauncherService: Cannot launch WhatsApp URL (canLaunchUrl=false): $url");
      return false; // Indicate failure
    }
  }

  // Launches a generic URL (like http/https) using the platform's default handler.
  Future<bool> launchGenericUrl(String urlString) async {
    // Try to parse the string into a Uri object.
    final Uri? url = Uri.tryParse(urlString);
    if (url == null) {
      print("--- UrlLauncherService: Could not launch generic URL: Invalid format - '$urlString'");
      return false; // Invalid URL format
    }

    print("--- UrlLauncherService: Attempting to launch generic URL: $url");

    // Check if the URL can be launched.
    if (await canLaunchUrl(url)) {
      try {
        // Launch using the default mode (usually opens web browser for http/https).
        final bool launched = await launchUrl(url, mode: LaunchMode.platformDefault);
        if (!launched) {
          print("--- UrlLauncherService: launchUrl returned false for generic URL: $url");
          return false;
        }
        print("--- UrlLauncherService: Generic URL launched successfully.");
        return true; // Success
      } catch (e) {
        print("--- UrlLauncherService: ERROR launching generic URL $url: $e");
        return false; // Failure
      }
    } else {
      print("--- UrlLauncherService: Cannot launch generic URL (canLaunchUrl=false): $url");
      return false; // Cannot launch
    }
  }
}

// Riverpod Provider for easy access/mocking of the UrlLauncherService.
final urlLauncherServiceProvider = Provider<UrlLauncherService>((ref) {
  // Simply return a new instance of the service.
  return UrlLauncherService();
});