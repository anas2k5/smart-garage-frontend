import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';

class JobDetailScreen extends StatefulWidget {
  final Map job;

  const JobDetailScreen({
    super.key,
    required this.job,
  });

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  late Map job;
  bool loading = false;

  // Global Brand Palette
  static const Color brandGreen = Color(0xFF00B562);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color backgroundDark = Color(0xFF121212);

  @override
  void initState() {
    super.initState();
    job = widget.job;
  }

  // ================= OPTIMIZED REFRESH =================

  Future<void> refreshJob() async {
    try {
      final jobs = await ApiService.getMechanicJobs();
      final updated = jobs.firstWhere(
        (j) => j['id'] == job['id'],
        orElse: () => job,
      );
      if (mounted) setState(() => job = updated);
    } catch (e) {
      debugPrint("Error refreshing job: $e");
    }
  }

  // ================= UI HELPERS =================

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: brandGreen),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final tasks = job['tasks'] as List? ?? [];
    final parts = job['parts'] as List? ?? [];
    final String status = (job['status'] ?? 'OPEN').toString().toUpperCase();

    return Theme(
      data: ThemeData.dark().copyWith(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundDark,
        appBarTheme: const AppBarTheme(backgroundColor: backgroundDark, elevation: 0),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Job Card #${job['id']}", style: const TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: brandGreen),
              onPressed: refreshJob,
            )
          ],
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator(color: brandGreen))
            : Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        _buildStatusBanner(status),
                        const SizedBox(height: 24),
                        
                        _buildSectionHeader("Service Tasks", Icons.playlist_add_check_rounded),
                        if (tasks.isEmpty) 
                          _buildEmptyNotice("No tasks recorded yet") 
                        else 
                          ...tasks.map((t) => _buildItemCard(t, isTask: true)),
                        
                        const SizedBox(height: 24),
                        
                        _buildSectionHeader("Replaced Parts", Icons.settings_input_component_rounded),
                        if (parts.isEmpty) 
                          _buildEmptyNotice("No parts added yet") 
                        else 
                          ...parts.map((p) => _buildItemCard(p, isTask: false)),

                        const SizedBox(height: 40),
                        
                        // ACTION BUTTONS
                        if (status == 'OPEN' || status == 'WORKING') ...[
                          _buildActionButton(
                            label: "Add Service Task",
                            icon: Icons.add_task_rounded,
                            onPressed: _showTaskDialog,
                            isPrimary: false,
                          ),
                          const SizedBox(height: 12),
                          _buildActionButton(
                            label: "Add Replacement Part",
                            icon: Icons.add_business_rounded,
                            onPressed: _showPartDialog,
                            isPrimary: false,
                          ),
                          const SizedBox(height: 32),
                        ],
                      ],
                    ),
                  ),
                  _buildStickyFooter(status, tasks, parts),
                ],
              ),
      ),
    );
  }

  Widget _buildStatusBanner(String status) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: brandGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: brandGreen.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("WORKFLOW STATUS", style: TextStyle(color: brandGreen, fontWeight: FontWeight.bold, fontSize: 12)),
          Text(status, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildItemCard(dynamic item, {required bool isTask}) {
    final double amount = isTask 
        ? (item['cost']?.toDouble() ?? 0.0) 
        : ((item['quantity'] ?? 0) * (item['unitPrice']?.toDouble() ?? 0.0));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: ListTile(
        leading: Icon(isTask ? Icons.done_all_rounded : Icons.build_circle_rounded, 
                    color: isTask ? brandGreen : Colors.blueAccent, size: 20),
        title: Text(isTask ? item['description'] : item['name'], 
                   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(
          isTask ? "${item['hours']} hrs" : "Qty: ${item['quantity']}",
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
        trailing: Text("₹${amount.toStringAsFixed(2)}", 
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
      ),
    );
  }

  Widget _buildStickyFooter(String status, List tasks, List parts) {
    double total = 0;
    for (var t in tasks) total += (t['cost'] ?? 0);
    for (var p in parts) total += (p['quantity'] ?? 0) * (p['unitPrice'] ?? 0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Est. Total Value", style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold)),
                Text("₹${total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: brandGreen)),
              ],
            ),
            const SizedBox(height: 20),
            if (status == 'OPEN')
              _buildActionButton(
                label: "START WORK",
                icon: Icons.play_arrow_rounded,
                onPressed: () => _updateJobStatus('approve'),
                isPrimary: true,
              ),
            if (status == 'WORKING')
              _buildActionButton(
                label: "FINALIZE & CLOSE",
                icon: Icons.check_circle_rounded,
                onPressed: () => _updateJobStatus('close'),
                isPrimary: true,
                color: Colors.redAccent,
              ),
            if (status == 'CLOSED' || status == 'COMPLETED')
              const Text("Job Card is Finalized", style: TextStyle(color: Colors.white24, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label, 
    required IconData icon, 
    required VoidCallback onPressed, 
    bool isPrimary = true,
    Color? color,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 20),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? (isPrimary ? brandGreen : backgroundDark),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isPrimary ? BorderSide.none : const BorderSide(color: Colors.white10),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }

  // ================= STATUS LOGIC =================

  Future<void> _updateJobStatus(String action) async {
    setState(() => loading = true);
    try {
      if (action == 'approve') {
        await ApiService.approveJobCard(job['id']);
      } else {
        await ApiService.closeJobCard(job['id']);
      }
      await refreshJob();
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // ================= DIALOGS =================

  void _showTaskDialog() {
    final desc = TextEditingController();
    final hours = TextEditingController();
    final cost = TextEditingController();

    _showStyledDialog(
      title: "Add Service Task",
      content: [
        _buildDialogField(desc, "Task Description", Icons.description_rounded),
        _buildDialogField(hours, "Hours Spent", Icons.timer_rounded, isNumber: true),
        _buildDialogField(cost, "Labor Cost (₹)", Icons.payments_rounded, isNumber: true),
      ],
      onSave: () async {
        final h = double.tryParse(hours.text);
        final c = double.tryParse(cost.text);
        if (desc.text.trim().isEmpty || h == null || c == null) return;

        setState(() => loading = true);
        Navigator.pop(context);
        await ApiService.addJobTask(job['id'], desc.text.trim(), h, c);
        await refreshJob();
        setState(() => loading = false);
      },
    );
  }

  void _showPartDialog() {
    final name = TextEditingController();
    final qty = TextEditingController();
    final price = TextEditingController();

    _showStyledDialog(
      title: "Add Replaced Part",
      content: [
        _buildDialogField(name, "Part Name", Icons.settings_rounded),
        _buildDialogField(qty, "Quantity", Icons.numbers_rounded, isNumber: true),
        _buildDialogField(price, "Unit Price (₹)", Icons.sell_rounded, isNumber: true),
      ],
      onSave: () async {
        final q = int.tryParse(qty.text);
        final p = double.tryParse(price.text);
        if (name.text.trim().isEmpty || q == null || p == null) return;

        setState(() => loading = true);
        Navigator.pop(context);
        await ApiService.addJobPart(job['id'], name.text.trim(), q, p);
        await refreshJob();
        setState(() => loading = false);
      },
    );
  }

  void _showStyledDialog({required String title, required List<Widget> content, required VoidCallback onSave}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: content)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: brandGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: onSave, 
            child: const Text("Save Item", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(TextEditingController ctrl, String label, IconData icon, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20, color: brandGreen),
          filled: true,
          fillColor: backgroundDark,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildEmptyNotice(String msg) => Padding(
    padding: const EdgeInsets.only(left: 4, top: 4),
    child: Text(msg, style: const TextStyle(color: Colors.white10, fontSize: 13, fontStyle: FontStyle.italic)),
  );
}