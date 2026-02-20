import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'data_repository.dart';
import 'profile_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Week5',
      debugShowCheckedModeBanner: false,


      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(title: 'Week5 Login'),
        '/profile': (context) => const ProfilePage(),
      },

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
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
  late TextEditingController loginCtrl;
  late TextEditingController passCtrl;

  // EncryptedSharedPreferences
  final EncryptedSharedPreferences prefs = EncryptedSharedPreferences();

  //lab02 picture
  String imageSource = "images/question-mark.png";
  String imageLabel = "Question mark";

 //the right password from lab02
  static const String correctPassword = "ASDF";

  @override
  void initState() {
    super.initState();
    loginCtrl = TextEditingController();
    passCtrl = TextEditingController();

    _loadSavedLoginAndRepo();
  }

  Future<void> _loadSavedLoginAndRepo() async {
    // Load all saved data into repository
    final loaded = await DataRepository.loadData();

    if (loaded) {
      loginCtrl.text = DataRepository.loginName;
      passCtrl.text = DataRepository.password;

      // Snackbar at startup needs delay
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

  // Lab2 image behavior
  void _updateImageBasedOnPassword() {
    final typedPassword = passCtrl.text;

    setState(() {
      if (typedPassword != '') {
        imageSource = "images/idea.png";
        imageLabel = "Light bulb";
      } else {
        imageSource = "images/stop.png";
        imageLabel = "Stop sign";
      }
    });
  }

  void _onLoginPressed() {
    // AlertDialog asking to save login/pass
    showDialog(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text("Save Login?"),
        content: const Text("Do you want to save your username and password for next time?"),
        actions: [
          TextButton(
            onPressed: () async {
              // no clear encrypted saved login data
              await prefs.remove("login");
              await prefs.remove("password");
              await DataRepository.clearLogin();

              Navigator.pop(ctx);

              loginCtrl.clear();
              passCtrl.clear();

              _updateImageBasedOnPassword();


            },
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () async {
              // yes save encrypted login data
              await prefs.setString("login", loginCtrl.text);
              await prefs.setString("password", passCtrl.text);
              await DataRepository.saveLogin(loginCtrl.text, passCtrl.text);

              Navigator.pop(ctx);

              _updateImageBasedOnPassword();

              // “Successful login” -> go to second page if password correct
              if (passCtrl.text == correctPassword) {
                // Put loginName in repository so next page can show it
                DataRepository.loginName = loginCtrl.text;

                Navigator.pushNamed(context, '/profile');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Login failed: password incorrect.")),
                );
              }
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
                obscureText: true,
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

            // Lab2 image area (kept)
            Semantics(
              label: imageLabel,
              child: Image.asset(
                imageSource,
                width: 220,
                height: 220,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
