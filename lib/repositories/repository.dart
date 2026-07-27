/// Generic interface contract enforcing CRUD storage operations.
abstract interface class Repository<T> {
  Future<List<T>> getAll();
  Future<T?> getById(String id);
  Future<void> add(T item);
  Future<void> update(T item);
  Future<void> delete(String id);
}
