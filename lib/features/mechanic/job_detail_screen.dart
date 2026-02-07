import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';

class JobDetailScreen extends StatefulWidget {
  final Map job;

  const JobDetailScreen({
    super.key,
    required this.job,
  });

  @override
  State<JobDetailScreen> createState() =>
      _JobDetailScreenState();
}

class _JobDetailScreenState
    extends State<JobDetailScreen> {
  late Map job;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    job = widget.job;
  }

  // ================= REFRESH =================

  Future<void> refreshJob() async {
    final jobs =
        await ApiService.getMechanicJobs();

    final updated = jobs.firstWhere(
      (j) => j['id'] == job['id'],
      orElse: () => job,
    );

    setState(() => job = updated);
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final tasks = job['tasks'] as List? ?? [];
    final parts = job['parts'] as List? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text("Job #${job['id']}"),
      ),

      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // ================= STATUS =================

                  Text(
                    "Status: ${job['status']}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ================= TASKS =================

                  const Text(
                    "Tasks",
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  if (tasks.isEmpty)
                    const Text(
                        "No tasks added")
                  else
                    ...tasks.map(
                      (t) => ListTile(
                        leading: const Icon(
                          Icons
                              .check_circle_outline,
                        ),
                        title: Text(
                            t['description'] ??
                                ""),
                        subtitle: Text(
                          "Hours: ${t['hours']} | ₹${t['cost']}",
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // ================= PARTS =================

                  const Text(
                    "Parts",
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  if (parts.isEmpty)
                    const Text(
                        "No parts added")
                  else
                    ...parts.map(
                      (p) => ListTile(
                        leading: const Icon(
                          Icons
                              .build_circle_outlined,
                        ),
                        title: Text(
                            p['name'] ?? ""),
                        subtitle: Text(
                          "Qty: ${p['quantity']} × ₹${p['unitPrice']}",
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // ================= ACTIONS =================

                  if (job['status'] == 'OPEN' ||
                      job['status'] ==
                          'WORKING')
                    SizedBox(
                      width: double.infinity,
                      child:
                          ElevatedButton.icon(
                        icon:
                            const Icon(Icons.add),
                        label:
                            const Text("Add Task"),
                        onPressed:
                            _showTaskDialog,
                      ),
                    ),

                  const SizedBox(height: 8),

                  if (job['status'] == 'OPEN' ||
                      job['status'] ==
                          'WORKING')
                    SizedBox(
                      width: double.infinity,
                      child:
                          ElevatedButton.icon(
                        icon: const Icon(
                            Icons.build),
                        label:
                            const Text("Add Part"),
                        onPressed:
                            _showPartDialog,
                      ),
                    ),

                  const SizedBox(height: 20),

                  // ================= START WORK =================

                  if (job['status'] == 'OPEN')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          setState(() =>
                              loading = true);

                          await ApiService
                              .approveJobCard(
                                  job['id']);

                          await refreshJob();

                          setState(() =>
                              loading = false);
                        },
                        child:
                            const Text("Start Work"),
                      ),
                    ),

                  // ================= CLOSE JOB =================

                  if (job['status'] ==
                      'WORKING')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              Colors.red,
                        ),
                        onPressed: () async {
                          setState(() =>
                              loading = true);

                          await ApiService
                              .closeJobCard(
                                  job['id']);

                          await refreshJob();

                          setState(() =>
                              loading = false);
                        },
                        child:
                            const Text("Close Job"),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  // ================= ADD TASK =================

  void _showTaskDialog() {
    final desc =
        TextEditingController();
    final hours =
        TextEditingController();
    final cost =
        TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Task"),
        content: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            TextField(
              controller: desc,
              decoration:
                  const InputDecoration(
                labelText: "Description",
              ),
            ),
            TextField(
              controller: hours,
              keyboardType:
                  TextInputType.number,
              decoration:
                  const InputDecoration(
                labelText: "Hours",
              ),
            ),
            TextField(
              controller: cost,
              keyboardType:
                  TextInputType.number,
              decoration:
                  const InputDecoration(
                labelText: "Cost",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final h =
                  double.tryParse(
                      hours.text);
              final c =
                  double.tryParse(
                      cost.text);

              if (desc.text.isEmpty ||
                  h == null ||
                  c == null) return;

              setState(() =>
                  loading = true);

              await ApiService
                  .addJobTask(
                job['id'],
                desc.text,
                h,
                c,
              );

              Navigator.pop(context);

              await refreshJob();

              setState(() =>
                  loading = false);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  // ================= ADD PART =================

  void _showPartDialog() {
    final name =
        TextEditingController();
    final qty =
        TextEditingController();
    final price =
        TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Part"),
        content: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration:
                  const InputDecoration(
                labelText: "Part Name",
              ),
            ),
            TextField(
              controller: qty,
              keyboardType:
                  TextInputType.number,
              decoration:
                  const InputDecoration(
                labelText: "Quantity",
              ),
            ),
            TextField(
              controller: price,
              keyboardType:
                  TextInputType.number,
              decoration:
                  const InputDecoration(
                labelText: "Unit Price",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final q =
                  int.tryParse(
                      qty.text);
              final p =
                  double.tryParse(
                      price.text);

              if (name.text.isEmpty ||
                  q == null ||
                  p == null) return;

              setState(() =>
                  loading = true);

              await ApiService
                  .addJobPart(
                job['id'],
                name.text,
                q,
                p,
              );

              Navigator.pop(context);

              await refreshJob();

              setState(() =>
                  loading = false);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }
}
