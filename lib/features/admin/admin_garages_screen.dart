import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';

class AdminGaragesScreen extends StatefulWidget {
  const AdminGaragesScreen({super.key});

  @override
  State<AdminGaragesScreen> createState() => _AdminGaragesScreenState();
}

class _AdminGaragesScreenState extends State<AdminGaragesScreen> {
  List<Map<String, dynamic>> garages = [];
  List<Map<String, dynamic>> filteredGarages = [];

  bool loading = true;
  bool processing = false;

  String searchQuery = "";
  String statusFilter = "ALL";

  // Global Brand Palette
  static const Color brandGreen = Color(0xFF00B562);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color backgroundDark = Color(0xFF121212);

  @override
  void initState() {
    super.initState();
    _loadGarages();
  }

  Future<void> _loadGarages() async {
    try {
      setState(() => loading = true);
      final data = await ApiService.getAllGaragesAdmin();
      final list = List<Map<String, dynamic>>.from(data);

      if (!mounted) return;

      setState(() {
        garages = list;
        _applyFilters();
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.redAccent, content: Text("Network sync failed")),
      );
    }
  }

  void _applyFilters() {
    filteredGarages = garages.where((g) {
      final name = (g["name"] ?? "").toString().toLowerCase();
      final isActive = g["active"] == true;
      final matchesSearch = name.contains(searchQuery.toLowerCase());
      final matchesStatus = statusFilter == "ALL" ||
          (statusFilter == "ACTIVE" && isActive) ||
          (statusFilter == "INACTIVE" && !isActive);
      return matchesSearch && matchesStatus;
    }).toList();
  }

  Future<void> _confirmToggle(Map<String, dynamic> garage) async {
    final isActive = garage["active"] == true;
    final action = isActive ? "Deactivate" : "Activate";

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("$action Branch?", style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Proceed with $action for '${garage["name"]}'? Customers will be affected immediately."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: isActive ? Colors.redAccent : brandGreen),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(action, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) _toggleGarage(garage["id"]);
  }

  Future<void> _toggleGarage(int id) async {
    if (processing) return;
    try {
      setState(() => processing = true);
      await ApiService.toggleGarage(id);
      await _loadGarages();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: brandGreen, content: Text("Branch status updated")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.redAccent, content: Text("Status update failed")));
    } finally {
      if (mounted) setState(() => processing = false);
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
          title: const Text("Garage Oversight", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          centerTitle: true,
        ),
        body: Column(
          children: [
            _buildSearchAndFilters(),
            Expanded(
              child: RefreshIndicator(
                color: brandGreen,
                onRefresh: _loadGarages,
                child: loading
                    ? const Center(child: CircularProgressIndicator(color: brandGreen))
                    : _buildList(),
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
              hintText: "Search workshops...",
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded, color: brandGreen, size: 20),
              filled: true,
              fillColor: surfaceDark,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: ["ALL", "ACTIVE", "INACTIVE"].map((s) => _buildFilterChip(s)).toList(),
          ),
        ],
      ),
    );
  }

 // Update the ChoiceChip shape inside _buildFilterChip method:
Widget _buildFilterChip(String label) {
  final isSelected = statusFilter == label;
  return Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      selected: isSelected,
      onSelected: (_) => setState(() { statusFilter = label; _applyFilters(); }),
      selectedColor: brandGreen,
      backgroundColor: surfaceDark,
      showCheckmark: false,
      // FIXED PARAMETER NAME
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide.none),
    ),
  );
}

  Widget _buildList() {
    if (filteredGarages.isEmpty) {
      return const Center(child: Text("No workshops found", style: TextStyle(color: Colors.white24)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredGarages.length,
      itemBuilder: (context, index) => _buildGarageCard(filteredGarages[index]),
    );
  }

  Widget _buildGarageCard(Map<String, dynamic> g) {
    final bool isActive = g["active"] == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: (isActive ? brandGreen : Colors.redAccent).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.storefront_rounded, color: isActive ? brandGreen : Colors.redAccent, size: 22),
        ),
        title: Text(g["name"] ?? "New Workshop", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(g["address"] ?? "Location pending", style: const TextStyle(color: Colors.white30, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        trailing: Transform.scale(
          scale: 0.8,
          child: Switch(
            value: isActive,
            activeColor: brandGreen,
            onChanged: processing ? null : (_) => _confirmToggle(g),
          ),
        ),
      ),
    );
  }
}