import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../models/garage.dart';
import '../../models/mechanic.dart';
import 'add_mechanic_screen.dart';
import 'edit_mechanic_screen.dart'; // ✅ NEW

class OwnerMechanicsScreen extends StatefulWidget {
  const OwnerMechanicsScreen({super.key});

  @override
  State<OwnerMechanicsScreen> createState() => _OwnerMechanicsScreenState();
}

class _OwnerMechanicsScreenState extends State<OwnerMechanicsScreen> {
  static const brandGreen = Color(0xFF00B562);
  static const surfaceDark = Color(0xFF1C1C1E);
  static const backgroundDark = Color(0xFF121212);

  List<Garage> garages = [];
  Garage? selectedGarage;
  List<Mechanic> mechanics = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      garages = await ApiService.getOwnerGarages();
      if (garages.isNotEmpty) {
        selectedGarage = garages.first;
        await _loadMechanics();
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _loadMechanics() async {
    if (selectedGarage == null) return;
    final data =
        await ApiService.getMechanicsByGarage(selectedGarage!.id);
    if (mounted) setState(() => mechanics = data);
  }

  // ================= DELETE =================

  Future<void> _delete(Mechanic m) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text("Remove Staff",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            "Are you sure you want to remove ${m.name} from the team?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCEL",
                style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("DELETE"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await ApiService.deleteMechanic(m.id);
    await _loadMechanics();
  }

  // ================= EDIT =================

  Future<void> _edit(Mechanic m) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditMechanicScreen(mechanic: m),
      ),
    );

    if (updated == true) _loadMechanics();
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundDark,
        appBarTheme:
            const AppBarTheme(backgroundColor: backgroundDark, elevation: 0),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("TEAM MANAGEMENT",
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 2,
                  color: brandGreen)),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: brandGreen,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.person_add_alt_1_rounded),
          onPressed: () async {
            if (selectedGarage == null) return;
            final added = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    AddMechanicScreen(garage: selectedGarage!),
              ),
            );
            if (added == true) _loadMechanics();
          },
        ),
        body: loading
            ? const Center(
                child: CircularProgressIndicator(color: brandGreen))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGarageSelector(),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
                    child: Text("TECHNICAL STAFF",
                        style: TextStyle(
                            color: Colors.white24,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5)),
                  ),
                  Expanded(
                    child: mechanics.isEmpty
                        ? _buildEmptyState()
                        : _buildMechanicList(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildGarageSelector() {
    if (garages.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: garages.length,
        itemBuilder: (context, index) {
          final g = garages[index];
          final isSelected = selectedGarage?.id == g.id;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(g.name),
              selected: isSelected,
              onSelected: (val) {
                if (val) {
                  setState(() => selectedGarage = g);
                  _loadMechanics();
                }
              },
              selectedColor: brandGreen,
              backgroundColor: surfaceDark,
              showCheckmark: false,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
      ),
    );
  }

  // ================= LIST =================

  Widget _buildMechanicList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mechanics.length,
      itemBuilder: (_, i) {
        final m = mechanics[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: surfaceDark,
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: const BoxDecoration(
                border:
                    Border(left: BorderSide(color: brandGreen, width: 4)),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: brandGreen.withOpacity(0.1),
                  child: const Icon(Icons.engineering_rounded,
                      color: brandGreen),
                ),
                title: Text(m.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(m.phone,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 13)),

                // 🔥 EDIT + DELETE
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_rounded,
                          color: Colors.blueAccent, size: 20),
                      onPressed: () => _edit(m),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_sweep_rounded,
                          color: Colors.redAccent, size: 22),
                      onPressed: () => _delete(m),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded,
              size: 64, color: Colors.white10),
          SizedBox(height: 16),
          Text("No technical staff found",
              style: TextStyle(color: Colors.white38)),
        ],
      ),
    );
  }
}
