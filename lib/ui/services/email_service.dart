import 'package:url_launcher/url_launcher.dart';

class EmailService {
  Future<void> openEmail(String subject, String body) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: '', // leave empty for user to enter recipient
      query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );

    if (!await launchUrl(emailLaunchUri)) {
      throw 'Could not launch email client';
    }
  }
}

