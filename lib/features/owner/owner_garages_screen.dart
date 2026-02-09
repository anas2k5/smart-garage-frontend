import 'package:flutter/material.dart';
import 'package:smart_garage_app/core/services/api_service.dart';
import 'package:smart_garage_app/models/garage.dart';
import 'owner_garage_actions_screen.dart';

class OwnerGaragesScreen extends StatefulWidget {
  const OwnerGaragesScreen({super.key});

  @override
  State<OwnerGaragesScreen> createState() => _OwnerGaragesScreenState();
}

class _OwnerGaragesScreenState extends State<OwnerGaragesScreen> {
  late Future<List<Garage>> _future;

  // Design System Colors
  static const Color brandGreen = Color(0xFF00B562);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color backgroundDark = Color(0xFF121212);

  @override
  void initState() {
    super.initState();
    _loadGarages();
  }

  void _loadGarages() {
    setState(() {
      _future = ApiService.getOwnerGarages();
    });
  }

  // ================= MODERN EDIT DIALOG =================
  void _editGarage(Garage g) {
    final nameCtrl = TextEditingController(text: g.name);
    final addressCtrl = TextEditingController(text: g.address);
    final phoneCtrl = TextEditingController(text: g.phone);

    showDialog(
      context: context,
      builder: (_) => Theme(
        data: ThemeData.dark().copyWith(useMaterial3: true),
        child: AlertDialog(
          backgroundColor: surfaceDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text("Edit Garage Details", style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogField(nameCtrl, "Garage Name", Icons.storefront_rounded),
                const SizedBox(height: 16),
                _buildDialogField(addressCtrl, "Address", Icons.location_on_rounded),
                const SizedBox(height: 16),
                _buildDialogField(phoneCtrl, "Phone Number", Icons.phone_rounded, type: TextInputType.phone),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.white38)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: brandGreen, foregroundColor: Colors.white),
              onPressed: () async {
                await ApiService.updateGarage(
                  garageId: g.id,
                  name: nameCtrl.text.trim(),
                  address: addressCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                );
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(backgroundColor: brandGreen, content: Text("✅ Garage updated successfully")),
                );
                _loadGarages();
              },
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogField(TextEditingController ctrl, String label, IconData icon, {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: brandGreen, size: 20),
        filled: true,
        fillColor: backgroundDark,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  // ================= MODERN DELETE DIALOG =================
  void _deleteGarage(Garage g) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: surfaceDark,
        title: const Text("Delete Garage?"),
        content: Text("Are you sure you want to delete '${g.name}'? This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(context);
              await ApiService.deleteGarage(g.id);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Garage deleted")));
              _loadGarages();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
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
          title: const Text("My Garages", style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: FutureBuilder<List<Garage>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: brandGreen));
            }
            if (snapshot.hasError) {
              return const Center(child: Text("Error fetching garages"));
            }

            final garages = snapshot.data ?? [];
            if (garages.isEmpty) return _buildEmptyState();

            return RefreshIndicator(
              color: brandGreen,
              onRefresh: () async => _loadGarages(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: garages.length,
                itemBuilder: (context, index) => _buildGarageItem(garages[index]),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGarageItem(Garage g) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: brandGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.home_repair_service_rounded, color: brandGreen),
        ),
        title: Text(g.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(g.address, style: const TextStyle(color: Colors.white38, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded, color: Colors.white24),
          color: surfaceDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onSelected: (value) {
            if (value == "edit") _editGarage(g);
            if (value == "delete") _deleteGarage(g);
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: "edit", child: Row(children: [Icon(Icons.edit_rounded, size: 18), SizedBox(width: 12), Text("Edit")])),
            const PopupMenuItem(value: "delete", child: Row(children: [Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18), SizedBox(width: 12), Text("Delete", style: TextStyle(color: Colors.redAccent))])),
          ],
        ),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => OwnerGarageActionsScreen(garage: g)));
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.storefront_rounded, size: 64, color: Colors.white10),
          SizedBox(height: 16),
          Text("No garages registered", style: TextStyle(color: Colors.white38)),
        ],
      ),
    );
  }
}