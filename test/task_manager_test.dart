import 'package:test/test.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/repositories/repository.dart';
import 'package:task_manager/services/task_manager.dart';
import 'package:task_manager/exceptions/task_exception.dart';

/// In-memory repository implementation for unit testing without I/O side effects.
class MockTaskRepository implements Repository<Task> {
  final List<Task> _tasks = [];

  @override
  Future<List<Task>> getAll() async => List.unmodifiable(_tasks);

  @override
  Future<Task?> getById(String id) async {
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> add(Task item) async => _tasks.add(item);

  @override
  Future<void> update(Task item) async {
    final index = _tasks.indexWhere((t) => t.id == item.id);
    if (index != -1) _tasks[index] = item;
  }

  @override
  Future<void> delete(String id) async {
    _tasks.removeWhere((t) => t.id == id);
  }
}

void main() {
  group('TaskManager Unit Tests', () {
    late TaskManager taskManager;
    late MockTaskRepository mockRepo;

    setUp(() {
      mockRepo = MockTaskRepository();
      taskManager = TaskManager(mockRepo);
    });

    test('1. Should add a task successfully', () async {
      final task = SimpleTask(
        id: '1',
        title: 'Test Task',
        priority: Priority.medium,
      );
      await taskManager.addTask(task);
      final tasks = await taskManager.getAllTasks();
      expect(tasks.length, equals(1));
      expect(tasks.first.title, equals('Test Task'));
    });

    test('2. Should retrieve all tasks', () async {
      await taskManager.addTask(
        SimpleTask(id: '1', title: 'Task 1', priority: Priority.low),
      );
      await taskManager.addTask(
        SimpleTask(id: '2', title: 'Task 2', priority: Priority.high),
      );

      final tasks = await taskManager.getAllTasks();
      expect(tasks.length, equals(2));
    });

    test('3. Should throw DuplicateTaskException on duplicate title', () async {
      final task1 = SimpleTask(
        id: '1',
        title: 'Unique Task',
        priority: Priority.low,
      );
      await taskManager.addTask(task1);

      expect(
        () async => await taskManager.addTask(
          SimpleTask(id: '2', title: 'Unique Task', priority: Priority.high),
        ),
        throwsA(isA<DuplicateTaskException>()),
      );
    });

    test('4. Should mark task as completed', () async {
      final task = SimpleTask(
        id: '1',
        title: 'Task to complete',
        priority: Priority.low,
      );
      await taskManager.addTask(task);

      await taskManager.markAsCompleted('1');
      final updated = await mockRepo.getById('1');
      expect(updated?.isCompleted, isTrue);
    });

    test(
      '5. Should throw TaskNotFoundException when completing non-existent task',
      () async {
        expect(
          () async => await taskManager.markAsCompleted('999'),
          throwsA(isA<TaskNotFoundException>()),
        );
      },
    );

    test(
      '6. Should throw TaskNotFoundException when deleting non-existent task',
      () async {
        expect(
          () async => await taskManager.deleteTask('999'),
          throwsA(isA<TaskNotFoundException>()),
        );
      },
    );

    test('7. Should delete an existing task successfully', () async {
      final task = SimpleTask(
        id: '1',
        title: 'Task to delete',
        priority: Priority.low,
      );
      await taskManager.addTask(task);

      await taskManager.deleteTask('1');
      final tasks = await taskManager.getAllTasks();
      expect(tasks.isEmpty, isTrue);
    });
  });
}
