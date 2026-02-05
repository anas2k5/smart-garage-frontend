import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';
import '../../models/garage.dart';

class AddMechanicScreen extends StatefulWidget {
  final Garage garage;

  const AddMechanicScreen({
    super.key,
    required this.garage,
  });

  @override
  State<AddMechanicScreen> createState() =>
      _AddMechanicScreenState();
}

class _AddMechanicScreenState
    extends State<AddMechanicScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;

  // ================= REGISTER USER =================
  Future<int> _registerUser() async {
    final response = await http.post(
      Uri.parse(ApiConstants.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "fullName": _nameController.text,
        "email": _emailController.text,
        "password": _passwordController.text,
        "role": "MECHANIC",
      }),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return json["userId"];
    } else {
      throw Exception(
          "User creation failed\n${response.body}");
    }
  }

  // ================= CREATE MECHANIC =================
  Future<void> _createMechanic(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/mechanics'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },

      // 🔥 FIXED STRUCTURE
      body: jsonEncode({
        "name": _nameController.text,
        "phone": _phoneController.text,

        "user": {
          "id": userId,
        },

        "garage": {
          "id": widget.garage.id,
        }
      }),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception(
          "Mechanic creation failed\n${response.body}");
    }
  }

  // ================= SUBMIT =================
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final userId = await _registerUser();
      await _createMechanic(userId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Mechanic created successfully ✅"),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  // ================= DISPOSE =================
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Mechanic"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                "Garage: ${widget.garage.name}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Mechanic Name",
                ),
                validator: (v) =>
                    v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "Phone",
                ),
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email (Login ID)",
                ),
                validator: (v) =>
                    v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: "Temporary Password",
                ),
                obscureText: true,
                validator: (v) =>
                    v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed:
                    _loading ? null : _submit,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text("Create Mechanic"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
