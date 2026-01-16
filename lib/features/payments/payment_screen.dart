import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../core/services/api_service.dart';
import '../../models/booking.dart';

class PaymentScreen extends StatefulWidget {
  final Booking booking;

  const PaymentScreen({
    super.key,
    required this.booking,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _loading = false;

  Future<void> _payNow() async {
    try {
      setState(() => _loading = true);

      final amount = widget.booking.finalCost!;
      final bookingId = widget.booking.id;

      // ---------------- STEP 1: INITIATE PAYMENT (Backend) ----------------
      final paymentIntentData = await ApiService.initiatePayment(
        bookingId: bookingId,
        amount: amount,
      );

      // ✅ MUST USE clientSecret — NOT transactionId
      final clientSecret = paymentIntentData['clientSecret'];

      if (clientSecret == null) {
        throw Exception("Client secret not received from backend");
      }

      // ---------------- STEP 2: INIT STRIPE SHEET ----------------
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: "Smart Garage",
          style: ThemeMode.light,
        ),
      );

      // ---------------- STEP 3: PRESENT STRIPE UI ----------------
      await Stripe.instance.presentPaymentSheet();

      // ---------------- STEP 4: CONFIRM PAYMENT (Backend) ----------------
      await ApiService.confirmPayment(
        bookingId: bookingId,
        transactionId: paymentIntentData['transactionId'], // store Stripe Intent ID
        amountPaid: amount,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Payment successful! Invoice sent to email 📧"),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment failed: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Secure Payment")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.lock, size: 80, color: Colors.green),
            const SizedBox(height: 20),

            const Text(
              "Amount to Pay",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),

            Text(
              "₹${widget.booking.finalCost}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Spacer(),

            ElevatedButton.icon(
              icon: const Icon(Icons.credit_card),
              label: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Pay Securely"),
              onPressed: _loading ? null : _payNow,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
