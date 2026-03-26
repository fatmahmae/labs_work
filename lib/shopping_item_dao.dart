import 'package:floor/floor.dart';
import 'shopping_item.dart';

@dao
abstract class ShoppingItemDao {
  @Query('SELECT * FROM ShoppingItem')
  Future<List<ShoppingItem>> findAllItems();

  @insert
  Future<void> insertItem(ShoppingItem item);

  @delete
  Future<void> deleteItem(ShoppingItem item);
}