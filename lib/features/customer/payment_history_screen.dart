import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

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

  // ================= FILE HELPERS =================

  Future<File> _getInvoiceFile(int bookingId) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/invoice-$bookingId.pdf');
  }

  Future<File> _downloadInvoiceFile(int bookingId) async {
    final bytes =
        await ApiService.downloadInvoice(bookingId);

    final file = await _getInvoiceFile(bookingId);
    await file.writeAsBytes(bytes, flush: true);

    return file;
  }

  // ================= ACTION SHEET =================

  void _showInvoiceActions(int bookingId) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),

            const Text(
              "Invoice Options",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            ListTile(
              leading: const Icon(Icons.open_in_new),
              title: const Text("Open PDF"),
              onTap: () async {
                Navigator.pop(context);

                try {
                  final file =
                      await _downloadInvoiceFile(
                          bookingId);

                  await OpenFilex.open(file.path);
                } catch (_) {
                  _showError();
                }
              },
            ),

            ListTile(
              leading: const Icon(Icons.share),
              title: const Text("Share PDF"),
              onTap: () async {
                Navigator.pop(context);

                try {
                  final file =
                      await _downloadInvoiceFile(
                          bookingId);

                  await Share.shareXFiles(
                    [XFile(file.path)],
                    text:
                        "Invoice for Booking #$bookingId",
                  );
                } catch (_) {
                  _showError();
                }
              },
            ),

            ListTile(
              leading: const Icon(Icons.download),
              title: const Text("Download PDF"),
              onTap: () async {
                Navigator.pop(context);

                try {
                  final file =
                      await _downloadInvoiceFile(
                          bookingId);

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    SnackBar(
                      content: Text(
                          "Saved to ${file.path}"),
                    ),
                  );
                } catch (_) {
                  _showError();
                }
              },
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Invoice action failed"),
      ),
    );
  }

  // ================= UI HELPERS =================

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

  // ================= UI =================

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

                  trailing: p["status"] == "SUCCESS"
                      ? ElevatedButton.icon(
                          icon: const Icon(Icons.receipt),
                          label: const Text("Invoice"),
                          onPressed: () =>
                              _showInvoiceActions(
                                  p["bookingId"]),
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
