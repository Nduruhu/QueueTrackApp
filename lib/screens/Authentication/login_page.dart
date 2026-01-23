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
  final TextEditingController stageMarshalIdController =
      TextEditingController();
  final TextEditingController driverNameController = TextEditingController();
  final TextEditingController stageMarshalEmailController =
      TextEditingController();
  final TextEditingController vehicleNumberController = TextEditingController();

  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  //reusable widget
  Widget _textField({
    required String label,
    required TextEditingController controller,
    required TextInputType keyboard,
    required bool obscure,
    TextCapitalization capitalValue = TextCapitalization.none,
    required int maxLength,
    required int minLength,
    required Icon leadingIcon,
  }) {
    return TextFormField(
      
      controller: controller,
      keyboardType: keyboard,
      obscureText: obscure,
      maxLength: maxLength,
      minLines: minLength,
      decoration: InputDecoration(
        icon: leadingIcon,
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
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue,Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(22.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: width > 600 ? 520 : double.infinity,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'QueueTrack',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Sign in to manage your matatu stage',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (widget.selectedRole.toLowerCase() ==
                                'sacco_official' ||
                            widget.selectedRole.toLowerCase() == 'matatu_owner')
                          _textField(
                            leadingIcon: Icon(Icons.email),
                            label: 'Email',
                            controller: emailController,
                            keyboard: TextInputType.emailAddress,
                            obscure: false,
                            minLength: 1,
                            maxLength: 25,
                          ),
                        if (widget.selectedRole.toLowerCase() ==
                                'sacco_official' ||
                            widget.selectedRole.toLowerCase() == 'matatu_owner')
                          const SizedBox(height: 18),
                        if (widget.selectedRole.toLowerCase() ==
                                'sacco_official' ||
                            widget.selectedRole.toLowerCase() == 'matatu_owner')
                          _textField(
                            leadingIcon: Icon(Icons.lock),
                            label: 'Password',
                            controller: passwordController,
                            keyboard: TextInputType.visiblePassword,
                            obscure: true,
                            minLength: 1,
                            maxLength: 15,
                          ),

                        const SizedBox(height: 18),
                        if (widget.selectedRole.toLowerCase() == 'driver')
                          _textField(
                            leadingIcon: Icon(Icons.badge),
                            label: 'Driver Id',
                            controller: driverIdController,
                            keyboard: TextInputType.number,
                            obscure: false,
                            minLength: 1,
                            maxLength: 8,
                          ),
                        const SizedBox(height: 18),
                        if (widget.selectedRole.toLowerCase() == 'driver')
                          _textField(
                            leadingIcon: Icon(Icons.confirmation_num),
                            label: 'Vehicle Number (Capital Letters)',
                            controller: vehicleNumberController,
                            keyboard: TextInputType.text,
                            obscure: false,
                            capitalValue: TextCapitalization.characters,
                            minLength: 1,
                            maxLength: 8,
                          ),
                        const SizedBox(height: 18),
                        if (widget.selectedRole.toLowerCase() ==
                            'stage_marshal')
                          _textField(
                            leadingIcon: Icon(Icons.email),
                            label: 'Stage Marshal Email ',
                            controller: stageMarshalEmailController,
                            keyboard: TextInputType.emailAddress,
                            obscure: false,
                            minLength: 1,
                            maxLength: 25,
                          ),
                        if (widget.selectedRole.toLowerCase() ==
                            'stage_marshal')
                          const SizedBox(height: 18),
                        if (widget.selectedRole.toLowerCase() ==
                            'stage_marshal')
                          _textField(
                            leadingIcon: Icon(Icons.badge),
                            label: 'Stage Marshal Id',
                            controller: stageMarshalIdController,
                            keyboard: TextInputType.number,
                            obscure: false,
                            minLength: 1,
                            maxLength: 8,
                          ),
                        const SizedBox(height: 18),
                        isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                          style: ButtonStyle(
                            foregroundColor: WidgetStatePropertyAll(Colors.white),
                            backgroundColor: WidgetStatePropertyAll(Colors.blue),
                            
                          ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    isLoading = !isLoading;
                                    if (widget.selectedRole
                                            .toLowerCase() == //sign in ya matatu owner
                                        'matatu_owner') {
                                      final response = await MatatuOwner()
                                          .signIn(
                                            email: emailController.text,
                                            password: passwordController.text,
                                          );
                                      if (response == true) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                MatatuOwnerDashboard(),
                                          ),
                                        );
                                      }
                                      isLoading = !isLoading;
                                    } else if (widget
                                            .selectedRole //sign in ya driver
                                            .toLowerCase() ==
                                        'driver') {
                                      int id = int.tryParse(
                                        driverIdController.text.toString(),
                                      )!;
                                      final response = await Driver()
                                          .signInDriver(
                                            vehicleId:
                                                vehicleNumberController.text,
                                            id: id,
                                          );
                                      if (response == true) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                DriverDashboard(),
                                          ),
                                        );
                                      }

                                      isLoading = !isLoading;
                                    } else if (widget
                                            .selectedRole //sign in a sacco official
                                            .toLowerCase()
                                            .toString() ==
                                        'sacco_official') {
                                      final response = await SaccoOfficial()
                                          .signIn(
                                            email: emailController.text,
                                            password: passwordController.text,
                                          );
                                      if (response == true) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SaccoOfficialDashboard(),
                                          ),
                                        );
                                        isLoading = !isLoading;
                                      } else {
                                        return;
                                      }
                                      isLoading = !isLoading;
                                    } else if (widget.selectedRole
                                            .toLowerCase()
                                            .toString() ==
                                        'stage_marshal') {
                                      //sign in stage marshal
                                      final response = await StageMarshal()
                                          .signIn(
                                            email: emailController.text,
                                            id: int.tryParse(
                                              stageMarshalIdController.text,
                                            )!,
                                          );
                                      if (response == true) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                StageMarshalDashboard(),
                                          ),
                                        );
                                        isLoading = !isLoading;
                                      }
                                    }
                                  }
                                },
                                child: const Text('Login'),
                              ),
                        const SizedBox(height: 8),
                        (widget.selectedRole.toLowerCase() ==
                                    'sacco_official' ||
                                widget.selectedRole.toLowerCase() ==
                                    'matatu_owner')
                            ? TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SignUpScreen(
                                        selectedRole: widget.selectedRole,
                                      ),
                                    ),
                                  ); // ✅ fixed
                                },
                                child: const Text(
                                  "Don't have an account? Sign up",
                                ),
                              )
                            : Text(
                                "No sign in available for ${widget.selectedRole}",
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
