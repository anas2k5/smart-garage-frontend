import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';

class OwnerJobCardViewScreen extends StatefulWidget {
  final int bookingId;
  final int garageId;

  const OwnerJobCardViewScreen({
    super.key,
    required this.bookingId,
    required this.garageId,
  });

  @override
  State<OwnerJobCardViewScreen> createState() =>
      _OwnerJobCardViewScreenState();
}

class _OwnerJobCardViewScreenState
    extends State<OwnerJobCardViewScreen> {
  Map<String, dynamic>? job;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadJob();
  }

  // =====================================================
  // LOAD JOB CARD
  // =====================================================
  Future<void> loadJob() async {
    setState(() => loading = true);

    try {
      final jobs =
          await ApiService.getGarageJobCards(widget.garageId);

      final found = jobs.firstWhere(
        (j) => j['booking']['id'] == widget.bookingId,
        orElse: () => null,
      );

      setState(() {
        job = found;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  // =====================================================
  // UI
  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Job Card"),
      ),

      // 🔄 PULL TO REFRESH
      body: RefreshIndicator(
        onRefresh: loadJob,

        child: loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : job == null
                ? const Center(
                    child: Text("Job Card not found"),
                  )
                : _buildContent(),
      ),
    );
  }

  // =====================================================
  // CONTENT
  // =====================================================
  Widget _buildContent() {
    final tasks = job!['tasks'] as List? ?? [];
    final parts = job!['parts'] as List? ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // STATUS
        Text(
          "Status: ${job!['status']}",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        // ================= TASKS =================
        const Text(
          "Tasks",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 8),

        if (tasks.isEmpty)
          const Text("No tasks added")
        else
          ...tasks.map<Widget>((t) {
            return Card(
              child: ListTile(
                leading: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                title: Text(
                  t['description'] ?? "",
                ),
                subtitle: Text(
                  "Hours: ${t['hours']} | ₹${t['cost']}",
                ),
              ),
            );
          }),

        const SizedBox(height: 20),

        // ================= PARTS =================
        const Text(
          "Parts",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 8),

        if (parts.isEmpty)
          const Text("No parts added")
        else
          ...parts.map<Widget>((p) {
            return Card(
              child: ListTile(
                leading: const Icon(
                  Icons.build,
                  color: Colors.blue,
                ),
                title: Text(p['name'] ?? ""),
                subtitle: Text(
                  "Qty: ${p['quantity']} × ₹${p['unitPrice']}",
                ),
              ),
            );
          }),

        const SizedBox(height: 30),

        // ================= TOTAL COST =================
        _costSummary(tasks, parts),
      ],
    );
  }

  // =====================================================
  // COST SUMMARY
  // =====================================================
  Widget _costSummary(List tasks, List parts) {
    double labor = 0;
    double partsCost = 0;

    for (var t in tasks) {
      labor += (t['cost'] ?? 0);
    }

    for (var p in parts) {
      partsCost +=
          (p['quantity'] ?? 0) * (p['unitPrice'] ?? 0);
    }

    final total = labor + partsCost;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              "Cost Summary",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Text("Labor Cost: ₹$labor"),
            Text("Parts Cost: ₹$partsCost"),
            const Divider(),
            Text(
              "Total: ₹$total",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
