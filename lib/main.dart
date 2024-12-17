import 'package:flutter/material.dart';
import 'package:supabase_database/database_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'todo.dart';

void main() async {
  await Supabase.initialize(
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5iZXF5dnNya2NyYnd4bG53bnlhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQzNDcxNzIsImV4cCI6MjA0OTkyMzE3Mn0.tKliYE_fWX8fOU_wnwnmRaDE42vCJfHXBYFFWxcNUWA",
    url: "https://nbeqyvsrkcrbwxlnwnya.supabase.co",
  );
  runApp(const SupabaseDatabase());
}

class SupabaseDatabase extends StatelessWidget {
  const SupabaseDatabase({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TodoScreen(),
    );
  }
}

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  // Properties
  final TextEditingController titleController = TextEditingController();

  final DatabaseService databaseService = DatabaseService();

  // Add new todo method
  void addNewTodo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add new todo"),
        content: TextField(controller: titleController),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () {
              titleController.clear();
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          // Save button
          TextButton(
            onPressed: () {
              final Todo newTodo = Todo(title: titleController.text);
              databaseService.createTodo(newTodo);
              titleController.clear();
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // Delete todo method
  void deleteTodo(Todo currentTodo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Are you sure?"),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          // Save button
          TextButton(
            onPressed: () {
              databaseService.deleteTodo(currentTodo);
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  // Update todo method
  void updateTodo(Todo currentTodo) {
    titleController.text = currentTodo.title;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update todo"),
        content: TextField(controller: titleController),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () {
              titleController.clear();
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          // Save button
          TextButton(
            onPressed: () {
              databaseService.updateTodo(currentTodo, titleController.text);
              titleController.clear();
              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("CRUD")),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewTodo,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: databaseService.stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: Text("There are have no data"));
          }

          final List<Todo> todos = snapshot.data!;

          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final Todo todo = todos[index];
              return ListTile(
                title: Text(todo.title),
                trailing: SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => updateTodo(todo),
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: () => deleteTodo(todo),
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
