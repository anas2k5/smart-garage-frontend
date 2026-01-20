import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../models/garage.dart';
import '../../../models/vehicle.dart';
import 'select_service_screen.dart';

class SelectGarageScreen extends StatefulWidget {
  final Vehicle selectedVehicle;

  const SelectGarageScreen({
    super.key,
    required this.selectedVehicle,
  });

  @override
  State<SelectGarageScreen> createState() => _SelectGarageScreenState();
}

class _SelectGarageScreenState extends State<SelectGarageScreen> {
  late Future<List<Garage>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.getGarages();
  }

  // ================= STEP HEADER =================
  Widget _stepHeader() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: const [
            _StepChip(title: "Vehicle", active: true),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 14),
            SizedBox(width: 8),
            _StepChip(title: "Garage", active: true),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 14),
            SizedBox(width: 8),
            _StepChip(title: "Service"),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 14),
            SizedBox(width: 8),
            _StepChip(title: "Confirm"),
          ],
        ),
      ),
    );
  }

  // ================= GARAGE CARD =================
  Widget _garageCard(Garage g) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: const CircleAvatar(
          backgroundColor: Colors.deepPurple,
          child: Icon(Icons.store, color: Colors.white),
        ),
        title: Text(
          g.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            g.address,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SelectServiceScreen(
                garage: g,
                vehicle: widget.selectedVehicle,
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= MAIN UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Garage'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Garage>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Failed to load garages',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          final garages = snapshot.data ?? [];

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _stepHeader(),
                  const SizedBox(height: 16),

                  Expanded(
                    child: garages.isEmpty
                        ? const Center(
                            child: Text(
                              'No garages available',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: garages.length,
                            itemBuilder: (context, index) {
                              return _garageCard(
                                garages[index],
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ================= STEP CHIP =================
class _StepChip extends StatelessWidget {
  final String title;
  final bool active;

  const _StepChip({
    required this.title,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: active ? Colors.deepPurple : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.deepPurple,
          width: 1.5,
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Text(
        title,
        style: TextStyle(
          color: active ? Colors.white : Colors.deepPurple,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
