import 'dart:io';

import 'package:task_manager/storage_interface.dart';
import 'package:task_manager/task.dart';
import 'package:task_manager/task_manager.dart';
import 'package:test/test.dart';

void main() {
  group('TaskManager Tests', () {
    final testFile = File('test_tasks.json');

    tearDown(() async {
      if (await testFile.exists()) {
        await testFile.delete();
      }
    });

    test('A new task should not be completed by default', () {
      Task taskOne = UrgentTask(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Test Not Completed By Default',
      );
      expect(taskOne.completed, equals(false));
    });

    test(
      'Marking a task as complete requires setting `completed` to true.',
      () async {
        JsonTaskStorage storage = JsonTaskStorage(testFile);
        TaskManager taskManager = TaskManager(storage);
        String uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
        Task taskTwo = UrgentTask(
          id: uniqueId,
          title: 'Test Marking Done The Task $uniqueId',
        );

        await taskManager.addTask(taskTwo);
        await taskManager.markAsDone(uniqueId);

        final tasks = await taskManager.getTasks();
        final updatedTask = tasks.firstWhere((t) => t.id == uniqueId);

        expect(updatedTask.completed, equals(true));
      },
    );

    test(
      'Adding a task with an existing title throws TitleAlreadyExistException',
      () async {
        JsonTaskStorage storage = JsonTaskStorage(testFile);
        TaskManager taskManager = TaskManager(storage);

        String uniqueId1 = DateTime.now().millisecondsSinceEpoch.toString();
        String uniqueId2 = (DateTime.now().millisecondsSinceEpoch + 1)
            .toString();

        Task taskOne = UrgentTask(id: uniqueId1, title: 'Unique Title Test');
        Task taskTwo = SimpleTask(id: uniqueId2, title: 'Unique Title Test');

        await taskManager.addTask(taskOne);

        expect(
          () => taskManager.addTask(taskTwo),
          throwsA(isA<TitleAlreadyExistException>()),
        );
      },
    );

    test('Deleting a task removes it from storage.', () async {
      JsonTaskStorage storage = JsonTaskStorage(testFile);
      TaskManager taskManager = TaskManager(storage);
      String uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
      Task taskToDelete = UrgentTask(
        id: uniqueId,
        title: 'Task To Delete $uniqueId',
      );

      await taskManager.addTask(taskToDelete);
      await taskManager.deleteTask(uniqueId);

      final tasks = await taskManager.getTasks();
      final exists = tasks.any((t) => t.id == uniqueId);

      expect(exists, equals(false));
    });

    test('Deleting a non-existent task throws TaskNotFoundException', () async {
      JsonTaskStorage storage = JsonTaskStorage(testFile);
      TaskManager taskManager = TaskManager(storage);

      expect(
        () => taskManager.deleteTask('lee_id_733'),
        throwsA(isA<TaskNotFoundException>()),
      );
    });

    test('A new task has medium priority by default', () async {
      JsonTaskStorage storage = JsonTaskStorage(testFile);
      TaskManager taskManager = TaskManager(storage);

      String uniqueId = DateTime.now().millisecondsSinceEpoch.toString();

      Task newTask = SimpleTask(id: uniqueId, title: 'Default Priority Task');

      await taskManager.addTask(newTask);

      final tasks = await taskManager.getTasks();
      final createdTask = tasks.firstWhere((task) => task.id == uniqueId);

      expect(createdTask.priority, equals(Priority.medium));
    });

    test(
      'Get tasks sorted by priority returns tasks in correct order',
      () async {
        JsonTaskStorage storage = JsonTaskStorage(testFile);
        TaskManager taskManager = TaskManager(storage);

        String uniqueId1 = DateTime.now().millisecondsSinceEpoch.toString();
        String uniqueId2 = (DateTime.now().millisecondsSinceEpoch + 1)
            .toString();
        String uniqueId3 = (DateTime.now().millisecondsSinceEpoch + 2)
            .toString();

        Task taskOne = UrgentTask(
          id: uniqueId1,
          title: 'Low Priority Test',
          priority: Priority.low,
        );
        Task taskTwo = SimpleTask(
          id: uniqueId2,
          title: 'High Priority Test',
          priority: Priority.high,
        );
        Task taskThree = SimpleTask(
          id: uniqueId3,
          title: 'Medium Priority Test',
        );

        await taskManager.addTask(taskOne);
        await taskManager.addTask(taskTwo);
        await taskManager.addTask(taskThree);

        final tasks = await taskManager.getTasks(sortByPriority: true);

        expect(tasks[0].priority, equals(Priority.high));
        expect(tasks.last.priority, equals(Priority.low));
      },
    );
  });
}
