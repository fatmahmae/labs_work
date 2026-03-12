import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab06',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Shopping List'),
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

class ShoppingItem {
  String itemName;
  String quantity;

  ShoppingItem(this.itemName, this.quantity);
}

class _MyHomePageState extends State<MyHomePage> {
  var shoppingList = <ShoppingItem>[];

  late TextEditingController _itemController;
  late TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _itemController = TextEditingController();
    _quantityController = TextEditingController();
  }

  @override
  void dispose() {
    _itemController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListPage(),
    );
  }

  Widget ListPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _itemController,
                  decoration: const InputDecoration(
                    hintText: "Type the item here",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "Type the quantity here",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (_itemController.text.isNotEmpty &&
                          _quantityController.text.isNotEmpty) {
                        shoppingList.add(
                          ShoppingItem(
                            _itemController.text,
                            _quantityController.text,
                          ),
                        );

                        _itemController.text = "";
                        _quantityController.text = "";
                      }
                    });
                  },
                  child: const Text("Add"),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: shoppingList.isEmpty
              ? const Center(
            child: Text(
              "There are no items in the list",
              style: TextStyle(fontSize: 18),
            ),
          )
              : ListView.builder(
            itemCount: shoppingList.length,
            itemBuilder: (context, rowNum) {
              return GestureDetector(
                onLongPress: () {
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text("Delete this item?"),
                      content: Text(
                        "Do you want to delete ${shoppingList[rowNum].itemName}?",
                      ),
                      actions: <Widget>[
                        FilledButton(
                          onPressed: () {
                            setState(() {
                              shoppingList.removeAt(rowNum);
                            });
                            Navigator.pop(context);
                          },
                          child: const Text("Yes"),
                        ),
                        FilledButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("No"),
                        ),
                      ],
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "${rowNum + 1}: ${shoppingList[rowNum].itemName}",
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        "quantity: ${shoppingList[rowNum].quantity}",
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}