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
        //create sacco official  user
        await SaccoOfficial().signUp(
          email: emailController.text,
          password: passwordController.text,
          id: int.tryParse(idNumberController.text)!,
          name: nameController.text,
        );
      }
      // if (!mounted) Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: idNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Your Id Number',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  items: roles
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedRole = v),
                  decoration: const InputDecoration(labelText: 'Select Role'),
                ),
                const SizedBox(height: 18),
                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () async {
                          await _signUp(category: widget.selectedRole);
                        },
                        child: const Text('Create account'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
