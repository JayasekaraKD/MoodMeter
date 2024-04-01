import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _selectedUserId;
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    QuerySnapshot querySnapshot = await _firestore.collection('users').get();
    List<Map<String, dynamic>> usersList =
        querySnapshot.docs.map((DocumentSnapshot document) {
      return {
        'id': document.id,
        'username': document['username'],
        'role': document['role'],
      };
    }).toList();

    setState(() {
      _users = usersList;
    });
  }

  Future<void> _updateUserRole(String userId, String newRole) async {
    await _firestore.collection('users').doc(userId).update({'role': newRole});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select User:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedUserId,
              onChanged: (String? userId) {
                setState(() {
                  _selectedUserId = userId;
                });
              },
              items: _users
                  .map<DropdownMenuItem<String>>((Map<String, dynamic> user) {
                return DropdownMenuItem<String>(
                  value: user['id'],
                  child: Text(user['username']),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectedUserId != null
                  ? () async {
                      await _updateUserRole(_selectedUserId!, 'admin');
                      // Reload users after updating role
                      await _loadUsers();
                    }
                  : null,
              child: Text('Grant Admin Privilege'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AdminPage(),
  ));
}
