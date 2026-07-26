import 'package:task_manager/storage_interface.dart';
import 'package:task_manager/task.dart';

class TaskNotFoundException implements Exception {
  final String message;
  TaskNotFoundException(this.message);

  @override
  String toString() => 'TaskNotFoundException: $message';
}

class TitleAlreadyExistException implements Exception {
  final String message;
  TitleAlreadyExistException(this.message);

  @override
  String toString() => 'TitleAlreadyExistException: $message';
}

class TaskManager {
  final Repository<Task> _storage;

  TaskManager(this._storage);

  Future<void> addTask(Task newTask) async {
    final tasks = await _storage.getAll();
    bool titleExists = tasks.any(
      (t) => t.title.toLowerCase() == newTask.title.toLowerCase(),
    );
    if (titleExists) {
      throw TitleAlreadyExistException(
        "A task with the same title already exists!",
      );
    }
    tasks.add(newTask);
    await _storage.saveAll(tasks);
  }

  Future<List<Task>> getTasks({bool sortByPriority = false}) async {
    final taskList = await _storage.getAll();
    if (taskList.isEmpty) return [];

    if (sortByPriority) {
      taskList.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    } else {
      taskList.sort((a, b) {
        if (a.deadline != null && b.deadline != null) {
          return a.deadline!.compareTo(b.deadline!);
        }
        if (a.deadline != null) return -1;
        if (b.deadline != null) return 1;

        return b.id.compareTo(a.id);
      });
    }
    return taskList;
  }

  Future<void> markAsDone(String id) async {
    final tasks = await _storage.getAll();
    final index = tasks.indexWhere((t) => t.id == id);

    if (index == -1) {
      throw TaskNotFoundException('Task not found with ID: $id');
    }

    tasks[index].completed = true;
    await _storage.saveAll(tasks);
  }

  Future<void> deleteTask(String id) async {
    final tasks = await _storage.getAll();
    final initialLength = tasks.length;

    tasks.removeWhere((t) => t.id == id);

    if (tasks.length == initialLength) {
      throw TaskNotFoundException('Task not found with ID: $id');
    }

    await _storage.saveAll(tasks);
  }
}
