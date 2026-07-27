import '../models/task.dart';
import '../repositories/repository.dart';
import '../exceptions/task_exception.dart';

/// Business logic service coordinating domain logic and persistence layer.
class TaskManager {
  final Repository<Task> _repository;

  TaskManager(this._repository);

  Future<List<Task>> getAllTasks() async {
    return await _repository.getAll();
  }

  Future<void> addTask(Task task) async {
    final tasks = await _repository.getAll();
    final exists = tasks.any(
      (t) => t.title.trim().toLowerCase() == task.title.trim().toLowerCase(),
    );
    if (exists) {
      throw DuplicateTaskException(task.title);
    }
    await _repository.add(task);
  }

  Future<void> markAsCompleted(String id) async {
    final task = await _repository.getById(id);
    if (task == null) {
      throw TaskNotFoundException(id);
    }
    task.isCompleted = true;
    await _repository.update(task);
  }

  Future<void> deleteTask(String id) async {
    final task = await _repository.getById(id);
    if (task == null) {
      throw TaskNotFoundException(id);
    }
    await _repository.delete(id);
  }
}
