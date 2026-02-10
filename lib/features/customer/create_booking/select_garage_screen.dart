import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/api_service.dart';
import '../../../models/garage.dart';
import '../../../models/vehicle.dart';
import 'select_service_screen.dart';

class SelectGarageScreen extends StatefulWidget {
  final Vehicle selectedVehicle;
  const SelectGarageScreen({super.key, required this.selectedVehicle});

  @override
  State<SelectGarageScreen> createState() => _SelectGarageScreenState();
}

class _SelectGarageScreenState extends State<SelectGarageScreen> {
  late Future<List<Garage>> _future;
  List<Garage> _allGarages = [];
  List<Garage> _filteredGarages = [];
  final TextEditingController _searchController = TextEditingController();

  Position? currentPosition;

  static const Color brandGreen = Color(0xFF00B562);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color backgroundDark = Color(0xFF121212);

  @override
  void initState() {
    super.initState();
    _future = ApiService.getGarages();
    _getLocation();
  }

  /// 📍 Get Customer Location
  Future<void> _getLocation() async {
    bool serviceEnabled =
        await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission =
        await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) return;

    currentPosition =
        await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

    setState(() {});
  }

  void _filterGarages(String query) {
    setState(() {
      _filteredGarages = _allGarages
          .where((g) =>
              g.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark()
          .copyWith(useMaterial3: true, scaffoldBackgroundColor: backgroundDark),
      child: Scaffold(
        appBar: AppBar(title: const Text("Choose Garage"), centerTitle: true),
        body: FutureBuilder<List<Garage>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: brandGreen));
            }

            if (snapshot.hasError) {
              return const Center(child: Text("Error loading garages"));
            }

            if (_allGarages.isEmpty) {
              _allGarages = snapshot.data ?? [];
              _filteredGarages = _allGarages;
            }

            return SafeArea(
              child: Column(
                children: [
                  _buildStepHeader(),
                  Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildSearchBar()),
                  Expanded(
                    child: _filteredGarages.isEmpty
                        ? const Center(child: Text("No workshops found"))
                        : ListView.builder(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredGarages.length,
                            itemBuilder: (context, index) =>
                                _buildGarageCard(
                                    _filteredGarages[index]),
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStepHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: surfaceDark,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _StepChip(title: "Vehicle", isDone: true),
          _StepLine(isDone: true),
          _StepChip(title: "Garage", isActive: true),
          _StepLine(),
          _StepChip(title: "Service"),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: _filterGarages,
      decoration: InputDecoration(
        hintText: "Search workshop...",
        prefixIcon: const Icon(Icons.search, color: brandGreen),
        filled: true,
        fillColor: surfaceDark,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
      ),
    );
  }

  /// 🏭 GARAGE CARD (Distance + Directions — UI SAFE)
  Widget _buildGarageCard(Garage g) {
    double? distanceKm;

    if (currentPosition != null &&
        g.latitude != null &&
        g.longitude != null) {
      distanceKm = g.distanceFrom(
        currentPosition!.latitude,
        currentPosition!.longitude,
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: surfaceDark,
          borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        leading:
            const Icon(Icons.home_repair_service, color: brandGreen),
        title: Text(g.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          distanceKm != null
              ? "${g.address} • ${distanceKm.toStringAsFixed(1)} km away"
              : g.address,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        /// 📍 Directions icon (no UI break)
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (g.latitude != null && g.longitude != null)
              IconButton(
                icon: const Icon(Icons.directions, color: brandGreen),
                onPressed: () => _openDirections(g),
              ),
            const Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),

        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SelectServiceScreen(
                garage: g, vehicle: widget.selectedVehicle),
          ),
        ),
      ),
    );
  }

  /// 🧭 Open Google Maps Directions
  Future<void> _openDirections(Garage g) async {
    final url =
        "https://www.google.com/maps/dir/?api=1&destination=${g.latitude},${g.longitude}";

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication);
    }
  }
}

class _StepChip extends StatelessWidget {
  final String title;
  final bool isActive;
  final bool isDone;
  const _StepChip(
      {required this.title, this.isActive = false, this.isDone = false});

  @override
  Widget build(BuildContext context) => Column(children: [
        Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
                color: isDone || isActive
                    ? const Color(0xFF00B562)
                    : Colors.white10,
                shape: BoxShape.circle),
            child: Center(
                child: Icon(isDone ? Icons.check : Icons.circle,
                    size: isDone ? 14 : 6))),
        const SizedBox(height: 4),
        Text(title,
            style: TextStyle(
                color: isDone || isActive
                    ? Colors.white
                    : Colors.white24,
                fontSize: 10))
      ]);
}

class _StepLine extends StatelessWidget {
  final bool isDone;
  const _StepLine({this.isDone = false});

  @override
  Widget build(BuildContext context) => Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(left: 8, right: 8, bottom: 15),
      color: isDone ? const Color(0xFF00B562) : Colors.white10);
}
