// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name ?? ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  ShoppingItemDao? _shoppingItemDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ShoppingItem` (`id` INTEGER NOT NULL, `itemName` TEXT NOT NULL, `quantity` TEXT NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  ShoppingItemDao get shoppingItemDao {
    return _shoppingItemDaoInstance ??=
        _$ShoppingItemDao(database, changeListener);
  }
}

class _$ShoppingItemDao extends ShoppingItemDao {
  _$ShoppingItemDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _shoppingItemInsertionAdapter = InsertionAdapter(
            database,
            'ShoppingItem',
            (ShoppingItem item) => <String, Object?>{
                  'id': item.id,
                  'itemName': item.itemName,
                  'quantity': item.quantity
                }),
        _shoppingItemDeletionAdapter = DeletionAdapter(
            database,
            'ShoppingItem',
            ['id'],
            (ShoppingItem item) => <String, Object?>{
                  'id': item.id,
                  'itemName': item.itemName,
                  'quantity': item.quantity
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ShoppingItem> _shoppingItemInsertionAdapter;

  final DeletionAdapter<ShoppingItem> _shoppingItemDeletionAdapter;

  @override
  Future<List<ShoppingItem>> findAllItems() async {
    return _queryAdapter.queryList('SELECT * FROM ShoppingItem',
        mapper: (Map<String, Object?> row) => ShoppingItem(row['id'] as int,
            row['itemName'] as String, row['quantity'] as String));
  }

  @override
  Future<void> insertItem(ShoppingItem item) async {
    await _shoppingItemInsertionAdapter.insert(item, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteItem(ShoppingItem item) async {
    await _shoppingItemDeletionAdapter.delete(item);
  }
}
