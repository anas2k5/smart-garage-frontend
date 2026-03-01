import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../models/garage.dart';
import '../../models/garage_service.dart';

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
  late int _currentSlotCapacity;

  // Global Brand Palette
  static const Color brandGreen = Color(0xFF00B562);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color backgroundDark = Color(0xFF121212);

  @override
  void initState() {
    super.initState();
    _currentSlotCapacity = widget.garage.maxBookingsPerSlot;
    _load();
  }

  void _load() {
    _future = ApiService.getGarageServices(widget.garage.id);
  }

  void _reload() {
    setState(_load);
  }

  // ================= SLOT CAPACITY EDIT =================

  void _editSlotCapacity() {
    final ctrl =
        TextEditingController(text: _currentSlotCapacity.toString());

    showDialog(
      context: context,
      builder: (_) => Theme(
        data: ThemeData.dark().copyWith(useMaterial3: true),
        child: AlertDialog(
          backgroundColor: surfaceDark,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24)),
          title: const Text("Edit Slot Capacity",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Max bookings per slot",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel",
                  style: TextStyle(color: Colors.white38)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: brandGreen,
                  foregroundColor: Colors.white),
              onPressed: () async {
                final newValue =
                    int.tryParse(ctrl.text.trim());

                if (newValue == null || newValue < 1) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                        content:
                            Text("Enter valid number")),
                  );
                  return;
                }

                await ApiService.updateSlotCapacity(
                  garageId: widget.garage.id,
                  maxBookingsPerSlot: newValue,
                );

                if (!mounted) return;

                Navigator.pop(context);

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    backgroundColor: brandGreen,
                    content:
                        Text("Slot capacity updated"),
                  ),
                );

                setState(() {
                  _currentSlotCapacity = newValue;
                });
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  // ================= MODERN SERVICE DIALOG =================

  void _openServiceDialog({GarageService? service}) {
    final nameCtrl =
        TextEditingController(text: service?.name ?? '');
    final descCtrl =
        TextEditingController(text: service?.description ?? '');
    final priceCtrl =
        TextEditingController(text: service?.price.toString() ?? '');

    showDialog(
      context: context,
      builder: (_) => Theme(
        data: ThemeData.dark().copyWith(useMaterial3: true),
        child: AlertDialog(
          backgroundColor: surfaceDark,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24)),
          title: Text(
              service == null
                  ? "Add New Service"
                  : "Edit Service",
              style: const TextStyle(
                  fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogField(nameCtrl,
                    "Service Name", Icons.settings_suggest_rounded),
                const SizedBox(height: 16),
                _buildDialogField(descCtrl,
                    "Description", Icons.description_rounded),
                const SizedBox(height: 16),
                _buildDialogField(priceCtrl,
                    "Price", Icons.payments_rounded,
                    type: TextInputType.number,
                    prefix: "₹ "),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text("Cancel",
                  style: TextStyle(color: Colors.white38)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: brandGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final price =
                    double.tryParse(priceCtrl.text);
                if (price == null) return;

                if (service == null) {
                  await ApiService.addGarageService(
                    garageId:
                        widget.garage.id,
                    name:
                        nameCtrl.text.trim(),
                    description:
                        descCtrl.text.trim(),
                    price: price,
                  );
                } else {
                  await ApiService.updateGarageService(
                    serviceId:
                        service.id,
                    name:
                        nameCtrl.text.trim(),
                    description:
                        descCtrl.text.trim(),
                    price: price,
                  );
                }

                if (!mounted) return;
                Navigator.pop(context);
                _reload();
              },
              child: const Text("Save Service"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogField(
      TextEditingController ctrl,
      String label,
      IconData icon,
      {TextInputType type =
          TextInputType.text,
      String? prefix}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        prefixIcon:
            Icon(icon, color: brandGreen, size: 20),
        filled: true,
        fillColor: backgroundDark,
        border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(12),
            borderSide: BorderSide.none),
      ),
    );
  }

  // ================= MODERN DEACTIVATE =================

  void _confirmDeactivate(
      GarageService service) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(24)),
        title: const Text(
            "Deactivate Service?"),
        content: Text(
            "Are you sure you want to deactivate '${service.name}'?\n\nThis will hide the service from your customers."),
        actions: [
          TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child:
                  const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.redAccent),
            onPressed: () async {
              await ApiService
                  .deactivateGarageService(
                      service.id);
              if (!mounted) return;
              Navigator.pop(context);
              _reload();
            },
            child:
                const Text("Deactivate"),
          ),
        ],
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        useMaterial3: true,
        scaffoldBackgroundColor:
            backgroundDark,
        appBarTheme: const AppBarTheme(
            backgroundColor:
                backgroundDark,
            elevation: 0),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
              "Catalog Management",
              style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 18)),
          leading: IconButton(
            icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 20),
            onPressed: () =>
                Navigator.pop(context),
          ),
        ),
        floatingActionButton:
            FloatingActionButton.extended(
          backgroundColor:
              brandGreen,
          foregroundColor:
              Colors.white,
          onPressed: () =>
              _openServiceDialog(),
          icon: const Icon(
              Icons
                  .add_circle_outline_rounded),
          label: const Text(
              "New Service",
              style: TextStyle(
                  fontWeight:
                      FontWeight.bold)),
        ),
        body: Column(
          children: [

            // SLOT CAPACITY CARD (UNCHANGED STYLE)
            Container(
              margin:
                  const EdgeInsets.all(16),
              padding:
                  const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surfaceDark,
                borderRadius:
                    BorderRadius.circular(20),
                border: Border.all(
                    color: Colors.white
                        .withOpacity(0.05)),
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      const Text(
                        "Slot Capacity",
                        style: TextStyle(
                          color:
                              Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(
                          height: 6),
                      Text(
                        _currentSlotCapacity
                            .toString(),
                        style:
                            const TextStyle(
                          color: brandGreen,
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                        Icons.edit_rounded,
                        color:
                            Colors.white38),
                    onPressed:
                        _editSlotCapacity,
                  )
                ],
              ),
            ),

            Expanded(
              child:
                  FutureBuilder<List<
                      GarageService>>(
                future: _future,
                builder:
                    (context, snapshot) {
                  if (snapshot
                          .connectionState ==
                      ConnectionState
                          .waiting) {
                    return const Center(
                        child:
                            CircularProgressIndicator(
                                color:
                                    brandGreen));
                  }

                  if (snapshot.hasError) {
                    return const Center(
                        child: Text(
                            "Error loading service catalog"));
                  }

                  final services =
                      snapshot.data ?? [];
                  if (services.isEmpty)
                    return _buildEmptyState();

                  return RefreshIndicator(
                    color: brandGreen,
                    onRefresh:
                        () async =>
                            _reload(),
                    child:
                        ListView.builder(
                      padding:
                          const EdgeInsets
                              .fromLTRB(
                                  16,
                                  0,
                                  16,
                                  80),
                      itemCount:
                          services.length,
                      itemBuilder:
                          (_, i) =>
                              _buildServiceCard(
                                  services[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(
      GarageService s) {
    return Container(
      margin:
          const EdgeInsets.only(
              bottom: 16),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
            color: Colors.white
                .withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets
                .symmetric(
                    horizontal: 20,
                    vertical: 8),
        title: Text(s.name,
            style: const TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 16)),
        subtitle: Padding(
          padding:
              const EdgeInsets.only(
                  top: 4),
          child: Text(
              "₹${s.price.toStringAsFixed(0)}",
              style: const TextStyle(
                  color: brandGreen,
                  fontWeight:
                      FontWeight.w900,
                  fontSize: 14)),
        ),
        trailing: Row(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                  Icons.edit_note_rounded,
                  color:
                      Colors.white38),
              onPressed: () =>
                  _openServiceDialog(
                      service: s),
            ),
            IconButton(
              icon: const Icon(
                  Icons
                      .remove_circle_outline_rounded,
                  color:
                      Colors.redAccent,
                  size: 20),
              onPressed: () =>
                  _confirmDeactivate(s),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment
                .center,
        children: [
          Icon(Icons.auto_fix_off_rounded,
              size: 64,
              color:
                  Colors.white10),
          SizedBox(height: 16),
          Text("Catalog is empty",
              style: TextStyle(
                  color:
                      Colors.white38)),
        ],
      ),
    );
  }
}