/// Base exception class for all domain-specific task manager errors.
class TaskException implements Exception {
  final String message;
  TaskException(this.message);

  @override
  String toString() => 'TaskException: $message';
}

class TaskNotFoundException extends TaskException {
  TaskNotFoundException(String id) : super('Task with ID "$id" was not found.');
}

class DuplicateTaskException extends TaskException {
  DuplicateTaskException(String title)
    : super('Task with title "$title" already exists.');
}

class StorageException extends TaskException {
  StorageException(String message) : super('Storage error: $message');
}
