import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import 'package:intl/intl.dart';

class AdminAuditScreen extends StatefulWidget {
  const AdminAuditScreen({super.key});

  @override
  State<AdminAuditScreen> createState() => _AdminAuditScreenState();
}

class _AdminAuditScreenState extends State<AdminAuditScreen> {
  List logs = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    try {
      final data = await ApiService.getRecentAuditLogs();
      setState(() {
        logs = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  String _formatTime(String timestamp) {
    final dt = DateTime.parse(timestamp);
    return DateFormat("dd MMM yyyy, hh:mm a").format(dt);
  }

  Color _badgeColor(String action) {
    switch (action) {
      case "PAYMENT_SUCCESS":
        return Colors.green;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Audit Logs")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadLogs,
              child: ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            _badgeColor(log["action"]).withOpacity(0.2),
                        child: Icon(
                          Icons.security,
                          color: _badgeColor(log["action"]),
                        ),
                      ),
                      title: Text(
                        "${log["action"]} • ${log["entityType"]} #${log["entityId"]}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text("By: ${log["actorEmail"]}"),
                          Text("Role: ${log["actorRole"]}"),
                          Text("Time: ${_formatTime(log["timestamp"])}"),
                          if (log["newValue"] != null &&
                              log["newValue"].toString().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                "Change: ${log["newValue"]}",
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
