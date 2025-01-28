import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _baseUrl = "https://solar-iot-be.vercel.app"; // Default base URL
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBaseUrl();
  }

  // Load saved base URL from shared preferences
  Future<void> _loadBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _baseUrl = prefs.getString('base_url') ?? _baseUrl;
      _controller.text = _baseUrl; // Set initial value for TextField
    });
  }

Future<void> _saveBaseUrl() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('base_url', _controller.text);

  setState(() {
    _baseUrl = _controller.text;
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Base URL updated successfully! app will restart in 2 seconds')),
  );

  // Delay for the SnackBar to display and then restart the app
  await Future.delayed(const Duration(seconds: 2));

  // Exit the app
  SystemNavigator.pop();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.green[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Base URL',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter Base URL',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.link, color: Colors.green),
              ),
            ),
            const SizedBox(height: 16),
           ElevatedButton(
  onPressed: _saveBaseUrl,
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green[700], // Button background color
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8), // Rounded corners
    ),
  ),
  child: const Text(
    'Save',
    style: TextStyle(
      color: Colors.white, // Set text color to white
      fontWeight: FontWeight.bold, // Optional: Make text bold
    ),
  ),
),
            const SizedBox(height: 16),
            const Divider(thickness: 1),
            const SizedBox(height: 16),
            Text(
              'Current Base URL: $_baseUrl',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
