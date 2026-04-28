import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Terms & Conditions',
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
            _SectionTitle('1. Acceptance of Terms'),
            _SectionBody(
              'By accessing or using the BestSeed application ("App"), you agree to be bound by these Terms and Conditions. If you do not agree to these terms, please do not use the App.',
            ),
            _SectionTitle('2. Use of the Application'),
            _SectionBody(
              'The BestSeed App is intended solely for authorized drivers and employees of BestSeed. You agree to use the App only for its intended purpose — managing and completing deliveries on behalf of BestSeed.\n\n'
              'You must not:\n'
              '• Share your login credentials with any other person.\n'
              '• Use the App for any unlawful or unauthorized purpose.\n'
              '• Attempt to reverse-engineer, copy, or tamper with the App.',
            ),
            _SectionTitle('3. Account Responsibility'),
            _SectionBody(
              'You are responsible for maintaining the confidentiality of your account credentials. You agree to notify BestSeed immediately of any unauthorized use of your account. BestSeed will not be liable for any loss or damage arising from your failure to protect your login information.',
            ),
            _SectionTitle('4. Location Data'),
            _SectionBody(
              'The App collects real-time location data during active delivery sessions to track delivery progress, optimize routes, and ensure accurate delivery records. Location tracking is active only during delivery operations. By using the App, you consent to this location collection.',
            ),
            _SectionTitle('5. Delivery Obligations'),
            _SectionBody(
              'As a driver or employee, you agree to:\n'
              '• Handle all goods with care and responsibility.\n'
              '• Follow all applicable traffic laws and safety regulations.\n'
              '• Report any delivery issues or incidents to your supervisor promptly.\n'
              '• Maintain professional conduct with customers at all times.',
            ),
            _SectionTitle('6. Intellectual Property'),
            _SectionBody(
              'All content, logos, and materials within the App are the property of BestSeed and are protected by applicable intellectual property laws. You may not use, reproduce, or distribute any content from the App without prior written consent from BestSeed.',
            ),
            _SectionTitle('7. Termination'),
            _SectionBody(
              'BestSeed reserves the right to suspend or terminate your access to the App at any time, without notice, for conduct that violates these Terms and Conditions or is harmful to other users, BestSeed, or third parties.',
            ),
            _SectionTitle('8. Limitation of Liability'),
            _SectionBody(
              'BestSeed shall not be liable for any indirect, incidental, or consequential damages arising out of your use of the App. The App is provided "as is" without any warranties of any kind.',
            ),
            _SectionTitle('9. Changes to Terms'),
            _SectionBody(
              'BestSeed reserves the right to modify these Terms and Conditions at any time. Changes will be communicated through the App. Continued use of the App after changes constitutes your acceptance of the updated terms.',
            ),
            _SectionTitle('10. Contact'),
            _SectionBody(
              'If you have any questions about these Terms and Conditions, please contact BestSeed support through the official BestSeed channels.',
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
