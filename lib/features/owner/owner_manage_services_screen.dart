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
    _future = ApiService.getGarageServices(widget.garage.id);
  }

  void _reload() {
    setState(() {
      _future = ApiService.getGarageServices(widget.garage.id);
    });
  }

  void _openAddServiceDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Service"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Description")),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Price"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await ApiService.addGarageService(
                garageId: widget.garage.id,
                name: nameCtrl.text,
                description: descCtrl.text,
                price: double.parse(priceCtrl.text),
              );
              Navigator.pop(context);
              _reload();
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Services")),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddServiceDialog,
        child: const Icon(Icons.add),
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
            itemCount: services.length,
            itemBuilder: (_, i) {
              final s = services[i];
              return ListTile(
                title: Text(s.name),
                subtitle: Text("₹${s.price}"),
              );
            },
          );
        },
      ),
    );
  }
}
