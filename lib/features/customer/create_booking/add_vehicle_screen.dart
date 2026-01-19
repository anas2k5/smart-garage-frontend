import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  final _plateController = TextEditingController();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _plateController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_loading) return;

    setState(() => _loading = true);

    try {
      await ApiService.addVehicle(
        plateNumber: _plateController.text.trim().toUpperCase(),
        make: _makeController.text.trim(),
        model: _modelController.text.trim(),
      );

      Navigator.pop(context, true); // ✅ success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().contains("exists")
                ? "Vehicle already exists"
                : "Failed to add vehicle",
          ),
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Vehicle")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 🚗 PLATE NUMBER
              TextFormField(
                controller: _plateController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: "Plate Number",
                  prefixIcon: Icon(Icons.confirmation_number),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Enter plate number" : null,
              ),

              const SizedBox(height: 12),

              // 🏭 MAKE
              TextFormField(
                controller: _makeController,
                decoration: const InputDecoration(
                  labelText: "Make (e.g. Honda)",
                  prefixIcon: Icon(Icons.directions_car),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Enter vehicle make" : null,
              ),

              const SizedBox(height: 12),

              // 🚘 MODEL
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: "Model (e.g. City)",
                  prefixIcon: Icon(Icons.car_repair),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Enter vehicle model" : null,
              ),

              const SizedBox(height: 24),

              // 💾 SAVE BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Save Vehicle"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
