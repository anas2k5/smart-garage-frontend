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
                return ListTile(
                  leading: const Icon(Icons.store),
                  title: Text(g["name"]),
                  subtitle: Text("Active: ${g["active"]}"),
                );
              },
            ),
    );
  }
}
