import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import 'job_detail_screen.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() =>
      _JobListScreenState();
}

class _JobListScreenState
    extends State<JobListScreen> {
  List jobs = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadJobs();
  }

  // ================= LOAD JOBS =================

  Future<void> loadJobs() async {
    setState(() => loading = true);

    try {
      final data =
          await ApiService.getMechanicJobs();

      setState(() {
        jobs = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text("My Job Cards")),

      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : jobs.isEmpty
              ? const Center(
                  child:
                      Text("No jobs assigned yet"),
                )
              : RefreshIndicator(
                  onRefresh: loadJobs,
                  child: ListView.builder(
                    itemCount: jobs.length,
                    itemBuilder: (_, i) {
                      final job = jobs[i];

                      return Card(
                        child: ListTile(
                          title: Text(
                              "Job #${job['id']}"),

                          subtitle: Text(
                            "Status: ${job['status']}  |  Booking #${job['booking']['id']}",
                          ),

                          trailing: const Icon(
                              Icons.arrow_forward),

                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    JobDetailScreen(
                                        job: job),
                              ),
                            );

                            // 🔄 Refresh after return
                            loadJobs();
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
