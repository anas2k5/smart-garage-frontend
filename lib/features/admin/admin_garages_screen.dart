import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';

class AdminGaragesScreen extends StatefulWidget {
  const AdminGaragesScreen({super.key});

  @override
  State<AdminGaragesScreen> createState() => _AdminGaragesScreenState();
}

class _AdminGaragesScreenState extends State<AdminGaragesScreen> {
  List<Map<String, dynamic>> garages = [];
  List<Map<String, dynamic>> filteredGarages = [];

  bool loading = true;
  bool processing = false;

  String searchQuery = "";
  String statusFilter = "ALL";

  @override
  void initState() {
    super.initState();
    _loadGarages();
  }

  // ================= LOAD GARAGES =================
  Future<void> _loadGarages() async {
    try {
      setState(() => loading = true);

      final data = await ApiService.getAllGaragesAdmin();
      final list = List<Map<String, dynamic>>.from(data);

      if (!mounted) return;

      setState(() {
        garages = list;
        _applyFilters();
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load garages")),
      );
    }
  }

  // ================= FILTER LOGIC =================
  void _applyFilters() {
    filteredGarages = garages.where((g) {
      final name = (g["name"] ?? "").toString().toLowerCase();
      final isActive = g["active"] == true;

      final matchesSearch =
          name.contains(searchQuery.toLowerCase());

      final matchesStatus = statusFilter == "ALL" ||
          (statusFilter == "ACTIVE" && isActive) ||
          (statusFilter == "INACTIVE" && !isActive);

      return matchesSearch && matchesStatus;
    }).toList();
  }

  // ================= CONFIRM TOGGLE =================
  Future<void> _confirmToggle(Map<String, dynamic> garage) async {
    final isActive = garage["active"] == true;
    final action = isActive ? "Deactivate" : "Activate";

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("$action Garage"),
        content: Text(
          "Are you sure you want to $action ${garage["name"]}?",
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
      _toggleGarage(garage["id"]);
    }
  }

  // ================= TOGGLE GARAGE =================
  Future<void> _toggleGarage(int id) async {
    if (processing) return;

    try {
      setState(() => processing = true);

      await ApiService.toggleGarage(id);
      await _loadGarages();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Garage status updated")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update garage")),
      );
    } finally {
      if (mounted) {
        setState(() => processing = false);
      }
    }
  }

  // ================= STATUS BADGE =================
  Widget _statusBadge(bool active) {
    final color = active ? Colors.green : Colors.red;
    final text = active ? "ACTIVE" : "INACTIVE";

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

  // ================= STATUS FILTER CHIPS =================
  Widget _statusChips() {
    const statuses = ["ALL", "ACTIVE", "INACTIVE"];

    return Wrap(
      spacing: 8,
      children: statuses.map((status) {
        final selected = statusFilter == status;

        return ChoiceChip(
          label: Text(status),
          selected: selected,
          onSelected: (_) {
            setState(() {
              statusFilter = status;
              _applyFilters();
            });
          },
        );
      }).toList(),
    );
  }

  // ================= GARAGE CARD =================
  Widget _garageCard(Map<String, dynamic> g) {
    final isActive = g["active"] == true;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.15),
          child: const Icon(Icons.store),
        ),
        title: Text(
          g["name"] ?? "Unknown Garage",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Row(
          children: [
            _statusBadge(isActive),
          ],
        ),
        trailing: Switch(
          value: isActive,
          onChanged: processing ? null : (_) => _confirmToggle(g),
        ),
        onTap: () => _confirmToggle(g),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Garage Management"),
      ),
      body: RefreshIndicator(
        onRefresh: _loadGarages,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // 🔍 Search
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: "Search by garage name...",
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

                  // 🏷️ Status Filters
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _statusChips(),
                  ),

                  const SizedBox(height: 8),

                  // 📋 Garage List
                  Expanded(
                    child: filteredGarages.isEmpty
                        ? const Center(
                            child: Text("No garages found"),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: filteredGarages.length,
                            itemBuilder: (context, index) {
                              return _garageCard(
                                  filteredGarages[index]);
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
