import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../models/garage.dart';
import '../../../models/vehicle.dart';
import '../../../models/garage_service.dart';
import 'confirm_booking_screen.dart';

class SelectServiceScreen extends StatefulWidget {
  final Garage garage;
  final Vehicle vehicle;

  const SelectServiceScreen({
    super.key,
    required this.garage,
    required this.vehicle,
  });

  @override
  State<SelectServiceScreen> createState() =>
      _SelectServiceScreenState();
}

class _SelectServiceScreenState
    extends State<SelectServiceScreen> {
  late Future<List<GarageService>> _future;
  final ScrollController _stepScroll =
      ScrollController();

  @override
  void initState() {
    super.initState();
    _future =
        ApiService.getGarageServices(widget.garage.id);

    // auto-scroll step header to active step
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _stepScroll.animateTo(
        120,
        duration:
            const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _stepScroll.dispose();
    super.dispose();
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
        controller: _stepScroll,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: const [
            _StepChip(title: "Vehicle", done: true),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 14),
            SizedBox(width: 8),
            _StepChip(title: "Garage", done: true),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 14),
            SizedBox(width: 8),
            _StepChip(
              title: "Service",
              active: true,
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 14),
            SizedBox(width: 8),
            _StepChip(title: "Confirm"),
          ],
        ),
      ),
    );
  }

  // ================= SERVICE CARD =================
  Widget _serviceCard(
      GarageService s, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration:
          Duration(milliseconds: 250 + index * 80),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(
            vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(14),
        ),
        child: InkWell(
          borderRadius:
              BorderRadius.circular(14),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ConfirmBookingScreen(
                  garage: widget.garage,
                  vehicle: widget.vehicle,
                  service: s,
                ),
              ),
            );
          },
          child: Padding(
            padding:
                const EdgeInsets.all(12),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor:
                      Colors.green,
                  child: Icon(Icons.build,
                      color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        s.name,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                          height: 4),
                      Text(
                        s.description ??
                            "No description available",
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
                          fontSize: 13,
                          color:
                              Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green
                        .withOpacity(0.15),
                    borderRadius:
                        BorderRadius.circular(
                            20),
                    border: Border.all(
                        color: Colors.green),
                  ),
                  child: Text(
                    "₹ ${s.price}",
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= MAIN UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Service"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<GarageService>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Failed to load services",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            );
          }

          final services =
              snapshot.data ?? [];

          return SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.all(16),
              child: Column(
                children: [
                  _stepHeader(),
                  const SizedBox(
                      height: 16),

                  Expanded(
                    child: services.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisSize:
                                  MainAxisSize
                                      .min,
                              children: [
                                Icon(
                                  Icons.build,
                                  size: 48,
                                  color:
                                      Colors.grey,
                                ),
                                SizedBox(
                                    height: 8),
                                Text(
                                  "No services available",
                                  style:
                                      TextStyle(
                                    fontSize:
                                        16,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            physics:
                                const BouncingScrollPhysics(),
                            itemCount:
                                services.length,
                            itemBuilder:
                                (context, index) {
                              return _serviceCard(
                                services[index],
                                index,
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
  final bool done;

  const _StepChip({
    required this.title,
    this.active = false,
    this.done = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = active
        ? Colors.deepPurple
        : done
            ? Colors.green
            : Colors.white;

    Color textColor = active || done
        ? Colors.white
        : Colors.deepPurple;

    return AnimatedContainer(
      duration:
          const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: active || done
              ? bgColor
              : Colors.deepPurple,
          width: 1.5,
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: Colors
                      .deepPurple
                      .withOpacity(0.3),
                  blurRadius: 8,
                  offset:
                      const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          if (done) ...[
            const Icon(Icons.check,
                size: 14,
                color: Colors.white),
            const SizedBox(width: 4),
          ],
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontWeight:
                  FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
