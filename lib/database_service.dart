import 'package:supabase_flutter/supabase_flutter.dart';
import 'todo.dart';

class DatabaseService {
  // Instance of supabase table
  final _supabaseTable = Supabase.instance.client.from("todos");

  // Create
  Future createTodo(Todo newTodo) async {
    await _supabaseTable.insert(newTodo.toJson());
  }

  // Read
  final stream = Supabase.instance.client.from("todos").stream(
    primaryKey: ["id"],
  ).map((data) => data.map((todo) => Todo.fromJson(todo)).toList());

  // Update
  Future updateTodo(Todo currentTodo, String newTitle) async {
    await _supabaseTable.update({"title": newTitle}).eq("id", currentTodo.id!);
  }

  // Delete
  Future deleteTodo(Todo currentTodo) async {
    await _supabaseTable.delete().eq("id", currentTodo.id!);
  }
}
