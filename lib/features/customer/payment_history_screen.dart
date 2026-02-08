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
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  late Future<List<dynamic>> _paymentsFuture;

  // Global Brand Colors
  static const Color brandGreen = Color(0xFF00B562);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color backgroundDark = Color(0xFF121212);

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
    final bytes = await ApiService.downloadInvoice(bookingId);
    final file = await _getInvoiceFile(bookingId);
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  // ================= ACTION SHEET =================
  void _showInvoiceActions(int bookingId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 20),
              const Text("Invoice Options", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 20),
              _buildActionTile(Icons.picture_as_pdf_rounded, "View Invoice", () async {
                final file = await _downloadInvoiceFile(bookingId);
                await OpenFilex.open(file.path);
              }),
              _buildActionTile(Icons.ios_share_rounded, "Share with Others", () async {
                final file = await _downloadInvoiceFile(bookingId);
                await Share.shareXFiles([XFile(file.path)], text: "Invoice for Booking #$bookingId");
              }),
              _buildActionTile(Icons.file_download_outlined, "Save to Device", () async {
                final file = await _downloadInvoiceFile(bookingId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(backgroundColor: brandGreen, content: Text("Saved: ${file.path.split('/').last}")),
                  );
                }
              }),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, Future<void> Function() action) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: brandGreen, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      onTap: () async {
        Navigator.pop(context);
        try {
          await action();
        } catch (e) {
          _showError();
        }
      },
    );
  }

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(backgroundColor: Colors.redAccent, content: Text("Failed to process invoice")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundDark,
        appBarTheme: const AppBarTheme(backgroundColor: backgroundDark, elevation: 0),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Payment History", style: TextStyle(fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: FutureBuilder<List<dynamic>>(
          future: _paymentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: brandGreen));
            }
            if (snapshot.hasError) {
              return const Center(child: Text("Error loading transactions", style: TextStyle(color: Colors.white38)));
            }

            final payments = snapshot.data ?? [];
            if (payments.isEmpty) return _buildEmptyState();

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: payments.length,
              itemBuilder: (context, index) => _buildPaymentCard(payments[index]),
            );
          },
        ),
      ),
    );
  }

 Widget _buildPaymentCard(dynamic p) {
    final status = p["status"] ?? "UNKNOWN";
    final isPaid = status == "SUCCESS" || status == "PAID";
    final String date = p["completedAt"] != null
        ? DateFormat("dd MMM yyyy • hh:mm a").format(DateTime.parse(p["completedAt"]))
        : "Processing...";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isPaid ? brandGreen : Colors.orangeAccent).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPaid ? Icons.account_balance_wallet_rounded : Icons.pending_actions_rounded,
              color: isPaid ? brandGreen : Colors.orangeAccent,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Booking #${p["bookingId"]}", 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(date, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                const SizedBox(height: 8),
                Text("Via ${p["method"] ?? "Online Payment"}", 
                  style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          // --- UPDATED INVOICE BUTTON AREA ---
          if (isPaid)
            TextButton.icon(
              onPressed: () => _showInvoiceActions(p["bookingId"]),
              style: TextButton.styleFrom(
                foregroundColor: brandGreen,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                backgroundColor: brandGreen.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.receipt_long_rounded, size: 18),
              label: const Text(
                "Invoice",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            )
          else
            const Text("Pending", style: TextStyle(color: Colors.white24, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.history_rounded, size: 64, color: Colors.white10),
          SizedBox(height: 16),
          Text("No payment records found", style: TextStyle(color: Colors.white38)),
        ],
      ),
    );
  }
}