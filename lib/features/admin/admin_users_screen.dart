import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List users = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final data = await ApiService.getAllUsers();
      setState(() {
        users = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Future<void> _toggleUser(int id, bool active) async {
    if (active) {
      await ApiService.disableUser(id);
    } else {
      await ApiService.enableUser(id);
    }
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Users Management")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final u = users[index];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(u["email"]),
                  subtitle: Text("Role: ${u["role"]}"),
                  trailing: Switch(
                    value: u["active"] ?? true,
                    onChanged: (_) =>
                        _toggleUser(u["id"], u["active"] ?? true),
                  ),
                );
              },
            ),
    );
  }
}
