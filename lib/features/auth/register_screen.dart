import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _selectedRole = "CUSTOMER";
  bool _isLoading = false;
  bool _obscurePassword = true;

  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  // Global Brand Palette
  static const Color brandGreen = Color(0xFF00B562);
  static const Color surfaceDark = Color(0xFF1C1C1E);

  @override
  void initState() {
    super.initState();
    // 🎭 Background Animation Setup
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _animController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.redAccent, content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ApiService.register(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: _selectedRole,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: brandGreen, content: Text("Registration successful! Please login")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.redAccent, content: Text("Registration failed")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 🏎️ LAYER 1: Animated Background (Workshop/Engine Theme)
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?q=80&w=1500&auto=format&fit=crop'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),

          // 🌑 LAYER 2: Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.85),
                  Colors.black.withOpacity(0.5),
                  Colors.black.withOpacity(0.9),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 📝 LAYER 3: Registration Form
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildGlassCard(),
                    const SizedBox(height: 24),
                    _buildLoginLink(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          "JOIN THE HUB",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 2,
          width: 40,
          color: brandGreen,
        ),
      ],
    );
  }

  Widget _buildGlassCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              _buildField(_nameController, "Full Name", Icons.person_outline_rounded),
              const SizedBox(height: 16),
              _buildField(_emailController, "Email Address", Icons.alternate_email_rounded, type: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildField(_passwordController, "Password", Icons.lock_outline_rounded, isPassword: true),
              const SizedBox(height: 16),
              _buildRoleDropdown(),
              const SizedBox(height: 32),
              _buildRegisterButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String hint, IconData icon, {bool isPassword = false, TextInputType type = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      obscureText: isPassword ? _obscurePassword : false,
      keyboardType: type,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        prefixIcon: Icon(icon, color: brandGreen, size: 20),
        suffixIcon: isPassword 
          ? IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white24, size: 18),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ) 
          : null,
        filled: true,
        fillColor: Colors.black.withOpacity(0.2),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: brandGreen, width: 1),
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Theme(
      data: Theme.of(context).copyWith(canvasColor: surfaceDark),
      child: DropdownButtonFormField<String>(
        value: _selectedRole,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: "Select Role",
          prefixIcon: const Icon(Icons.shield_outlined, color: brandGreen, size: 20),
          filled: true,
          fillColor: Colors.black.withOpacity(0.2),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
        items: const [
          DropdownMenuItem(value: "CUSTOMER", child: Text("Customer")),
          DropdownMenuItem(value: "OWNER", child: Text("Garage Owner")),
        ],
        onChanged: (value) => setState(() => _selectedRole = value!),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: _isLoading ? null : _register,
        child: _isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text("CREATE ACCOUNT", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
      ),
    );
  }

  Widget _buildLoginLink() {
    return TextButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      },
      child: RichText(
        text: const TextSpan(
          text: "Already a member? ",
          style: TextStyle(color: Colors.white54),
          children: [
            TextSpan(
              text: "Login",
              style: TextStyle(color: brandGreen, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}