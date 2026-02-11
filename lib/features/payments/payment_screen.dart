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

  // Global Brand Palette
  static const Color brandGreen = Color(0xFF00B562);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color backgroundDark = Color(0xFF121212);

  Future<void> _payNow() async {
    try {
      setState(() => _loading = true);

      final amount = widget.booking.finalCost!;
      final bookingId = widget.booking.id;

      // STEP 1: INITIATE PAYMENT
      final paymentIntentData = await ApiService.initiatePayment(
        bookingId: bookingId,
        amount: amount,
      );

      final clientSecret = paymentIntentData['clientSecret'];

      if (clientSecret == null) {
        throw Exception("Stripe connection error");
      }

     // STEP 2: INIT STRIPE SHEET
await Stripe.instance.initPaymentSheet(
  paymentSheetParameters: SetupPaymentSheetParameters(
    paymentIntentClientSecret: clientSecret,
    merchantDisplayName: "Smart Garage",
    style: ThemeMode.dark, 
    appearance: const PaymentSheetAppearance(
      colors: PaymentSheetAppearanceColors(
        primary: brandGreen,
        background: surfaceDark,
        componentBackground: backgroundDark,
        // --- ADD THESE LINES TO FIX VISIBILITY ---
        componentText: Colors.white,         // Text inside the input fields
        componentDivider: Colors.white24,    // Lines between card/expiry/cvc
        primaryText: Colors.white,           // Main titles
        secondaryText: Colors.white70,       // Subtitles/placeholders
        placeholderText: Colors.white30,     // "MM/YY" and "CVC" text
      ),
      // Optional: Round the corners to match your UI
      shapes: PaymentSheetShape(
        borderRadius: 16.0,
      ),
    ),
  ),
);

      // STEP 3: PRESENT UI
      await Stripe.instance.presentPaymentSheet();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: brandGreen,
          content: Text("✅ Payment Confirmed. Receipt sent to your email."),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text("Payment unsuccessful. Try again."),
        ),
      );
    }
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
          title: const Text("Secure Checkout", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 30),
                _buildSecurityHeader(),
                const SizedBox(height: 40),
                _buildReceiptCard(),
                const SizedBox(height: 60),
                _buildPaymentButton(),
                const SizedBox(height: 20),
                const Text("Protected by 256-bit SSL encryption", 
                  style: TextStyle(color: Colors.white24, fontSize: 11)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: brandGreen.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.verified_user_rounded, size: 60, color: brandGreen),
        ),
        const SizedBox(height: 16),
        const Text("Payment Information", 
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
      ],
    );
  }

  Widget _buildReceiptCard() {
    return Container(
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text("TOTAL PAYABLE", 
                  style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                const SizedBox(height: 12),
                Text("₹${widget.booking.finalCost}", 
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: brandGreen)),
              ],
            ),
          ),
          const _DashedLine(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _infoRow("Booking ID", "#${widget.booking.id}"),
                _infoRow("Garage", widget.booking.garageNameSafe),
                _infoRow("Service", widget.booking.serviceTypeSafe),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        onPressed: _loading ? null : _payNow,
        child: _loading
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline_rounded, size: 20),
                  SizedBox(width: 12),
                  Text("PAY SECURELY NOW", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                ],
              ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 13)),
          const SizedBox(width: 20),
          Flexible(
            child: Text(value, 
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}

// Custom widget for the receipt effect
class _DashedLine extends StatelessWidget {
  const _DashedLine();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return const SizedBox(width: dashWidth, height: 1, child: DecoratedBox(decoration: BoxDecoration(color: Colors.white10)));
          }),
        );
      },
    );
  }
}