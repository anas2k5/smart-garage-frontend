import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/api_service.dart';
import '../../core/utils/role_navigator.dart';
import '../../models/login_response.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  bool _isLoading = false;
  bool _obscurePassword = true;

  // Global Brand Palette
  static const Color brandGreen = Color(0xFF00B562);

  @override
  void initState() {
    super.initState();
    // 🎭 Ken Burns Effect: Slow zoom for a premium cinematic feel
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.redAccent, content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      LoginResponse response = await ApiService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', response.token);
      await prefs.setInt('userId', response.userId);
      await prefs.setString('role', response.role);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RoleNavigator.getHomeByRole(response.role),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.redAccent, content: Text("Invalid email or password")),
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
          // 🏎️ LAYER 1: Animated Background
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?q=80&w=1500&auto=format&fit=crop'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),

          // 🌑 LAYER 2: Deep Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.9),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 📝 LAYER 3: Login Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildLogoHeader(),
                    const SizedBox(height: 40),
                    _buildLoginCard(),
                    const SizedBox(height: 24),
                    _buildFooterLink(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: brandGreen, width: 2),
            boxShadow: [
              BoxShadow(color: brandGreen.withOpacity(0.3), blurRadius: 20, spreadRadius: 2)
            ],
          ),
          child: const Icon(Icons.garage_rounded, size: 48, color: brandGreen),
        ),
        const SizedBox(height: 16),
        const Text(
          "SMART GARAGE",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 3,
          ),
        ),
        const Text(
          "PREMIUM VEHICLE CARE",
          style: TextStyle(color: brandGreen, letterSpacing: 1.5, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              const Text("Login to Hub", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 24),
              
              // Email Field - FIXED VISIBILITY
              _buildStyledField(
                controller: _emailController,
                hint: "Email Address",
                icon: Icons.alternate_email_rounded,
              ),
              const SizedBox(height: 16),
              
              // Password Field - FIXED VISIBILITY
              _buildStyledField(
                controller: _passwordController,
                hint: "Password",
                icon: Icons.lock_outline_rounded,
                isPassword: true,
              ),
              const SizedBox(height: 32),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("ACCESS DASHBOARD", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStyledField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        // VISIBILITY FIX: Increased opacity and used white70 for better contrast
        hintStyle: const TextStyle(color: Colors.white60, fontWeight: FontWeight.w400),
        prefixIcon: Icon(icon, color: brandGreen, size: 20),
        suffixIcon: isPassword 
          ? IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white38, size: 18),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ) 
          : null,
        filled: true,
        // VISIBILITY FIX: Slightly darker fill for the input container to separate text from background
        fillColor: Colors.black.withOpacity(0.25),
        contentPadding: const EdgeInsets.symmetric(vertical: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: brandGreen, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildFooterLink() {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RegisterScreen()),
        );
      },
      child: RichText(
        text: const TextSpan(
          text: "Don't have an account? ",
          style: TextStyle(color: Colors.white70),
          children: [
            TextSpan(
              text: "Register",
              style: TextStyle(color: brandGreen, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}