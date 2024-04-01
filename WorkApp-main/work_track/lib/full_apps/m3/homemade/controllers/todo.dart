import 'dart:collection';

import 'package:work_track/full_apps/m3/homemade/models/todo.dart';

class TodoController {
  final List<TodoModel> _todos = [];

  UnmodifiableListView<TodoModel> get todos => UnmodifiableListView(_todos);

  void addTodo(String title, String description) {
    final newTodo = TodoModel(
      title: title,
      description: description,
    );
    _todos.add(newTodo);
  }
}
