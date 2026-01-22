import 'package:flutter/material.dart';
import 'package:smart_garage_app/core/services/api_service.dart';
import 'package:smart_garage_app/models/garage.dart';
import 'package:smart_garage_app/models/garage_service.dart';

class OwnerManageServicesScreen extends StatefulWidget {
  final Garage garage;

  const OwnerManageServicesScreen({super.key, required this.garage});

  @override
  State<OwnerManageServicesScreen> createState() =>
      _OwnerManageServicesScreenState();
}

class _OwnerManageServicesScreenState
    extends State<OwnerManageServicesScreen> {
  late Future<List<GarageService>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = ApiService.getGarageServices(widget.garage.id);
  }

  void _reload() {
    setState(_load);
  }

  // ================= SERVICE DIALOG =================

  void _openServiceDialog({GarageService? service}) {
    final nameCtrl =
        TextEditingController(text: service?.name ?? '');
    final descCtrl =
        TextEditingController(text: service?.description ?? '');
    final priceCtrl =
        TextEditingController(text: service?.price.toString() ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(service == null ? "Add Service" : "Edit Service"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Service Name"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Price",
                prefixText: "₹ ",
              ),
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
              final price = double.tryParse(priceCtrl.text);
              if (price == null) return;

              if (service == null) {
                await ApiService.addGarageService(
                  garageId: widget.garage.id,
                  name: nameCtrl.text,
                  description: descCtrl.text,
                  price: price,
                );
              } else {
                await ApiService.updateGarageService(
                  serviceId: service.id,
                  name: nameCtrl.text,
                  description: descCtrl.text,
                  price: price,
                );
              }

              Navigator.pop(context);
              _reload();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // ================= DEACTIVATE =================

  void _confirmDeactivate(GarageService service) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text("Deactivate Service"),
        content: Text(
          "Are you sure you want to deactivate '${service.name}'?\n\nCustomers will no longer see this service.",
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
              await ApiService.deactivateGarageService(service.id);
              Navigator.pop(context);
              _reload();
            },
            child: const Text("Deactivate"),
          ),
        ],
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Services")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openServiceDialog(),
        icon: const Icon(Icons.add),
        label: const Text("Add Service"),
      ),
      body: FutureBuilder<List<GarageService>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Failed to load services"));
          }

          final services = snapshot.data ?? [];

          if (services.isEmpty) {
            return const Center(child: Text("No services added"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: services.length,
            itemBuilder: (_, i) {
              final s = services[i];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  title: Text(
                    s.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("₹${s.price.toStringAsFixed(2)}"),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () =>
                            _openServiceDialog(service: s),
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.block, color: Colors.red),
                        onPressed: () => _confirmDeactivate(s),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
