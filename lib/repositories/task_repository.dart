import 'dart:io';
import 'dart:convert';
import 'repository.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/exceptions/task_exception.dart';

/// File-system JSON implementation of the generic Repository contract.
class JsonTaskStorage implements Repository<Task> {
  final String filePath;

  JsonTaskStorage([this.filePath = 'tasks.json']);

  File get _file => File(filePath);

  @override
  Future<List<Task>> getAll() async {
    try {
      if (!await _file.exists()) return [];
      final content = await _file.readAsString();
      if (content.trim().isEmpty) return [];

      final List<dynamic> jsonList = jsonDecode(content);
      return jsonList.map((json) => Task.fromJson(json)).toList();
    } on FormatException {
      throw StorageException('Corrupted JSON file structure.');
    } catch (e) {
      throw StorageException('Could not read tasks file: $e');
    }
  }

  @override
  Future<Task?> getById(String id) async {
    final tasks = await getAll();
    try {
      return tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> add(Task item) async {
    final tasks = await getAll();
    tasks.add(item);
    await _saveAll(tasks);
  }

  @override
  Future<void> update(Task item) async {
    final tasks = await getAll();
    final index = tasks.indexWhere((t) => t.id == item.id);
    if (index != -1) {
      tasks[index] = item;
      await _saveAll(tasks);
    }
  }

  @override
  Future<void> delete(String id) async {
    final tasks = await getAll();
    tasks.removeWhere((t) => t.id == id);
    await _saveAll(tasks);
  }

  Future<void> _saveAll(List<Task> tasks) async {
    try {
      final jsonList = tasks.map((t) => t.toJson()).toList();
      await _file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      throw StorageException('Failed to write tasks to file: $e');
    }
  }
}
