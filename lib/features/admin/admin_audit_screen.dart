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

  // Global Brand Palette
  static const Color brandGreen = Color(0xFF00B562);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color backgroundDark = Color(0xFF121212);

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

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
        const SnackBar(backgroundColor: Colors.redAccent, content: Text("Failed to fetch logs")),
      );
    }
  }

  void _applyFilters() {
    filteredLogs = logs.where((log) {
      final actor = (log["actorEmail"] ?? "").toString().toLowerCase();
      final action = (log["action"] ?? "").toString().toLowerCase();
      final entityType = (log["entityType"] ?? "").toString().toLowerCase();
      final entityId = log["entityId"].toString();
      final module = (log["module"] ?? "UNKNOWN").toString().toUpperCase();

      final matchesSearch = actor.contains(searchQuery.toLowerCase()) ||
          action.contains(searchQuery.toLowerCase()) ||
          entityType.contains(searchQuery.toLowerCase()) ||
          entityId.contains(searchQuery);

      final matchesModule = moduleFilter == "ALL" || module == moduleFilter;

      return matchesSearch && matchesModule;
    }).toList();
  }

  String _formatTime(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp);
      return DateFormat("dd MMM yyyy • hh:mm a").format(dt);
    } catch (e) {
      return "Time Unknown";
    }
  }

  Color _badgeColor(String action) {
    switch (action) {
      case "USER_ENABLED":
      case "PAYMENT_SUCCESS":
      case "GARAGE_APPROVED":
        return brandGreen;
      case "USER_DISABLED":
      case "STATUS_CHANGE":
        return Colors.blueAccent;
      case "COST_UPDATE":
        return Colors.orangeAccent;
      case "ASSIGN_MECHANIC":
        return Colors.purpleAccent;
      default:
        return Colors.white24;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundDark,
        appBarTheme: const AppBarTheme(backgroundColor: backgroundDark, elevation: 0),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Security Audit", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          centerTitle: true,
        ),
        body: Column(
          children: [
            _buildSearchAndFilters(),
            Expanded(
              child: RefreshIndicator(
                color: brandGreen,
                onRefresh: _loadLogs,
                child: loading
                    ? const Center(child: CircularProgressIndicator(color: brandGreen))
                    : _buildLogsList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: backgroundDark,
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Column(
        children: [
          TextField(
            onChanged: (val) => setState(() { searchQuery = val; _applyFilters(); }),
            decoration: InputDecoration(
              hintText: "Search actor, action, or ID...",
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded, color: brandGreen, size: 20),
              filled: true,
              fillColor: surfaceDark,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                "ALL", "USER_MANAGEMENT", "GARAGE_MANAGEMENT", 
                "BOOKING_MANAGEMENT", "PAYMENT_MANAGEMENT", "JOB_CARD_MANAGEMENT"
              ].map((m) => _buildModuleChip(m)).toList(),
            ),
          ),
        ],
      ),
    );
  }

 // Update the ChoiceChip shape inside _buildModuleChip method:
Widget _buildModuleChip(String label) {
  final isSelected = moduleFilter == label;
  return Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(label.replaceAll("_", " "), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      selected: isSelected,
      onSelected: (_) => setState(() { moduleFilter = label; _applyFilters(); }),
      selectedColor: brandGreen,
      backgroundColor: surfaceDark,
      showCheckmark: false,
      // FIXED PARAMETER NAME
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide.none),
    ),
  );
}

  Widget _buildLogsList() {
    if (filteredLogs.isEmpty) {
      return const Center(child: Text("No logs found", style: TextStyle(color: Colors.white24)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredLogs.length,
      itemBuilder: (context, index) => _buildLogItem(filteredLogs[index]),
    );
  }

  Widget _buildLogItem(Map<String, dynamic> log) {
    final action = log["action"] ?? "UNKNOWN";
    final module = (log["module"] ?? "UNKNOWN").toString().replaceAll("_", " ");
    final color = _badgeColor(action);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: brandGreen,
          collapsedIconColor: Colors.white24,
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.history_toggle_off_rounded, color: color, size: 20),
          ),
          title: Text("$action", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Text("${_formatTime(log["timestamp"])}", style: const TextStyle(color: Colors.white30, fontSize: 11)),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(color: Colors.white10),
                  _detailRow("Module", module),
                  _detailRow("Target", "${log["entityType"]} #${log["entityId"]}"),
                  _detailRow("Actor", log["actorEmail"]),
                  _detailRow("Role", log["actorRole"]),
                  if (log["oldValue"] != null) _detailRow("Before", log["oldValue"], isValue: true),
                  if (log["newValue"] != null) _detailRow("After", log["newValue"], isValue: true, highlight: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, dynamic value, {bool isValue = false, bool highlight = false}) {
    if (value == null || value.toString().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text("$label:", style: const TextStyle(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.bold))),
          Expanded(
            child: Text(
              value.toString(),
              style: TextStyle(
                color: highlight ? brandGreen : (isValue ? Colors.white70 : Colors.white54),
                fontSize: 12,
                fontWeight: highlight ? FontWeight.bold : FontWeight.normal
              ),
            ),
          ),
        ],
      ),
    );
  }
}