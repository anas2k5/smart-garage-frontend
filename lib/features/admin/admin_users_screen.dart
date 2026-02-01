import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];

  bool loading = true;
  bool processing = false;

  String searchQuery = "";
  String roleFilter = "ALL";

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  // ================= LOAD USERS =================
  Future<void> _loadUsers() async {
    try {
      setState(() {
        loading = true;
      });

      final data = await ApiService.getAllUsers();
      final list = List<Map<String, dynamic>>.from(data);

      if (!mounted) return;

      setState(() {
        users = list;
        _applyFilters();
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load users")),
      );
    }
  }

  // ================= FILTER LOGIC =================
  void _applyFilters() {
    filteredUsers = users.where((u) {
      final email = (u["email"] ?? "").toString().toLowerCase();
      final role = (u["role"] ?? "").toString().toUpperCase();

      final matchesSearch =
          email.contains(searchQuery.toLowerCase());
      final matchesRole =
          roleFilter == "ALL" || role == roleFilter;

      return matchesSearch && matchesRole;
    }).toList();
  }

  // ================= CONFIRM TOGGLE =================
  Future<void> _confirmToggle(Map<String, dynamic> user) async {
    final isActive = user["active"] ?? true;
    final action = isActive ? "Disable" : "Enable";

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("$action User"),
        content: Text(
          "Are you sure you want to $action ${user["email"]}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(action),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _toggleUser(user["id"], isActive);
    }
  }

  // ================= TOGGLE USER =================
  Future<void> _toggleUser(int id, bool active) async {
    if (processing) return;

    try {
      setState(() => processing = true);

      if (active) {
        await ApiService.disableUser(id);
      } else {
        await ApiService.enableUser(id);
      }

      await _loadUsers();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            active
                ? "User disabled successfully"
                : "User enabled successfully",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Action failed")),
      );
    } finally {
      if (mounted) {
        setState(() => processing = false);
      }
    }
  }

  // ================= ROLE FILTER CHIPS =================
  Widget _roleChips() {
    const roles = ["ALL", "ADMIN", "OWNER", "CUSTOMER"];

    return Wrap(
      spacing: 8,
      children: roles.map((role) {
        final selected = roleFilter == role;

        return ChoiceChip(
          label: Text(role),
          selected: selected,
          onSelected: (_) {
            setState(() {
              roleFilter = role;
              _applyFilters();
            });
          },
        );
      }).toList(),
    );
  }

  // ================= STATUS BADGE =================
  Widget _statusBadge(bool active) {
    final color = active ? Colors.green : Colors.red;
    final text = active ? "ACTIVE" : "DISABLED";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ================= USER CARD =================
  Widget _userCard(Map<String, dynamic> user) {
    final isActive = user["active"] ?? true;
    final role = (user["role"] ?? "").toString();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.15),
          child: const Icon(Icons.person),
        ),
        title: Text(
          user["email"] ?? "Unknown",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Row(
          children: [
            Text("Role: $role"),
            const SizedBox(width: 8),
            _statusBadge(isActive),
          ],
        ),
        trailing: Switch(
          value: isActive,
          onChanged: processing ? null : (_) => _confirmToggle(user),
        ),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Management"),
      ),
      body: RefreshIndicator(
        onRefresh: _loadUsers,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // 🔍 Search
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: "Search by email...",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) {
                        setState(() {
                          searchQuery = val;
                          _applyFilters();
                        });
                      },
                    ),
                  ),

                  // 🏷️ Role Filters
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _roleChips(),
                  ),

                  const SizedBox(height: 8),

                  // 📋 Users List
                  Expanded(
                    child: filteredUsers.isEmpty
                        ? const Center(
                            child: Text("No users found"),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              return _userCard(filteredUsers[index]);
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
