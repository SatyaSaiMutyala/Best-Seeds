import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF0077C8),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('1. Introduction'),
            _SectionBody(
              'BestSeed ("we", "us", or "our") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your personal information when you use the BestSeed App.',
            ),
            _SectionTitle('2. Information We Collect'),
            _SectionBody(
              'We collect the following types of information:\n\n'
              'a) Account Information\n'
              '   • Mobile number (for drivers)\n'
              '   • Employee ID and password (for employees/vendors)\n'
              '   • Name and profile details\n\n'
              'b) Location Information\n'
              '   • Real-time GPS location during active delivery sessions\n'
              '   • Location history linked to completed deliveries\n\n'
              'c) Device Information\n'
              '   • Device model and OS version\n'
              '   • FCM token for push notifications\n\n'
              'd) Usage Information\n'
              '   • Delivery activity logs\n'
              '   • App interaction data for performance improvement',
            ),
            _SectionTitle('3. How We Use Your Information'),
            _SectionBody(
              'We use the collected information to:\n'
              '• Authenticate and manage your account.\n'
              '• Track and coordinate delivery operations.\n'
              '• Send push notifications for delivery updates and alerts.\n'
              '• Improve app performance and user experience.\n'
              '• Comply with legal and regulatory requirements.\n'
              '• Generate delivery reports and analytics.',
            ),
            _SectionTitle('4. Location Data'),
            _SectionBody(
              'Location data is collected in the background during active delivery sessions to:\n'
              '• Enable real-time tracking for dispatch and customers.\n'
              '• Verify delivery routes and completion.\n'
              '• Calculate distance and optimize routes.\n\n'
              'Location tracking stops when you end a delivery session or log out. We do not track your location outside of active delivery sessions.',
            ),
            _SectionTitle('5. Data Sharing'),
            _SectionBody(
              'We do not sell your personal information to third parties. We may share your information with:\n'
              '• BestSeed internal teams for operational purposes.\n'
              '• Service providers who assist in operating the App (e.g., Firebase for authentication and notifications).\n'
              '• Law enforcement or regulators when required by law.',
            ),
            _SectionTitle('6. Data Retention'),
            _SectionBody(
              'We retain your personal data for as long as your account is active or as needed to provide services. Delivery records and logs may be retained for up to 3 years for business and compliance purposes. You may request deletion of your data by contacting BestSeed support.',
            ),
            _SectionTitle('7. Data Security'),
            _SectionBody(
              'We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. All data is transmitted over secure encrypted connections.',
            ),
            _SectionTitle('8. Your Rights'),
            _SectionBody(
              'You have the right to:\n'
              '• Access the personal data we hold about you.\n'
              '• Request correction of inaccurate data.\n'
              '• Request deletion of your data (subject to legal obligations).\n'
              '• Withdraw consent for location tracking (note: this may affect your ability to use delivery features).\n\n'
              'To exercise these rights, please contact BestSeed support.',
            ),
            _SectionTitle('9. Third-Party Services'),
            _SectionBody(
              'The App uses third-party services including Firebase (Google) for authentication, push notifications, and data storage. These services have their own privacy policies that govern their data handling practices.',
            ),
            _SectionTitle('10. Changes to This Policy'),
            _SectionBody(
              'We may update this Privacy Policy from time to time. We will notify you of significant changes through the App. Continued use of the App after changes constitutes your acceptance of the updated policy.',
            ),
            _SectionTitle('11. Contact Us'),
            _SectionBody(
              'If you have any questions or concerns about this Privacy Policy or our data practices, please contact BestSeed through the official support channels.',
            ),
            SizedBox(height: 32),
            Center(
              child: Text(
                'Last updated: April 2026',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0077C8),
        ),
      ),
    );
  }
}

class _SectionBody extends StatelessWidget {
  final String text;
  const _SectionBody(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black87,
        height: 1.6,
      ),
    );
  }
}
