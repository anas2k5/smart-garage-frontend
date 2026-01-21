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
  State<PaymentScreen> createState() =>
      _PaymentScreenState();
}

class _PaymentScreenState
    extends State<PaymentScreen> {
  bool _loading = false;

  // ================= PAY FLOW =================
  Future<void> _payNow() async {
    try {
      setState(() {
        _loading = true;
      });

      final amount =
          widget.booking.finalCost!;
      final bookingId =
          widget.booking.id;

      // STEP 1: INITIATE PAYMENT
      final paymentIntentData =
          await ApiService.initiatePayment(
        bookingId: bookingId,
        amount: amount,
      );

      final clientSecret =
          paymentIntentData['clientSecret'];

      if (clientSecret == null) {
        throw Exception(
            "Client secret not received from backend");
      }

      // STEP 2: INIT STRIPE SHEET
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters:
            SetupPaymentSheetParameters(
          paymentIntentClientSecret:
              clientSecret,
          merchantDisplayName:
              "Smart Garage",
          style: ThemeMode.light,
        ),
      );

      // STEP 3: PRESENT UI
      await Stripe.instance
          .presentPaymentSheet();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
              "✅ Payment successful! Invoice sent to email 📧"),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text("Payment failed: $e"),
        ),
      );
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Secure Payment"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              const Icon(
                Icons.lock,
                size: 80,
                color: Colors.green,
              ),

              const SizedBox(height: 20),

              const Text(
                "Amount to Pay",
                textAlign:
                    TextAlign.center,
                style:
                    TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 8),

              Text(
                "₹ ${widget.booking.finalCost}",
                textAlign:
                    TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              _infoRow("Booking ID",
                  "#${widget.booking.id}"),
              _infoRow("Garage",
                  widget.booking.garageName),
              _infoRow(
                "Service",
                widget.booking.serviceType ??
                    "Service",
              ),

              const SizedBox(height: 60),

              ElevatedButton.icon(
                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          color:
                              Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.credit_card),
                label: Text(
                  _loading
                      ? "Opening payment sheet..."
                      : "Pay Securely",
                ),
                onPressed:
                    _loading ? null : _payNow,
                style: ElevatedButton
                    .styleFrom(
                  padding:
                      const EdgeInsets.symmetric(
                          vertical: 14),
                  textStyle:
                      const TextStyle(
                          fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HELPER =================
  Widget _infoRow(
      String label, String value) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
              vertical: 6),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
                color:
                    Colors.black54),
          ),
          Flexible(
            child: Text(
              value,
              textAlign:
                  TextAlign.right,
              style: const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
