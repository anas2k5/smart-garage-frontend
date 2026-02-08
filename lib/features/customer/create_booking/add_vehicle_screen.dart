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

  // Unified Design Colors
  static const Color brandGreen = Color(0xFF00B562);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color backgroundDark = Color(0xFF121212);

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

      if (!mounted) return;
      Navigator.pop(context, true); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            e.toString().contains("exists")
                ? "Vehicle already registered"
                : "Error adding vehicle. Try again.",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
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
          title: const Text("Register Vehicle", style: TextStyle(fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("VEHICLE DETAILS", 
                  style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                const SizedBox(height: 20),

                _buildTextField(
                  controller: _plateController,
                  label: "Plate Number",
                  hint: "e.g. MH 12 AB 1234",
                  icon: Icons.badge_outlined,
                  caps: TextCapitalization.characters,
                  validator: (v) => v == null || v.isEmpty ? "Required" : null,
                ),

                const SizedBox(height: 16),

                _buildTextField(
                  controller: _makeController,
                  label: "Manufacturer",
                  hint: "e.g. Hyundai",
                  icon: Icons.factory_outlined,
                  validator: (v) => v == null || v.isEmpty ? "Required" : null,
                ),

                const SizedBox(height: 16),

                _buildTextField(
                  controller: _modelController,
                  label: "Model",
                  hint: "e.g. i20 Asta",
                  icon: Icons.directions_car_filled_outlined,
                  validator: (v) => v == null || v.isEmpty ? "Required" : null,
                ),

                const SizedBox(height: 40),

                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextCapitalization caps = TextCapitalization.words,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: const TextStyle(fontSize: 14, color: Colors.white70)),
        ),
        TextFormField(
          controller: controller,
          textCapitalization: caps,
          validator: validator,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
            prefixIcon: Icon(icon, color: brandGreen, size: 20),
            filled: true,
            fillColor: surfaceDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: brandGreen, width: 1),
            ),
            errorStyle: const TextStyle(color: Colors.redAccent),
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        onPressed: _loading ? null : _submit,
        child: _loading
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text("REGISTER VEHICLE", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
    );
  }
}