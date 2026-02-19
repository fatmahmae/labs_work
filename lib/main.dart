import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Week4',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Week4 Login'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // controllers for the two textfields
  late TextEditingController loginCtrl;
  late TextEditingController passCtrl;

  // Lab4 encrypted shared prefs
  final EncryptedSharedPreferences prefs = EncryptedSharedPreferences();

  // image starts as question mark
  String imageSource = "images/question-mark.png";
  String imageLabel = "Question mark";

  @override
  void initState() {
    super.initState();
    loginCtrl = TextEditingController();
    passCtrl = TextEditingController();

    // Lab4: load saved login/password on startup
    _loadSavedLogin();
  }

  Future<void> _loadSavedLogin() async {
    final savedLogin = await prefs.getString("login");
    final savedPass = await prefs.getString("password");

    if (savedLogin != null && savedPass != null) {
      loginCtrl.text = savedLogin;
      passCtrl.text = savedPass;

      // snackbar must be slightly delayed until page is ready
      Future.delayed(Duration.zero, () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Previous login and password loaded.")),
        );
      });
    }
  }

  @override
  void dispose() {
    loginCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  // Your original Lab2 behavior (image changes based on password)
  void doLogin() {
    String typedPassword = passCtrl.text;

    setState(() {
      if (typedPassword == "ASDF") {
        imageSource = "images/idea.png"; // light bulb
        imageLabel = "Light bulb";
      } else {
        imageSource = "images/stop.png"; // stop sign
        imageLabel = "Stop sign";
      }
    });
  }

  // Lab4: show dialog asking to save or clear
  void _onLoginPressed() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text("Save Login?"),
        content: const Text(
          "Do you want to save your username and password for next time you run the app?",
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // NO -> clear saved encrypted data
              await prefs.remove("login");
              await prefs.remove("password");

              // close dialog
              Navigator.pop(ctx);

              // clear fields so next start it will be empty
              loginCtrl.clear();
              passCtrl.clear();

              // run your lab2 logic (image change)
              doLogin();
            },
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () async {
              // YES -> save encrypted
              await prefs.setString("login", loginCtrl.text);
              await prefs.setString("password", passCtrl.text);

              // close dialog
              Navigator.pop(ctx);

              // run your lab2 logic (image change)
              doLogin();
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 40, 12),
              child: TextField(
                controller: loginCtrl,
                decoration: const InputDecoration(
                  labelText: "Login name",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 40, 12),
              child: TextField(
                controller: passCtrl,
                obscureText: true, // IMPORTANT: hides password
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _onLoginPressed,
              child: const Text("Login"),
            ),
            const SizedBox(height: 16),
            Semantics(
              label: imageLabel,
              child: Image.asset(
                imageSource,
                width: 300,
                height: 300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
