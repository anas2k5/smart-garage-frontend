import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../models/booking.dart';
import 'booking_details_screen.dart';
import '../payments/payment_screen.dart';

class CustomerBookingsScreen extends StatefulWidget {
  final String? statusFilter;

  const CustomerBookingsScreen({
    super.key,
    this.statusFilter,
  });

  @override
  State<CustomerBookingsScreen> createState() =>
      _CustomerBookingsScreenState();
}

class _CustomerBookingsScreenState
    extends State<CustomerBookingsScreen> {
  late Future<List<Booking>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _bookingsFuture = ApiService.getCustomerBookings();
  }

  void _reload() {
    setState(() {
      _bookingsFuture = ApiService.getCustomerBookings();
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'PAID':
        return Colors.green;
      case 'COMPLETED':
        return Colors.blue;
      case 'IN_PROGRESS':
        return Colors.orange;
      case 'CANCELLED':
        return Colors.red;
      case 'PENDING':
        return Colors.grey;
      default:
        return Colors.black54;
    }
  }

  List<Booking> _applyFilter(List<Booking> bookings) {
    if (widget.statusFilter == null) return bookings;
    return bookings
        .where((b) => b.status == widget.statusFilter)
        .toList();
  }

  // ✅ CANCEL CONFIRMATION
  Future<void> _confirmCancel(BuildContext context, int bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cancel Booking"),
        content:
            const Text("Are you sure you want to cancel this booking?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Yes, Cancel",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ApiService.cancelBooking(bookingId);
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.statusFilter == null
        ? "My Bookings"
        : "${widget.statusFilter} Bookings";

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: RefreshIndicator(
        onRefresh: () async => _reload(),
        child: FutureBuilder<List<Booking>>(
          future: _bookingsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text("Failed to load bookings"),
              );
            }

            final bookings =
                _applyFilter(snapshot.data ?? []);

            if (bookings.isEmpty) {
              return Center(
                child: Text(
                  widget.statusFilter == null
                      ? "No bookings found"
                      : "No ${widget.statusFilter} bookings",
                ),
              );
            }

            return ListView.builder(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];

                final bool isPaid =
                    booking.status == 'PAID';
                final bool isCompleted =
                    booking.status == 'COMPLETED';
                final bool canCancel =
                    booking.status == 'PENDING' ||
                        booking.status == 'ACCEPTED';

                return InkWell(
                  borderRadius:
                      BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            BookingDetailsScreen(
                                booking: booking),
                      ),
                    );
                  },
                  child: Card(
                    margin:
                        const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8),
                    elevation: 3,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                              12),
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            "Booking #${booking.id}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          const SizedBox(height: 6),
                          Text(
                            booking.garageNameSafe,
                            style:
                                const TextStyle(
                                    color: Colors
                                        .black54),
                          ),

                          const SizedBox(height: 6),
                          Text(
                            "Service: ${booking.serviceTypeSafe}",
                          ),

                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Text(
                                  "Status: "),
                              Text(
                                booking.status,
                                style: TextStyle(
                                  color:
                                      _statusColor(
                                          booking
                                              .status),
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),
                          Text(
                            "Final Cost: ${booking.finalCost != null ? "₹ ${booking.finalCost}" : "N/A"}",
                          ),

                          // ✅ PAID BADGE
                          if (isPaid) ...[
                            const SizedBox(
                                height: 8),
                            Align(
                              alignment:
                                  Alignment
                                      .centerRight,
                              child: Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color: Colors
                                      .green
                                      .withOpacity(
                                          0.15),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                              20),
                                  border: Border.all(
                                      color: Colors
                                          .green),
                                ),
                                child: const Text(
                                  "PAID",
                                  style:
                                      TextStyle(
                                    color: Colors
                                        .green,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ),
                            ),
                          ],

                          // 💳 PAY NOW
                          if (isCompleted &&
                              booking.finalCost !=
                                  null &&
                              !isPaid) ...[
                            const SizedBox(
                                height: 10),
                            Align(
                              alignment:
                                  Alignment
                                      .centerRight,
                              child:
                                  ElevatedButton
                                      .icon(
                                icon: const Icon(
                                    Icons.payment),
                                label: const Text(
                                    "Pay Now"),
                                onPressed:
                                    () async {
                                  final paid =
                                      await Navigator
                                          .push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) =>
                                              PaymentScreen(
                                        booking:
                                            booking,
                                      ),
                                    ),
                                  );

                                  if (paid ==
                                      true) {
                                    _reload();
                                  }
                                },
                              ),
                            ),
                          ],

                          // 🔥 CANCEL BUTTON
                          if (canCancel &&
                              booking.status !=
                                  'PAID' &&
                              booking.status !=
                                  'CANCELLED') ...[
                            const SizedBox(
                                height: 10),
                            Align(
                              alignment:
                                  Alignment
                                      .centerRight,
                              child: TextButton(
                                style: TextButton
                                    .styleFrom(
                                  foregroundColor:
                                      Colors.red,
                                ),
                                onPressed:
                                    () =>
                                        _confirmCancel(
                                  context,
                                  booking.id,
                                ),
                                child: const Text(
                                    "Cancel Booking"),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
