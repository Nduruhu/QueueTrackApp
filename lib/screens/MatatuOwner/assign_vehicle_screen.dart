import 'package:flutter/material.dart';
import 'package:queuetrack/Database/matatu_owner.dart';

class AssignVehicleScreen extends StatefulWidget {
  const AssignVehicleScreen({super.key});

  @override
  State<AssignVehicleScreen> createState() => _AssignVehicleScreenState();
}

class _AssignVehicleScreenState extends State<AssignVehicleScreen> {
  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController driverIdController = TextEditingController();
  final TextEditingController driverNameController = TextEditingController();
  final TextEditingController driverEmailController = TextEditingController();
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  // --- MODERN TEXT FIELD WIDGET ---
  Widget _textField({
    required int length,
    required String label,
    required TextEditingController controller,
    required TextInputType keyboard,
    required IconData icon, // Added icon for better UI
    TextCapitalization capitalValue = TextCapitalization.none,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        maxLength: length,
        textCapitalization: capitalValue,
        controller: controller,
        keyboardType: keyboard,
        style: const TextStyle(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          counterText: "", // Hides the character count number for a cleaner look
          filled: true,
          fillColor: const Color(0xFFF3F4F6), // Light grey background
          prefixIcon: Icon(icon, color: Colors.grey.shade600),
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade500),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
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
  void dispose() {
    vehicleNumberController.dispose();
    driverIdController.dispose();
    driverNameController.dispose();
    driverEmailController.dispose();
    super.dispose();
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
          "Register Vehicle",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 1. Header Visual
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Icon(
                  Icons.directions_bus_filled_rounded,
                  size: 80,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 10),
                Text(
                  "Assign Driver & Vehicle",
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
                          length: 8,
                          label: 'Vehicle Number (Plate)',
                          controller: vehicleNumberController,
                          capitalValue: TextCapitalization.characters,
                          keyboard: TextInputType.text,
                          icon: Icons.confirmation_number_outlined,
                        ),

                        _textField(
                          length: 8,
                          label: 'Driver ID (National ID)',
                          controller: driverIdController,
                          keyboard: TextInputType.number,
                          icon: Icons.badge_outlined,
                        ),

                        _textField(
                          length: 15,
                          label: 'Driver Name',
                          controller: driverNameController,
                          keyboard: TextInputType.name,
                          icon: Icons.person_outline,
                        ),

                        _textField(
                          label: "Driver's Email",
                          length: 30, // Increased slightly for emails
                          controller: driverEmailController,
                          keyboard: TextInputType.emailAddress,
                          icon: Icons.email_outlined,
                        ),

                        const SizedBox(height: 20),

                        // Action Button
                        SizedBox(
                          height: 55,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 5,
                              shadowColor: primaryColor.withValues(alpha: 0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            icon: isLoading
                                ? const SizedBox.shrink()
                                : const Icon(Icons.save_rounded),
                            label: isLoading
                                ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            )
                                : const Text(
                              "Register Vehicle",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            onPressed: isLoading ? null : () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => isLoading = true); // Update UI to show spinner

                                // Logic preserved
                                await MatatuOwner().addDriver(
                                  name: driverNameController.text,
                                  email: driverEmailController.text,
                                  vehicleId: vehicleNumberController.text,
                                  nationalId: int.tryParse(driverIdController.text.toString())!,
                                );

                                setState(() => isLoading = false); // Stop spinner

                                // Optional: Provide feedback or pop screen after success
                                // Navigator.pop(context);
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 30), // Bottom padding
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