import 'dart:io';
import 'package:task_manager/storage_interface.dart';
import 'package:task_manager/task.dart';
import 'package:task_manager/task_manager.dart';

void main() async {
  final file = File('tasks.json');
  final storage = JsonTaskStorage(file);
  final taskManager = TaskManager(storage);

  print('=== CLI TASK MANAGER ===');

  while (true) {
    print('\n--- MENU ---');
    print('1. Add a task');
    print('2. List tasks');
    print('3. Mark a task as complete');
    print('4. Delete a task');
    print('5. Exit');
    stdout.write('Choose an option: ');

    String? choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        String? taskTitle;
        while (taskTitle == null || taskTitle.trim().isEmpty) {
          stdout.write('Enter task title (cannot be empty): ');
          taskTitle = stdin.readLineSync()?.trim();
          if (taskTitle == null || taskTitle.isEmpty) {
            print('Error: Title cannot be blank. Please try again.');
          }
        }

        stdout.write('Enter priority (low/medium/high): ');
        String? priorityInput = stdin.readLineSync()?.trim().toLowerCase();

        Priority taskPriority;
        if (priorityInput == 'high') {
          taskPriority = Priority.high;
        } else if (priorityInput == 'low') {
          taskPriority = Priority.low;
        } else if (priorityInput == 'medium') {
          taskPriority = Priority.medium;
        } else {
          print('Invalid priority entered. Defaulting to MEDIUM.');
          taskPriority = Priority.medium;
        }

        stdout.write('Enter deadline (YYYY-MM-DD) or press Enter to skip: ');
        String? deadlineInput = stdin.readLineSync()?.trim();

        DateTime? deadline;
        if (deadlineInput != null && deadlineInput.isNotEmpty) {
          final dateRegExp = RegExp(
            r'^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$',
          );

          if (dateRegExp.hasMatch(deadlineInput)) {
            try {
              deadline = DateTime.parse(deadlineInput);
            } catch (_) {
              print('Invalid date value. Task created without deadline.');
            }
          } else {
            print(
              'Invalid date format (must be YYYY-MM-DD). Task created without deadline.',
            );
          }
        }

        String uniqueID = DateTime.now().millisecondsSinceEpoch.toString();

        Task task;
        if (taskPriority == Priority.high) {
          task = UrgentTask(id: uniqueID, title: taskTitle, deadline: deadline);
        } else {
          task = SimpleTask(
            id: uniqueID,
            title: taskTitle,
            priority: taskPriority,
            deadline: deadline,
          );
        }

        await taskManager.addTask(task);
        print('Task added successfully!');
        break;

      case '2':
        stdout.write('Sort by priority? (y/n, default is date): ');
        String? sortInput = stdin.readLineSync()?.trim().toLowerCase();

        bool sortByPriority = (sortInput == 'y' || sortInput == 'yes');

        final tasks = await taskManager.getTasks(
          sortByPriority: sortByPriority,
        );

        if (tasks.isEmpty) {
          print('No tasks found.');
        } else {
          print('\n--- YOUR TASKS ---');
          for (var task in tasks) {
            String status = task.completed ? '[X]' : '[ ]';
            String deadlineInfo = task.deadline != null
                ? 'Due: ${task.deadline.toString().split(' ')[0]}'
                : '               ';
            print(
              '$status ID: ${task.id} | $deadlineInfo | ${task.title} (${task.priority.name.toUpperCase()})',
            );
          }
        }
        break;

      case '3':
        stdout.write('Enter task ID to mark as done: ');
        String? id = stdin.readLineSync();

        if (id != null && id.isNotEmpty) {
          try {
            await taskManager.markAsDone(id);
            print('Task marked as complete successfully!');
          } on TaskNotFoundException catch (e) {
            print('Error: ${e.message}');
          }
        } else {
          print('Invalid ID.');
        }
        break;

      case '4':
        stdout.write('Enter task ID to delete: ');
        String? id = stdin.readLineSync();

        if (id != null && id.isNotEmpty) {
          try {
            await taskManager.deleteTask(id);
            print('Task deleted successfully!');
          } on TaskNotFoundException catch (e) {
            print('Error: ${e.message}');
          }
        } else {
          print('Invalid ID.');
        }
        break;

      case '5':
        print('Exiting Task Manager. Goodbye!');
        return;

      default:
        print('Invalid option, try again.');
    }
  }
}
