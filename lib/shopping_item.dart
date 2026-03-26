import 'package:floor/floor.dart';

@entity
class ShoppingItem {
  @primaryKey
  final int id;

  final String itemName;
  final String quantity;

  static int nextId = 1;

  ShoppingItem(this.id, this.itemName, this.quantity) {
    if (id >= nextId) {
      nextId = id + 1;
    }
  }
}