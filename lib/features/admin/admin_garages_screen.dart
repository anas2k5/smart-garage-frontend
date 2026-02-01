import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';

class AdminGaragesScreen extends StatefulWidget {
  const AdminGaragesScreen({super.key});

  @override
  State<AdminGaragesScreen> createState() => _AdminGaragesScreenState();
}

class _AdminGaragesScreenState extends State<AdminGaragesScreen> {
  List garages = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadGarages();
  }

  Future<void> _loadGarages() async {
    try {
      final data = await ApiService.getAllGaragesAdmin();
      setState(() {
        garages = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Future<void> _toggleGarage(int id) async {
    try {
      await ApiService.toggleGarage(id);
      await _loadGarages();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Garage status updated")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update garage")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Garage Management")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: garages.length,
              itemBuilder: (context, index) {
                final g = garages[index];
                final isActive = g["active"] == true;

                return ListTile(
                  leading: const Icon(Icons.store),
                  title: Text(g["name"]),
                  subtitle: Text("Active: $isActive"),
                  trailing: Switch(
                    value: isActive,
                    onChanged: (_) => _toggleGarage(g["id"]),
                  ),
                  onTap: () => _toggleGarage(g["id"]),
                );
              },
            ),
    );
  }
}
