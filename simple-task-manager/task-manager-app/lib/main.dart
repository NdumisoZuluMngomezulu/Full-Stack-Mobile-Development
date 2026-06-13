import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const TaskApp());
}

class TaskApp extends StatelessWidget {
  const TaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TaskListScreen(),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  // NOTE: If using Android Emulator, replace 'localhost' with '10.0.2.2'
  // If using iOS Simulator, keep 'localhost'. If testing on physical device, use your PC's local IP.
  final String baseUrl = 'http://10.0.2'; 
  List<dynamic> _tasks = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        setState(() {
          _tasks = json.decode(response.body);
        });
      }
    } catch (e) {
      debugPrint("Error fetching tasks: $e");
    }
  }

  Future<void> _addTask() async {
    if (_controller.text.isEmpty) return;
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"title": _controller.text}),
      );
      if (response.statusCode == 200) {
        _controller.clear();
        _fetchTasks();
      }
    } catch (e) {
      debugPrint("Error adding task: $e");
    }
  }

  Future<void> _deleteTask(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      if (response.statusCode == 200) {
        _fetchTasks();
      }
    } catch (e) {
      debugPrint("Error deleting task: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SQLite Task Manager')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Enter new task...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addTask,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: _tasks.isEmpty
                ? const Center(child: Text('No tasks available.'))
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      return ListTile(
                        title: Text(task['title']),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTask(task['id']),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}