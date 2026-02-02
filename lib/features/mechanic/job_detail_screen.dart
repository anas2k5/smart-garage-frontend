import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';

class JobDetailScreen extends StatelessWidget {
  final Map job;

  const JobDetailScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: 10),

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

            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                await ApiService.approveJobCard(job['id']);
                Navigator.pop(context);
              },
              child: const Text("Approve Job"),
            ),

            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
              await ApiService.addJobTask(
                job['id'],
                desc.text,
                double.parse(hours.text),
                double.parse(cost.text),
              );
              Navigator.pop(context);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

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
              await ApiService.addJobPart(
                job['id'],
                name.text,
                int.parse(qty.text),
                double.parse(price.text),
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
