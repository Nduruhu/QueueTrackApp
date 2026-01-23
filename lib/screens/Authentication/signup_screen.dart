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
      backgroundColor: Color(0xFFBBDEFB),
      appBar: AppBar(title: const Text(
        style: TextStyle(),
          'Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  maxLength: 20,
                  decoration: const InputDecoration(icon: Icon(Icons.person),labelText: 'Full name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  style: TextStyle(
                    fontWeight: FontWeight.w100
                  ),
                  controller: idNumberController,
                  maxLength: 8,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.badge),
                    labelText: 'Your Id Number',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  maxLength: 25,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(icon: Icon(Icons.email),labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  maxLength: 15,
                  decoration: const InputDecoration(icon: Icon(Icons.lock),labelText: 'Password'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmController,
                  obscureText: true,
                  maxLength: 15,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.lock),
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
                  style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.blue)),
                        onPressed: () async {
                          await _signUp(category: widget.selectedRole);
                        },
                        child: const Text(
                          style: TextStyle(color: Colors.white),
                            'Create account'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
