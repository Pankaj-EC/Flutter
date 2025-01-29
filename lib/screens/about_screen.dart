import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  Future<void> _launchURL(BuildContext context) async {
    final Uri url = Uri.parse('https://devamjyot.com');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to open website. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: Colors.green[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
             Image.asset(
                    'assets/company_icon.png',
                    width: 500,
                    height: 100,
                  ),
            // Logo and Company Name Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 253, 253, 253),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color.fromARGB(255, 255, 255, 255)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Transform Your Ideas Into Reality With Our Innovation',
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Information Cards
            _buildInfoCard(
              'About the App',
              'This application helps you monitor and manage your devices efficiently. Track device status, battery levels, and solar readings in real-time.',
              Icons.info_outline,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              'Contact Support',
              'Need help? Contact our support team for assistance.',
              Icons.support_agent,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              'Terms & Privacy',
              'Read our terms of service and privacy policy.',
              Icons.privacy_tip_outlined,
            ),
            const SizedBox(height: 32),

            // Footer Section
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String description, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.green[700], size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Divider(thickness: 1.5),
        const SizedBox(height: 16),
        Builder(
          builder: (context) => InkWell(
            onTap: () => _launchURL(context),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Visit our website',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.open_in_new, color: Colors.blue, size: 18),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '© 2025 Devamjyot Infotech',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
