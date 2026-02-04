import 'package:flutter/material.dart';
import 'package:queuetrack/Database/matatu_owner.dart';
import 'package:queuetrack/Database/sacco_official.dart';

class SignUpScreen extends StatefulWidget {
  final String selectedRole;
  const SignUpScreen({super.key, required this.selectedRole});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final nameController = TextEditingController();
  final idNumberController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool isLoading = false;
  String? selectedRole;

  /// Dropdown labels (user friendly)
  final roles = ['Sacco_Official', 'Matatu_Owner'];

  Future<void> _signUp({required String category}) async {
    if (passwordController.text != confirmController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() => isLoading = true);
    try {
      if (selectedRole!.toLowerCase() == 'matatu_owner') {
        //create matatu owner user
        MatatuOwner().signUp(
          fullName: nameController.text,
          id: int.tryParse(idNumberController.text)!,
          email: emailController.text,
          password: passwordController.text,
        );
      } else {
        //create sacco official user
        await SaccoOfficial().signUp(
          email: emailController.text,
          password: passwordController.text,
          id: int.tryParse(idNumberController.text)!,
          name: nameController.text,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    idNumberController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  // --- REUSABLE MODERN TEXT FIELD ---
  Widget _textField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    int? maxLength,
    Iterable<String>? autofillHints,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLength: maxLength,
        autofillHints: autofillHints,
        style: const TextStyle(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF3F4F6),
          counterText: "",
          prefixIcon: Icon(icon, color: Colors.grey.shade600),
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade500),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.blue.shade900, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.blue.shade900;

    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          // 1. TOP SECTION (Blue Background)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.35,
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    // Back Button (Top Left)
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, top: 10),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),

                    // Spacer pushes content to center
                    const Spacer(flex: 2),

                    // --- CHANGED TO BUS ICON (SIZE 50) ---
                    const Icon(
                        Icons.directions_bus_rounded,
                        color: Colors.white,
                        size: 50
                    ),
                    const SizedBox(height: 10),
                    // -------------------------------------

                    const Text(
                      'Create Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign up to get started',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.blue.shade100,
                        fontSize: 16,
                      ),
                    ),

                    // Spacer balances the bottom spacing
                    const Spacer(flex: 3),
                  ],
                ),
              ),
            ),
          ),

          // 2. BOTTOM SECTION (White Sheet)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.28,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - 60,
                        ),
                        child: AutofillGroup(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _textField(
                                controller: nameController,
                                maxLength: 20,
                                icon: Icons.person_outline,
                                label: 'Full Name',
                              ),
                              _textField(
                                controller: idNumberController,
                                maxLength: 8,
                                icon: Icons.badge_outlined,
                                label: 'Your ID Number',
                                autofillHints: [AutofillHints.telephoneNumber],
                              ),
                              _textField(
                                controller: emailController,
                                maxLength: 25,
                                icon: Icons.email_outlined,
                                label: 'Email',
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: [AutofillHints.email],
                              ),
                              _textField(
                                controller: passwordController,
                                maxLength: 15,
                                icon: Icons.lock_outline,
                                label: 'Password',
                                obscureText: true,
                                autofillHints: [AutofillHints.password],
                              ),
                              _textField(
                                controller: confirmController,
                                maxLength: 15,
                                icon: Icons.lock_outline,
                                label: 'Confirm Password',
                                obscureText: true,
                                autofillHints: [AutofillHints.password],
                              ),

                              // Stylized Dropdown
                              Container(
                                margin: const EdgeInsets.only(bottom: 24),
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: DropdownButtonFormField<String>(
                                  value: selectedRole,
                                  icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    prefixIcon: Icon(Icons.work_outline, color: Colors.grey),
                                    labelText: 'Select Role',
                                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  items: roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                                  onChanged: (v) => setState(() => selectedRole = v),
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Create Account Button
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    elevation: 5,
                                    shadowColor: primaryColor.withValues(alpha: 0.4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  onPressed: isLoading
                                      ? null
                                      : () async {
                                    await _signUp(category: widget.selectedRole);
                                  },
                                  child: isLoading
                                      ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                      : const Text(
                                    'Create Account',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}