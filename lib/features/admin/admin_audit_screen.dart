import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/services/api_service.dart';

class AdminAuditScreen extends StatefulWidget {
  const AdminAuditScreen({super.key});

  @override
  State<AdminAuditScreen> createState() => _AdminAuditScreenState();
}

class _AdminAuditScreenState extends State<AdminAuditScreen> {
  List<Map<String, dynamic>> logs = [];
  List<Map<String, dynamic>> filteredLogs = [];

  bool loading = true;

  String searchQuery = "";
  String moduleFilter = "ALL";

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  // ================= LOAD LOGS =================
  Future<void> _loadLogs() async {
    try {
      setState(() => loading = true);

      final data = await ApiService.getRecentAuditLogs();
      final list = List<Map<String, dynamic>>.from(data);

      if (!mounted) return;

      setState(() {
        logs = list;
        _applyFilters();
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load audit logs")),
      );
    }
  }

  // ================= FILTER LOGIC =================
  void _applyFilters() {
    filteredLogs = logs.where((log) {
      final actor =
          (log["actorEmail"] ?? "").toString().toLowerCase();
      final action =
          (log["action"] ?? "").toString().toLowerCase();
      final entityType =
          (log["entityType"] ?? "").toString().toLowerCase();
      final entityId = log["entityId"].toString();

      final module =
          (log["module"] ?? "UNKNOWN").toString().toUpperCase();

      final matchesSearch =
          actor.contains(searchQuery.toLowerCase()) ||
          action.contains(searchQuery.toLowerCase()) ||
          entityType.contains(searchQuery.toLowerCase()) ||
          entityId.contains(searchQuery);

      final matchesModule =
          moduleFilter == "ALL" || module == moduleFilter;

      return matchesSearch && matchesModule;
    }).toList();
  }

  // ================= MODULE FILTER CHIPS =================
  Widget _moduleChips() {
    const modules = [
      "ALL",
      "USER_MANAGEMENT",
      "GARAGE_MANAGEMENT",
      "BOOKING_MANAGEMENT",
      "PAYMENT_MANAGEMENT",
      "JOB_CARD_MANAGEMENT"
    ];

    return Wrap(
      spacing: 8,
      children: modules.map((module) {
        final selected = moduleFilter == module;

        return ChoiceChip(
          label: Text(module.replaceAll("_", " ")),
          selected: selected,
          onSelected: (_) {
            setState(() {
              moduleFilter = module;
              _applyFilters();
            });
          },
        );
      }).toList(),
    );
  }

  // ================= DATE FORMAT =================
  String _formatTime(String timestamp) {
    final dt = DateTime.parse(timestamp);
    return DateFormat("dd MMM yyyy • hh:mm a").format(dt);
  }

  // ================= ACTION COLOR =================
  Color _badgeColor(String action) {
    switch (action) {
      case "USER_ENABLED":
      case "PAYMENT_SUCCESS":
        return Colors.green;
      case "USER_DISABLED":
      case "STATUS_CHANGE":
        return Colors.blue;
      case "COST_UPDATE":
        return Colors.orange;
      case "ASSIGN_MECHANIC":
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // ================= LOG CARD =================
  Widget _logCard(Map<String, dynamic> log) {
    final action = log["action"] ?? "UNKNOWN";
    final module = (log["module"] ?? "UNKNOWN").toString();
    final color = _badgeColor(action);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(Icons.security, color: color),
        ),
        title: Text(
          "$action • ${log["entityType"]} #${log["entityId"]}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "${module.replaceAll("_", " ")} • ${_formatTime(log["timestamp"])}",
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow("Actor", log["actorEmail"]),
                _detailRow("Role", log["actorRole"]),
                _detailRow("Old Value", log["oldValue"]),
                _detailRow("New Value", log["newValue"]),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ================= DETAIL ROW =================
  Widget _detailRow(String label, dynamic value) {
    if (value == null || value.toString().isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(value.toString()),
          ),
        ],
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Audit Logs"),
      ),
      body: RefreshIndicator(
        onRefresh: _loadLogs,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // 🔍 Search
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText:
                            "Search by actor, action, module, or entity...",
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

                  // 🏷️ Module Filters
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _moduleChips(),
                  ),

                  const SizedBox(height: 8),

                  // 📋 Logs List
                  Expanded(
                    child: filteredLogs.isEmpty
                        ? const Center(
                            child: Text("No audit logs found"),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: filteredLogs.length,
                            itemBuilder: (context, index) {
                              return _logCard(
                                  filteredLogs[index]);
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
