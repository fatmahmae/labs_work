import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'data_repository.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController firstCtrl;
  late TextEditingController lastCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController emailCtrl;

  @override
  void initState() {
    super.initState();

    firstCtrl = TextEditingController(text: DataRepository.firstName);
    lastCtrl = TextEditingController(text: DataRepository.lastName);
    phoneCtrl = TextEditingController(text: DataRepository.phoneNumber);
    emailCtrl = TextEditingController(text: DataRepository.emailAddress);

    // Welcome snackbar
    Future.delayed(Duration.zero, () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Welcome Back ${DataRepository.loginName}")),
      );
    });

    // Save whenever user types
    firstCtrl.addListener(_saveProfile);
    lastCtrl.addListener(_saveProfile);
    phoneCtrl.addListener(_saveProfile);
    emailCtrl.addListener(_saveProfile);
  }

  Future<void> _saveProfile() async {
    DataRepository.firstName = firstCtrl.text;
    DataRepository.lastName = lastCtrl.text;
    DataRepository.phoneNumber = phoneCtrl.text;
    DataRepository.emailAddress = emailCtrl.text;

    await DataRepository.saveData();
  }

  Future<void> _launchOrAlert(String urlString) async {
    final uri = Uri.parse(urlString);
    final can = await canLaunchUrl(uri);

    if (can) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Not Supported"),
          content: Text("This device does not support: $urlString"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("OK"),
            )
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    firstCtrl.dispose();
    lastCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile Page")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Welcome Back ${DataRepository.loginName}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: firstCtrl,
              decoration: const InputDecoration(
                labelText: "First Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: lastCtrl,
              decoration: const InputDecoration(
                labelText: "Last Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Phone Number row: TextField + Telephone + SMS
            Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Phone Number",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.call),
                  onPressed: () {
                    final phone = phoneCtrl.text.trim();
                    if (phone.isNotEmpty) {
                      _launchOrAlert("tel:$phone");
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.message),
                  onPressed: () {
                    final phone = phoneCtrl.text.trim();
                    if (phone.isNotEmpty) {
                      _launchOrAlert("sms:$phone");
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Email row: TextField + mail button
            Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Email address",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.mail),
                  onPressed: () {
                    final email = emailCtrl.text.trim();
                    if (email.isNotEmpty) {
                      _launchOrAlert("mailto:$email");
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
