// Deprecated shim: JSON file storage was removed in favor of SQLite.
// Keep a minimal stub to avoid breaking imports; all operations should
// use `DatabaseService` now.

class JsonStorageService {
  JsonStorageService._();
  static final JsonStorageService instance = JsonStorageService._();

  Future<void> loadData() async {
    throw UnsupportedError(
        'JsonStorageService removed: use DatabaseService instead.');
  }

  Future<void> clearAllData() async {
    throw UnsupportedError(
        'JsonStorageService removed: use DatabaseService instead.');
  }

  // Any other former methods should be replaced by DatabaseService equivalents.
}
