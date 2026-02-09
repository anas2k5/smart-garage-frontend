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
  State<OwnerJobCardViewScreen> createState() => _OwnerJobCardViewScreenState();
}

class _OwnerJobCardViewScreenState extends State<OwnerJobCardViewScreen> {
  Map<String, dynamic>? job;
  bool loading = true;

  // Global Brand Palette
  static const Color brandGreen = Color(0xFF00B562);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color backgroundDark = Color(0xFF121212);

  @override
  void initState() {
    super.initState();
    loadJob();
  }

  Future<void> loadJob() async {
    setState(() => loading = true);
    try {
      final jobs = await ApiService.getGarageJobCards(widget.garageId);
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.redAccent, content: Text(e.toString())),
        );
      }
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
          title: const Text("Service Job Card", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: brandGreen),
              onPressed: loadJob,
            )
          ],
        ),
        body: RefreshIndicator(
          color: brandGreen,
          onRefresh: loadJob,
          child: loading
              ? const Center(child: CircularProgressIndicator(color: brandGreen))
              : job == null
                  ? _buildEmptyState()
                  : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final tasks = job!['tasks'] as List? ?? [];
    final parts = job!['parts'] as List? ?? [];
    final status = job!['status'] ?? "IN_PROGRESS";

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildStatusHeader(status),
        const SizedBox(height: 24),
        _buildSectionTitle("SERVICE TASKS", Icons.checklist_rtl_rounded),
        const SizedBox(height: 12),
        if (tasks.isEmpty) _buildNoData("No tasks recorded") else ...tasks.map((t) => _buildItemTile(t, isTask: true)),
        const SizedBox(height: 28),
        _buildSectionTitle("REPLACED PARTS", Icons.settings_input_component_rounded),
        const SizedBox(height: 12),
        if (parts.isEmpty) _buildNoData("No parts replaced") else ...parts.map((p) => _buildItemTile(p, isTask: false)),
        const SizedBox(height: 32),
        _costSummary(tasks, parts),
      ],
    );
  }

  Widget _buildStatusHeader(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: brandGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: brandGreen.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Current Status", style: TextStyle(color: brandGreen, fontWeight: FontWeight.bold)),
          Text(status, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white38),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      ],
    );
  }

  Widget _buildItemTile(dynamic data, {required bool isTask}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(isTask ? Icons.task_alt_rounded : Icons.extension_rounded, color: isTask ? brandGreen : Colors.blueAccent, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isTask ? data['description'] : data['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(
                  isTask ? "Time: ${data['hours']} hrs" : "Qty: ${data['quantity']}",
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
          Text("₹${isTask ? data['cost'] : (data['unitPrice'] * data['quantity'])}", style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _costSummary(List tasks, List parts) {
    double labor = tasks.fold(0, (sum, t) => sum + (t['cost'] ?? 0));
    double partsCost = parts.fold(0, (sum, p) => sum + ((p['quantity'] ?? 0) * (p['unitPrice'] ?? 0)));
    final total = labor + partsCost;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: brandGreen.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _summaryRow("Labor Charges", labor),
          const SizedBox(height: 8),
          _summaryRow("Parts Total", partsCost),
          const Divider(height: 32, color: Colors.white10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("GRAND TOTAL", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
              Text("₹$total", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: brandGreen)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
        Text("₹$amount", style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildEmptyState() => const Center(child: Text("Job Card not found", style: TextStyle(color: Colors.white38)));
  Widget _buildNoData(String msg) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(msg, style: const TextStyle(color: Colors.white24, fontSize: 12)));
}