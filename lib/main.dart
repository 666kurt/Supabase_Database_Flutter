import 'package:flutter/material.dart';
import 'package:supabase_database/database_service.dart';
import 'package:supabase_database/todo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final DatabaseService databaseService = DatabaseService();
  final TextEditingController titleController = TextEditingController();

  // Methods
  void addNewTodo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add new todo"),
        content: TextField(controller: titleController),
        actions: [
          // Close button
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              titleController.clear();
            },
            child: const Text("Cancel"),
          ),
          // Add button
          TextButton(
            onPressed: () {
              final Todo newTodo = Todo(title: titleController.text);
              databaseService.createTodo(newTodo);
              Navigator.pop(context);
              titleController.clear();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void deleteTodo(Todo todo) {
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
          // Agree button
          TextButton(
            onPressed: () {
              databaseService.deleteTodo(todo);
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void updateTodo(Todo todo) {
    titleController.text = todo.title;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update todo"),
        content: TextField(controller: titleController),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              titleController.clear();
            },
            child: const Text("Cancel"),
          ),
          // Agree button
          TextButton(
            onPressed: () {
              databaseService.updateTodo(todo, titleController.text);
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
      appBar: AppBar(title: const Text("Todos")),

      // Add new todo button
      floatingActionButton: FloatingActionButton(
        onPressed: addNewTodo,
        child: const Icon(Icons.add),
      ),

      // Body
      body: StreamBuilder(
        stream: databaseService.stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: Text("There are no todos"));
          }
          final todos = snapshot.data!;
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
