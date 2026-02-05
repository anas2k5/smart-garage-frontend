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

  @override
  void initState() {
    super.initState();
    _loadGarages();
  }

  void _loadGarages() {
    _future = ApiService.getOwnerGarages();
  }

  // ================= EDIT GARAGE =================

  void _editGarage(Garage g) {
    final nameCtrl = TextEditingController(text: g.name);
    final addressCtrl = TextEditingController(text: g.address);
    final phoneCtrl = TextEditingController(text: g.phone);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Garage"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Garage Name"),
            ),
            TextField(
              controller: addressCtrl,
              decoration: const InputDecoration(labelText: "Address"),
            ),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: "Phone"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await ApiService.updateGarage(
                garageId: g.id,
                name: nameCtrl.text,
                address: addressCtrl.text,
                phone: phoneCtrl.text,
              );

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Garage updated")),
              );

              setState(_loadGarages);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // ================= DELETE GARAGE =================

  void _deleteGarage(Garage g) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Garage"),
        content: Text(
          "Are you sure you want to delete '${g.name}'?\n\nThis action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.pop(context);

              await ApiService.deleteGarage(g.id);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Garage deleted")),
              );

              setState(_loadGarages);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("My Garages")),
      body: FutureBuilder<List<Garage>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Failed to load garages"));
          }

          final garages = snapshot.data ?? [];

          if (garages.isEmpty) {
            return const Center(child: Text("No garages found"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: garages.length,
            itemBuilder: (context, index) {
              final g = garages[index];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

                  leading: CircleAvatar(
                    backgroundColor:
                        theme.colorScheme.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.garage,
                      color: theme.colorScheme.primary,
                    ),
                  ),

                  title: Text(
                    g.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  subtitle: Text(g.address),

                  // 🔥 EDIT + DELETE MENU
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == "edit") {
                        _editGarage(g);
                      } else if (value == "delete") {
                        _deleteGarage(g);
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: "edit",
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text("Edit"),
                        ),
                      ),
                      const PopupMenuItem(
                        value: "delete",
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text("Delete"),
                        ),
                      ),
                    ],
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            OwnerGarageActionsScreen(garage: g),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
