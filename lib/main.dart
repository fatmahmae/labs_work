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
      title: 'Lab09',
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
  // This list holds all items loaded from the database
  List<ShoppingItem> shoppingList = [];

  // Controllers let me read and clear the text fields
  late TextEditingController itemController;
  late TextEditingController quantityController;

  // This variable stores the item the user tapped on
  ShoppingItem? selectedItem;

  @override
  void initState() {
    super.initState();

    // Initialize the text field controllers
    itemController = TextEditingController();
    quantityController = TextEditingController();

    // Load saved items when the app opens
    loadItemsFromDatabase();
  }

  Future<void> loadItemsFromDatabase() async {
    // Get all shopping items from the Floor database
    final items = await widget.database.shoppingItemDao.findAllItems();

    setState(() {
      shoppingList = items;

      // If the selected item was deleted, clear it
      if (selectedItem != null &&
          !shoppingList.any((item) => item.id == selectedItem!.id)) {
        selectedItem = null;
      }
    });
  }

  Future<void> addItem() async {
    // Only add the item if both fields have text
    if (itemController.text.isNotEmpty && quantityController.text.isNotEmpty) {
      final newItem = ShoppingItem(
        ShoppingItem.nextId,
        itemController.text,
        quantityController.text,
      );

      // Insert the new item into the database
      await widget.database.shoppingItemDao.insertItem(newItem);

      // Clear the text fields after adding
      itemController.clear();
      quantityController.clear();

      // Reload the list so the new item appears on screen
      await loadItemsFromDatabase();
    }
  }

  Future<void> deleteItem(ShoppingItem item) async {
    // Remove the item from the database
    await widget.database.shoppingItemDao.deleteItem(item);

    // Reload the list after deleting
    await loadItemsFromDatabase();
  }

  void closeDetails() {
    // This hides the details page by clearing the selected item
    setState(() {
      selectedItem = null;
    });
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is removed
    itemController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  bool isWideScreen(BuildContext context) {
    // I use this to decide if the app should show
    // list + details side by side or only one page at a time
    final screenWidth = MediaQuery.of(context).size.width;
    final orientation = MediaQuery.of(context).orientation;

    return screenWidth >= 700 || orientation == Orientation.landscape;
  }

  Widget buildInputArea() {
    // This is the top input section with 2 text fields and the Add button
    return Padding(
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
    );
  }

  Widget buildShoppingList() {
    // If there are no items, show a message in the center
    if (shoppingList.isEmpty) {
      return const Center(
        child: Text(
          "There are no items in the list",
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    // Otherwise show all items in a scrollable list
    return ListView.builder(
      itemCount: shoppingList.length,
      itemBuilder: (context, index) {
        final item = shoppingList[index];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title: Text("${index + 1}: ${item.itemName}"),
            subtitle: Text("Quantity: ${item.quantity}"),

            // In Week9 I changed the interaction to tap instead of long press
            onTap: () {
              setState(() {
                selectedItem = item;
              });
            },
          ),
        );
      },
    );
  }

  Widget buildDetailsPage() {
    // If nothing is selected yet, show a simple message
    if (selectedItem == null) {
      return const Center(
        child: Text(
          "Select an item to see details",
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    // This page shows the selected item's full details
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Item Details",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Item Name: ${selectedItem!.itemName}",
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 10),
          Text(
            "Quantity: ${selectedItem!.quantity}",
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 10),
          Text(
            "Database ID: ${selectedItem!.id}",
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  // Save the selected item first, then delete it
                  final itemToDelete = selectedItem!;
                  await deleteItem(itemToDelete);
                },
                child: const Text("Delete"),
              ),
              const SizedBox(width: 15),
              OutlinedButton(
                onPressed: closeDetails,
                child: const Text("Close"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool wideScreen = isWideScreen(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          buildInputArea(),
          Expanded(
            child: wideScreen
            // On tablet/desktop, show list and details side by side
                ? Row(
              children: [
                Expanded(
                  flex: 2,
                  child: buildShoppingList(),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  flex: 2,
                  child: buildDetailsPage(),
                ),
              ],
            )
            // On phone/portrait:
            // if no item is selected, show the list
            // if an item is selected, show the details page
                : selectedItem == null
                ? buildShoppingList()
                : buildDetailsPage(),
          ),
        ],
      ),
    );
  }
}