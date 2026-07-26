import 'dart:convert';
import 'dart:io';
import 'package:task_manager/task.dart';

abstract class Repository<T> {
  Future<List<T>> getAll();
  Future<void> saveAll(List<T> items);
}

class JsonTaskStorage implements Repository<Task> {
  final File file;

  JsonTaskStorage(this.file);

  @override
  Future<List<Task>> getAll() async {
    if (!await file.exists()) {
      return [];
    }

    try {
      final content = await file.readAsString();
      if (content.trim().isEmpty) return [];

      final List<dynamic> jsonList = jsonDecode(content);
      return jsonList
          .map((json) => Task.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveAll(List<Task> items) async {
    final jsonList = items.map((task) => task.toJson()).toList();
    final jsonString = JsonEncoder.withIndent('  ').convert(jsonList);
    await file.writeAsString(jsonString);
  }
}
