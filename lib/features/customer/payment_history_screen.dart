import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

import '../../core/services/api_service.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() =>
      _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState
    extends State<PaymentHistoryScreen> {
  late Future<List<dynamic>> _paymentsFuture;

  @override
  void initState() {
    super.initState();
    _paymentsFuture = ApiService.getMyPayments();
  }

  Future<void> _downloadInvoice(int bookingId) async {
    try {
      final bytes =
          await ApiService.downloadInvoice(bookingId);

      final dir =
          await getApplicationDocumentsDirectory();
      final file =
          File('${dir.path}/invoice-$bookingId.pdf');

      await file.writeAsBytes(bytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Invoice saved to ${file.path}"),
        ),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Download failed"),
        ),
      );
    }
  }

  Widget _statusChip(String status) {
    final isSuccess = status == "SUCCESS";

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSuccess
            ? Colors.green.withOpacity(0.15)
            : Colors.orange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSuccess ? Colors.green : Colors.orange,
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isSuccess ? Colors.green : Colors.orange,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text("Payment History")),
      body: FutureBuilder<List<dynamic>>(
        future: _paymentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("Failed to load payments"),
            );
          }

          final payments = snapshot.data ?? [];

          if (payments.isEmpty) {
            return const Center(
              child: Text("No payments found"),
            );
          }

          return ListView.builder(
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final p = payments[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(
                    "Booking #${p["bookingId"]}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // ✅ EVERYTHING BELOW GOES INSIDE SUBTITLE
                  subtitle: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),

                      Row(
                        children: [
                          _statusChip(p["status"]),
                          const SizedBox(width: 10),
                          Text(
                            "Method: ${p["method"] ?? "CARD"}",
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Paid on: ${p["completedAt"] != null
                            ? DateFormat("dd MMM yyyy, hh:mm a")
                                .format(DateTime.parse(p["completedAt"]))
                            : "—"}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  // ✅ ACTION ON RIGHT
                  trailing: p["status"] == "SUCCESS"
                      ? ElevatedButton(
                          onPressed: () =>
                              _downloadInvoice(
                                  p["bookingId"]),
                          child:
                              const Text("Invoice"),
                        )
                      : const Text(
                          "Pending",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
