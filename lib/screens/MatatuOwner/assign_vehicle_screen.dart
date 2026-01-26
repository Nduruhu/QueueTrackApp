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

  Widget _textFields({
    required int length,
    required String label,
    required TextEditingController controller,
    required TextInputType keyboard,
    TextCapitalization capitalValue = TextCapitalization.none,
  }) {
    return TextFormField(
      maxLength: length,
      textCapitalization: capitalValue,
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: label,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    vehicleNumberController.dispose();
    driverIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text("Register / Assign Vehicle"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _textFields(
                  length: 8,
                  label: 'Vehicle Number',
                  controller: vehicleNumberController,
                  capitalValue: TextCapitalization.characters,
                  keyboard: TextInputType.text,
                ),
                const SizedBox(height: 16),
                _textFields(
                  length: 8,
                  label: 'Driver ID',
                  controller: driverIdController,
                  keyboard: TextInputType.number,
                ),
                const SizedBox(height: 24),
                _textFields(
                  length: 15,
                  label: 'Driver Name',
                  controller: driverNameController,
                  keyboard: TextInputType.name,
                ),
                const SizedBox(height: 24),
                _textFields(
                  label: "Driver's Email",
                  length: 20,
                  controller: driverEmailController,
                  keyboard: TextInputType.emailAddress,
                ),
                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                  style: ButtonStyle(
                    foregroundColor: WidgetStatePropertyAll(Colors.white),
                    backgroundColor: WidgetStatePropertyAll(Colors.blue)
                  ),
                        icon: const Icon(Icons.save),
                        label: const Text("Register Vehicle"),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            isLoading = true;
                            //add the method here ya kujaza kwa firebase db
                            MatatuOwner().addDriver(
                              name: driverNameController.text,
                              email: driverEmailController.text,
                              vehicleId: vehicleNumberController.text,
                              nationalId: int.tryParse(
                                driverIdController.text.toString(),
                              )!,
                            );
                          }
                          isLoading = false;
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
