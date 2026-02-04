import 'package:flutter/material.dart';
import 'package:queuetrack/Database/driver.dart';
import 'package:queuetrack/Database/matatu_owner.dart';
import 'package:queuetrack/Database/sacco_official.dart';
import 'package:queuetrack/Database/stage_marshal.dart';
import 'package:queuetrack/screens/Authentication/signup_screen.dart';
import 'package:queuetrack/screens/Driver/driver_dashboard.dart';
import 'package:queuetrack/screens/MatatuOwner/matatu_owner_dashboard.dart';
import 'package:queuetrack/screens/SaccoOfficial/sacco_official_dashboard.dart';
import 'package:queuetrack/screens/StageMarshal/stage_marshal_dashboard.dart';

// ignore: must_be_immutable
class LoginPage extends StatefulWidget {
  String selectedRole;
  LoginPage({super.key, required this.selectedRole});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController driverIdController = TextEditingController();
  final TextEditingController stageMarshalIdController = TextEditingController();
  final TextEditingController driverNameController = TextEditingController();
  final TextEditingController stageMarshalEmailController = TextEditingController();
  final TextEditingController vehicleNumberController = TextEditingController();

  bool isLoading = false;

  // 1. ADDED: State to track password visibility
  bool _isPasswordVisible = false;

  final _formKey = GlobalKey<FormState>();

  // --- MODERN TEXT FIELD WIDGET ---
  Widget _textField({
    required String label,
    required TextEditingController controller,
    required TextInputType keyboard,
    required bool obscure, // This dictates if it CAN be obscured
    TextCapitalization capitalValue = TextCapitalization.none,
    required int maxLength,
    required int minLength,
    required Icon leadingIcon,
    Widget? suffixIcon, // 2. ADDED: Optional suffix icon for the eye
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        // Logic: If it's a password field (obscure=true), use the state variable.
        // If it's a normal field, always show text (false).
        obscureText: obscure ? !_isPasswordVisible : false,
        maxLength: maxLength,
        minLines: minLength,
        textCapitalization: capitalValue,
        style: const TextStyle(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF3F4F6),
          counterText: "",
          prefixIcon: Icon(leadingIcon.icon, color: Colors.grey.shade600),
          // Add the suffix icon here (the eye button)
          suffixIcon: suffixIcon,
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

  String _formatRoleName(String role) {
    return role.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    driverIdController.dispose();
    stageMarshalIdController.dispose();
    driverNameController.dispose();
    stageMarshalEmailController.dispose();
    vehicleNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.blue.shade900;

    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          // 1. TOP SECTION (LOGO & BACK BUTTON)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.35,
            child: SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Icon(
                    Icons.directions_bus_rounded,
                    color: Colors.white,
                    size: 60,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "QueueTrack",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Login as ${_formatRoleName(widget.selectedRole)}",
                    style: TextStyle(
                      color: Colors.blue.shade100,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. BOTTOM SECTION (WHITE SHEET FORM)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.32,
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
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
                  child: Form(
                    key: _formKey,
                    child: AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),

                          // ---------------- LOGIC BLOCKS ----------------
                          if (widget.selectedRole.toLowerCase() == 'sacco_official' ||
                              widget.selectedRole.toLowerCase() == 'matatu_owner')
                            Column(
                              children: [
                                _textField(
                                  leadingIcon: const Icon(Icons.email_outlined),
                                  label: 'Email',
                                  controller: emailController,
                                  keyboard: TextInputType.emailAddress,
                                  obscure: false,
                                  minLength: 1,
                                  maxLength: 25,
                                ),
                                _textField(
                                  leadingIcon: const Icon(Icons.lock_outline),
                                  label: 'Password',
                                  controller: passwordController,
                                  keyboard: TextInputType.visiblePassword,
                                  obscure: true, // This field is securable
                                  minLength: 1,
                                  maxLength: 15,
                                  // 3. ADDED: Eye Icon Button
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible = !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),

                          if (widget.selectedRole.toLowerCase() == 'driver')
                            Column(
                              children: [
                                _textField(
                                  leadingIcon: const Icon(Icons.badge_outlined),
                                  label: 'Driver ID',
                                  controller: driverIdController,
                                  keyboard: TextInputType.number,
                                  obscure: false,
                                  minLength: 1,
                                  maxLength: 8,
                                ),
                                _textField(
                                  leadingIcon: const Icon(Icons.confirmation_number_outlined),
                                  label: 'Vehicle Number',
                                  controller: vehicleNumberController,
                                  keyboard: TextInputType.text,
                                  capitalValue: TextCapitalization.characters,
                                  obscure: false,
                                  minLength: 1,
                                  maxLength: 8,
                                ),
                              ],
                            ),

                          if (widget.selectedRole.toLowerCase() == 'stage_marshal')
                            Column(
                              children: [
                                _textField(
                                  leadingIcon: const Icon(Icons.email_outlined),
                                  label: 'Marshal Email',
                                  controller: stageMarshalEmailController,
                                  keyboard: TextInputType.emailAddress,
                                  obscure: false,
                                  minLength: 1,
                                  maxLength: 25,
                                ),
                                _textField(
                                  leadingIcon: const Icon(Icons.badge_outlined),
                                  label: 'Marshal ID',
                                  controller: stageMarshalIdController,
                                  keyboard: TextInputType.number,
                                  obscure: false,
                                  minLength: 1,
                                  maxLength: 8,
                                ),
                              ],
                            ),

                          const SizedBox(height: 20),

                          // Login Button
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
                              onPressed: isLoading ? null : () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() => isLoading = true);

                                  // Matatu Owner Login
                                  if (widget.selectedRole.toLowerCase() == 'matatu_owner') {
                                    final response = await MatatuOwner().signIn(
                                      email: emailController.text,
                                      password: passwordController.text,
                                    );
                                    if (!mounted) return;
                                    if (response == true) {
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => MatatuOwnerDashboard(),
                                      ));
                                    }
                                  }
                                  // Driver Login
                                  else if (widget.selectedRole.toLowerCase() == 'driver') {
                                    int id = int.tryParse(driverIdController.text.toString())!;
                                    final response = await Driver().signInDriver(
                                      vehicleId: vehicleNumberController.text,
                                      id: id,
                                    );
                                    if (!mounted) return;
                                    if (response == true) {
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => DriverDashboard(),
                                      ));
                                    }
                                  }
                                  // Sacco Official Login
                                  else if (widget.selectedRole.toLowerCase() == 'sacco_official') {
                                    final response = await SaccoOfficial().signIn(
                                      email: emailController.text,
                                      password: passwordController.text,
                                    );
                                    if (!mounted) return;
                                    if (response == true) {
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => SaccoOfficialDashboard(),
                                      ));
                                    }
                                  }
                                  // Stage Marshal Login
                                  else if (widget.selectedRole.toLowerCase() == 'stage_marshal') {
                                    final response = await StageMarshal().signIn(
                                      email: emailController.text,
                                      id: int.tryParse(stageMarshalIdController.text)!,
                                    );
                                    if (!mounted) return;
                                    if (response == true) {
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => StageMarshalDashboard(),
                                      ));
                                    }
                                  }

                                  if (mounted) {
                                    setState(() => isLoading = false);
                                  }
                                }
                              },
                              child: isLoading
                                  ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                                  : const Text(
                                'Login',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Sign Up Link
                          if (widget.selectedRole.toLowerCase() == 'sacco_official' ||
                              widget.selectedRole.toLowerCase() == 'matatu_owner')
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => SignUpScreen(selectedRole: widget.selectedRole),
                                  ));
                                },
                                child: RichText(
                                  text: TextSpan(
                                    text: "Don't have an account? ",
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                                    children: [
                                      TextSpan(
                                        text: "Sign Up",
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          if (!(widget.selectedRole.toLowerCase() == 'sacco_official' ||
                              widget.selectedRole.toLowerCase() == 'matatu_owner'))
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  "Registration managed by Authorized Personnel",
                                  style: TextStyle(color: Colors.grey.shade400, fontStyle: FontStyle.italic),
                                ),
                              ),
                            )
                        ],
                      ),
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