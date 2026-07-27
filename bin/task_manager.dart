import 'dart:io';
import 'dart:convert';

import 'package:task_manager/models/task.dart';
import 'package:task_manager/repositories/task_repository.dart';
import 'package:task_manager/services/task_manager.dart';
import 'package:task_manager/exceptions/task_exception.dart';

String readInput() {
  return stdin.readLineSync(encoding: utf8)?.trim() ?? '';
}

Priority _promptPriority() {
  stdout.write('Priority (low/medium/high, default is medium): ');
  final input = readInput().toLowerCase();
  if (input == 'high' || input == '3' || input == 'h') {
    return Priority.high;
  } else if (input == 'low' || input == '1' || input == 'l') {
    return Priority.low;
  }
  return Priority.medium;
}

DateTime? _promptDeadline() {
  stdout.write('Optional deadline (YYYY-MM-DD, press Enter to skip): ');
  final input = readInput();
  if (input.isEmpty) return null;

  try {
    return DateTime.parse(input);
  } catch (_) {
    print('Invalid date format. Proceeding without deadline.');
    return null;
  }
}

String _formatDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

void main() async {
  final storage = JsonTaskStorage();
  final manager = TaskManager(storage);

  print('=== CLI TASK MANAGER ===');

  while (true) {
    print('\n--- MENU ---');
    print('1. Add a task');
    print('2. List tasks');
    print('3. Mark a task as complete');
    print('4. Delete a task');
    print('5. Exit');
    stdout.write('Choose an option: ');

    final input = readInput();

    if (input == '5') {
      print('Exiting Task Manager. Goodbye!');
      break;
    }

    try {
      switch (input) {
        case '1':
          stdout.write('Task Title: ');
          final title = readInput();
          if (title.isEmpty) {
            print('Title cannot be empty.');
            continue;
          }

          final priority = _promptPriority();
          final deadline = _promptDeadline();
          final id = DateTime.now().millisecondsSinceEpoch.toString();

          // Instantiate UrgentTask or SimpleTask based on deadline presence
          final Task task = deadline != null
              ? UrgentTask(
                  id: id,
                  title: title,
                  priority: priority,
                  deadline: deadline,
                )
              : SimpleTask(id: id, title: title, priority: priority);

          await manager.addTask(task);
          print('Task added successfully!');
          break;

        case '2':
          final tasks = await manager.getAllTasks();
          if (tasks.isEmpty) {
            print('No tasks found.');
            break;
          }

          stdout.write('Sort by priority? (y/n, default is date): ');
          final sortInput = readInput().toLowerCase();

          if (sortInput == 'y' || sortInput == 'yes') {
            tasks.sort((a, b) => b.priority.index.compareTo(a.priority.index));
          } else {
            // Sort deadlines chronologically first, then simple tasks by creation date
            tasks.sort((a, b) {
              final aDeadline = a is UrgentTask ? a.deadline : null;
              final bDeadline = b is UrgentTask ? b.deadline : null;

              if (aDeadline != null && bDeadline != null) {
                return aDeadline.compareTo(bDeadline);
              } else if (aDeadline != null) {
                return -1;
              } else if (bDeadline != null) {
                return 1;
              } else {
                return a.createdAt.compareTo(b.createdAt);
              }
            });
          }

          print('\n--- YOUR TASKS ---');
          for (var t in tasks) {
            final status = t.isCompleted ? '[X]' : '[ ]';
            final priorityStr = '(${t.priority.name.toUpperCase()})';

            String dueStr = '                ';
            if (t is UrgentTask) {
              dueStr = 'Due: ${_formatDate(t.deadline)}';
            }

            print(
              '$status ID: ${t.id} | ${dueStr.padRight(15)} | ${t.title} $priorityStr',
            );
          }
          break;

        case '3':
          stdout.write('Task ID to complete: ');
          final id = readInput();
          await manager.markAsCompleted(id);
          print('Task marked as complete.');
          break;

        case '4':
          stdout.write('Task ID to delete: ');
          final id = readInput();
          await manager.deleteTask(id);
          print('Task deleted.');
          break;

        default:
          print('Invalid option. Please try again.');
      }
    } on TaskException catch (e) {
      print('Error: ${e.message}');
    } catch (e) {
      print('Unexpected error: $e');
    }
  }
}
