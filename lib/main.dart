import 'package:flutter/material.dart';
import 'app_database.dart';
import 'shopping_item.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database =
  await $FloorAppDatabase.databaseBuilder('shopping_database.db').build();

  runApp(MyApp(database: database));
}

class MyApp extends StatelessWidget {
  final AppDatabase database;

  const MyApp({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab08',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(
        title: 'Shopping List',
        database: database,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final AppDatabase database;

  const MyHomePage({
    super.key,
    required this.title,
    required this.database,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<ShoppingItem> shoppingList = [];

  late TextEditingController itemController;
  late TextEditingController quantityController;

  @override
  void initState() {
    super.initState();
    itemController = TextEditingController();
    quantityController = TextEditingController();
    loadItemsFromDatabase();
  }

  Future<void> loadItemsFromDatabase() async {
    final items = await widget.database.shoppingItemDao.findAllItems();

    setState(() {
      shoppingList = items;
    });
  }

  Future<void> addItem() async {
    if (itemController.text.isNotEmpty && quantityController.text.isNotEmpty) {
      final newItem = ShoppingItem(
        ShoppingItem.nextId,
        itemController.text,
        quantityController.text,
      );

      await widget.database.shoppingItemDao.insertItem(newItem);

      itemController.clear();
      quantityController.clear();

      await loadItemsFromDatabase();
    }
  }

  Future<void> deleteItem(ShoppingItem item) async {
    await widget.database.shoppingItemDao.deleteItem(item);
    await loadItemsFromDatabase();
  }

  @override
  void dispose() {
    itemController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: itemController,
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
                    controller: quantityController,
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
                    onPressed: addItem,
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
              itemBuilder: (context, index) {
                final item = shoppingList[index];

                return GestureDetector(
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Delete this item?"),
                        content: Text(
                          "Do you want to delete ${item.itemName}?",
                        ),
                        actions: [
                          FilledButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await deleteItem(item);
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
                          "${index + 1}: ${item.itemName}",
                          style: const TextStyle(fontSize: 18),
                        ),
                        Text(
                          "quantity: ${item.quantity}",
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
      ),
    );
  }
}