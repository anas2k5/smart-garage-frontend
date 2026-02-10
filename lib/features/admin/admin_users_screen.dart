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

  static const Color brandGreen = Color(0xFF00B562);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color backgroundDark = Color(0xFF121212);

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      setState(() => loading = true);
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to load users")));
    }
  }

  void _applyFilters() {
    filteredUsers = users.where((u) {
      final email = (u["email"] ?? "").toString().toLowerCase();
      final role = (u["role"] ?? "").toString().toUpperCase();
      final matchesSearch = email.contains(searchQuery.toLowerCase());
      final matchesRole = roleFilter == "ALL" || role == roleFilter;
      return matchesSearch && matchesRole;
    }).toList();
  }

  Future<void> _toggleUser(int id, bool active) async {
    if (processing) return;
    try {
      setState(() => processing = true);
      active ? await ApiService.disableUser(id) : await ApiService.enableUser(id);
      await _loadUsers();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: brandGreen, content: Text("User updated")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Action failed")));
    } finally {
      if (mounted) setState(() => processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(useMaterial3: true, scaffoldBackgroundColor: backgroundDark),
      child: Scaffold(
        appBar: AppBar(title: const Text("User Management"), centerTitle: true),
        body: Column(
          children: [
            _buildHeader(),
            Expanded(child: loading ? const Center(child: CircularProgressIndicator(color: brandGreen)) : _buildList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            onChanged: (v) => setState(() { searchQuery = v; _applyFilters(); }),
            decoration: InputDecoration(
              hintText: "Search email...",
              prefixIcon: const Icon(Icons.search, color: brandGreen),
              filled: true, fillColor: surfaceDark,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: ["ALL", "ADMIN", "OWNER", "CUSTOMER"].map((r) => _buildChip(r)).toList()),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    final isSelected = roleFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        selected: isSelected,
        onSelected: (_) => setState(() { roleFilter = label; _applyFilters(); }),
        selectedColor: brandGreen,
        backgroundColor: surfaceDark,
        showCheckmark: false,
        // FIXED PARAMETER NAME
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide.none),
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final u = filteredUsers[index];
        final active = u["active"] ?? true;
        return Card(
          color: surfaceDark,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(u["email"] ?? ""),
            subtitle: Text(u["role"] ?? ""),
            trailing: Switch(value: active, activeColor: brandGreen, onChanged: (v) => _toggleUser(u["id"], active)),
          ),
        );
      },
    );
  }
}