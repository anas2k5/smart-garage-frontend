import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';

class JobDetailScreen extends StatelessWidget {
  final Map job;

  const JobDetailScreen({
    super.key,
    required this.job,
  });

  @override
  Widget build(BuildContext context) {
    final tasks = job['tasks'] as List? ?? [];
    final parts = job['parts'] as List? ?? [];

    return Scaffold(
      appBar: AppBar(title: Text("Job #${job['id']}")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Status: ${job['status']}",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 16),

            // ================= TASKS LIST =================
            const Text(
              "Tasks",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            if (tasks.isEmpty)
              const Text("No tasks added")
            else
              ...tasks.map(
                (t) => ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(t['description'] ?? ""),
                  subtitle: Text(
                    "Hours: ${t['hours']} | ₹${t['cost']}",
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // ================= PARTS LIST =================
            const Text(
              "Parts",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            if (parts.isEmpty)
              const Text("No parts added")
            else
              ...parts.map(
                (p) => ListTile(
                  leading: const Icon(Icons.build_circle_outlined),
                  title: Text(p['name'] ?? ""),
                  subtitle: Text(
                    "Qty: ${p['quantity']} × ₹${p['unitPrice']}",
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // ================= ACTION BUTTONS =================

            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Add Task"),
              onPressed: () {
                _showTaskDialog(context);
              },
            ),

            ElevatedButton.icon(
              icon: const Icon(Icons.build),
              label: const Text("Add Part"),
              onPressed: () {
                _showPartDialog(context);
              },
            ),

            const Spacer(),

            // 🔥 FIX 3 — STATUS BASED BUTTONS

            if (job['status'] == 'OPEN')
              ElevatedButton(
                onPressed: () async {
                  await ApiService.approveJobCard(job['id']);
                  Navigator.pop(context);
                },
                child: const Text("Start Work"),
              ),

            if (job['status'] == 'WORKING')
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () async {
                  await ApiService.closeJobCard(job['id']);
                  Navigator.pop(context);
                },
                child: const Text("Close Job"),
              ),
          ],
        ),
      ),
    );
  }

  // ================= ADD TASK =================

  void _showTaskDialog(BuildContext context) {
    final desc = TextEditingController();
    final hours = TextEditingController();
    final cost = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Task"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: desc,
              decoration:
                  const InputDecoration(labelText: "Description"),
            ),
            TextField(
              controller: hours,
              decoration:
                  const InputDecoration(labelText: "Hours"),
            ),
            TextField(
              controller: cost,
              decoration:
                  const InputDecoration(labelText: "Cost"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final h = double.tryParse(hours.text);
              final c = double.tryParse(cost.text);

              if (h == null || c == null) return;

              await ApiService.addJobTask(
                job['id'],
                desc.text,
                h,
                c,
              );

              Navigator.pop(context);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  // ================= ADD PART =================

  void _showPartDialog(BuildContext context) {
    final name = TextEditingController();
    final qty = TextEditingController();
    final price = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Part"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration:
                  const InputDecoration(labelText: "Part Name"),
            ),
            TextField(
              controller: qty,
              decoration:
                  const InputDecoration(labelText: "Quantity"),
            ),
            TextField(
              controller: price,
              decoration:
                  const InputDecoration(labelText: "Unit Price"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final q = int.tryParse(qty.text);
              final p = double.tryParse(price.text);

              if (q == null || p == null) return;

              await ApiService.addJobPart(
                job['id'],
                name.text,
                q,
                p,
              );

              Navigator.pop(context);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }
}
