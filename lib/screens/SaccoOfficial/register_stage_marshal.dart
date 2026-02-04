import 'package:flutter/material.dart';
import 'package:queuetrack/Database/sacco_official.dart';

class RegisterStageMarshal extends StatefulWidget {
  const RegisterStageMarshal({super.key});

  @override
  State<RegisterStageMarshal> createState() => _RegisterStageMarshalState();
}

class _RegisterStageMarshalState extends State<RegisterStageMarshal> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();

  bool isLoading = false;

  // --- MODERN TEXT FIELD WIDGET ---
  Widget _textField({
    required String label,
    required TextEditingController controller,
    required TextInputType keyboard,
    required bool obscure,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        keyboardType: keyboard,
        obscureText: obscure,
        controller: controller,
        style: const TextStyle(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF3F4F6), // Light grey background
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.blue.shade900;

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Register Stage Marshal",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 1. Background Visual
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Icon(
                  Icons.person_add_alt_1_rounded,
                  size: 80,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 10),
                Text(
                  "Add New Marshal",
                  style: TextStyle(
                    color: Colors.blue.shade100,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // 2. White Content Sheet
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2, // Start content lower
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _textField(
                          label: 'Email',
                          controller: emailController,
                          keyboard: TextInputType.emailAddress,
                          obscure: false,
                          icon: Icons.email_outlined,
                        ),

                        _textField(
                          label: 'Name',
                          controller: nameController,
                          keyboard: TextInputType.name,
                          obscure: false,
                          icon: Icons.person_outline,
                        ),

                        _textField(
                          label: 'National ID',
                          controller: idController,
                          keyboard: TextInputType.number,
                          obscure: false,
                          icon: Icons.badge_outlined,
                        ),

                        const SizedBox(height: 30),

                        // Action Buttons
                        SizedBox(
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 5,
                              shadowColor: primaryColor.withValues(alpha: 0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed: (!isLoading)
                                ? () {
                              // Preserved Logic
                              setState(() => isLoading = true); // Added setState to visualize loading
                              if (_formKey.currentState!.validate()) {
                                SaccoOfficial().addStageMarshal(
                                  name: nameController.text,
                                  email: emailController.text,
                                  nationalId: int.tryParse(idController.text)!,
                                );
                              }
                              setState(() => isLoading = false);
                            }
                                : null,
                            child: isLoading
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Sign Them Up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
                          height: 55,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade300),
                              foregroundColor: Colors.grey.shade700,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed: (!isLoading)
                                ? () {
                              Navigator.pop(context);
                            }
                                : null,
                            child: const Text('Exit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                        ),

                        const SizedBox(height: 20), // Bottom padding
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}