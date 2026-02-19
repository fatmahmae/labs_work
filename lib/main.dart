import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab02',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Lab02 Login'),
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

  // image starts as question mark
  String imageSource = "images/question-mark.png";
  String imageLabel = "Question mark";

  @override
  void initState() {
    super.initState();
    loginCtrl = TextEditingController();
    passCtrl = TextEditingController();
  }

  @override
  void dispose() {
    loginCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  void doLogin() {
    String typedPassword = passCtrl.text;

    setState(() {
      if (typedPassword == "ASDF") {
        imageSource = "images/idea.png";     // light bulb
        imageLabel = "Light bulb";
      } else {
        imageSource = "images/stop.png";     // stop sign
        imageLabel = "Stop sign";
      }
    });
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
              onPressed: doLogin,
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
