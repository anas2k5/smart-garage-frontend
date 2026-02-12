import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../models/mechanic.dart';

class EditMechanicScreen extends StatefulWidget {
  final Mechanic mechanic;

  const EditMechanicScreen({super.key, required this.mechanic});

  @override
  State<EditMechanicScreen> createState() =>
      _EditMechanicScreenState();
}

class _EditMechanicScreenState
    extends State<EditMechanicScreen> {

  static const brandGreen = Color(0xFF00B562);
  static const surfaceDark = Color(0xFF1C1C1E);

  late TextEditingController name;
  late TextEditingController phone;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.mechanic.name);
    phone = TextEditingController(text: widget.mechanic.phone);
  }

  Future<void> _update() async {
    await ApiService.updateMechanic(
      widget.mechanic.id,
      {
        "name": name.text,
        "phone": phone.text,
      },
    );

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Edit Mechanic")),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _field(name, "Mechanic Name"),
              _field(phone, "Phone Number"),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: brandGreen),
                onPressed: _update,
                child: const Text("Update"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String l) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: l,
          filled: true,
          fillColor: surfaceDark,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
