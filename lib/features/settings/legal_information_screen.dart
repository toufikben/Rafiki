import 'package:flutter/material.dart';

class LegalInformationScreen extends StatelessWidget {
  const LegalInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy and terms')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Text(
            'Privacy policy',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Rafiq keeps pet state, learning preferences, local chat history, and installed model files on this device. The app does not upload pet content or download a model automatically. A model is downloaded only after you enter a URL and explicitly confirm the download.',
          ),
          SizedBox(height: 20),
          Text(
            'Optional services',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Advertising, purchases, notifications, and floating-window access are optional platform services. Production identifiers and store configuration must be supplied by the release owner; the app fails closed when they are not configured.',
          ),
          SizedBox(height: 20),
          Text(
            'Terms of use',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Use only model files and visual assets that you are licensed to use. You are responsible for reviewing the license and source of any model URL before downloading it. Rafiq is a companion application and does not provide medical, legal, financial, or emergency advice.',
          ),
          SizedBox(height: 20),
          Text(
            'Data deletion',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'The Delete All Data action removes the local pet record. Installed model files are managed separately from the Local AI model settings.',
          ),
        ],
      ),
    );
  }
}
