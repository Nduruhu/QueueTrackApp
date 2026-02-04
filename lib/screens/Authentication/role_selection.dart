import 'package:flutter/material.dart';
import 'login_page.dart';

class RoleSelection extends StatefulWidget {
  const RoleSelection({super.key});

  @override
  State<RoleSelection> createState() => _RoleSelectionState();
}

class _RoleSelectionState extends State<RoleSelection> {

  Widget _buildRoleCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05), // Softer shadow for cleaner look
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 28, color: Colors.blue.shade700),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey.shade400)
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Match the primary color used in Login/SignUp
    final Color primaryColor = Colors.blue.shade900;

    return Scaffold(
      backgroundColor: primaryColor, // Blue background for the scaffold
      body: Stack(
        children: [
          // 1. TOP SECTION (Blue Background)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.35,
            child: SafeArea(
              child: Column(
                children: [
                  const Spacer(),

                  // Same Logo as Sign Up Page (Size 50)
                  const Icon(
                    Icons.directions_bus_rounded,
                    color: Colors.white,
                    size: 70,
                  ),
                  const SizedBox(height: 10),

                  // Title in White
                  const Text(
                    'Karibu Queue Track',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle in Light Blue
                  Text(
                    'Select your role to continue',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue.shade100,
                    ),
                  ),

                  const Spacer(flex: 2), // Push content slightly up
                ],
              ),
            ),
          ),

          // 2. BOTTOM SECTION (Content Sheet)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.30, // Start at 30%
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                // Using a very light grey so the White Cards stand out
                color: Color(0xFFF3F4F6),
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 30), // Padding inside the sheet
                      Expanded(
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.zero,
                          children: [
                            _buildRoleCard(
                              title: 'Sacco Official',
                              icon: Icons.badge_outlined,
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => LoginPage(selectedRole: 'sacco_official'))
                                );
                              },
                            ),
                            _buildRoleCard(
                              title: 'Stage Marshal',
                              icon: Icons.person_outline,
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => LoginPage(selectedRole: 'stage_marshal'))
                                );
                              },
                            ),
                            _buildRoleCard(
                              title: 'Matatu Owner',
                              icon: Icons.handshake_outlined,
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => LoginPage(selectedRole: 'matatu_owner'))
                                );
                              },
                            ),
                            _buildRoleCard(
                              title: 'Driver',
                              icon: Icons.directions_car_outlined,
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => LoginPage(selectedRole: 'driver'))
                                );
                              },
                            ),
                            // Extra space at bottom for scrolling
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
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