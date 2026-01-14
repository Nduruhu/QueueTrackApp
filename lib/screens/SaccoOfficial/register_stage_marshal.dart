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

  TextFormField textFormField({
    required String label,
    required TextEditingController controller,
    required TextInputType keyboard,
    required bool obscure,
  }) {
    return TextFormField(
      keyboardType: keyboard,
      obscureText: obscure,
      controller: controller,
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register Stage Marshal")),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            textFormField(
              label: 'Email',
              controller: emailController,
              keyboard: TextInputType.emailAddress,
              obscure: false,
            ),
            const SizedBox(height: 10),
            textFormField(
              label: 'Name',
              controller: nameController,
              keyboard: TextInputType.name,
              obscure: false,
            ),
            const SizedBox(height: 10),
            textFormField(
              label: 'National ID',
              controller: idController,
              keyboard: TextInputType.number,
              obscure: false,
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: (!isLoading)
                      ? () {
                          isLoading = true;
                          //register method here
                          if (_formKey.currentState!.validate()) {
                            SaccoOfficial().addStageMarshal(
                              name: nameController.text,
                              email: emailController.text,
                              nationalId: int.tryParse(idController.text)!,
                            );
                          }
                          isLoading = false;
                        }
                      : null,
                  child: Text('Sign them up'),
                ),
                ElevatedButton(
                  onPressed: (!isLoading)
                      ? () {
                          Navigator.pop(context);
                        }
                      : null,
                  child: Text('Exit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
