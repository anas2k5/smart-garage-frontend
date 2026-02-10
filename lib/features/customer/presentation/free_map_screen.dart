import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class FreeMapScreen extends StatefulWidget {
  const FreeMapScreen({super.key});

  @override
  State<FreeMapScreen> createState() => _FreeMapScreenState();
}

class _FreeMapScreenState extends State<FreeMapScreen> {
  LatLng? currentLatLng;

  @override
  void initState() {
    super.initState();
    _getLiveLocation();
  }

  Future<void> _getLiveLocation() async {
    LocationPermission permission =
        await Geolocator.requestPermission();

    Position position =
        await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

    setState(() {
      currentLatLng =
          LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Garage Locator")),
      body: currentLatLng == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                initialCenter: currentLatLng!,
                initialZoom: 15,
                onTap: (tapPos, point) {
                  Navigator.pop(
                      context,
                      "${point.latitude.toStringAsFixed(4)}, "
                      "${point.longitude.toStringAsFixed(4)}");
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName:
                      "com.smartgarage.app",
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: currentLatLng!,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.location_pin,
                        size: 40,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
