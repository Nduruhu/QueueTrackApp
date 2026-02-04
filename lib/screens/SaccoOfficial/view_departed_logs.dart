import 'package:flutter/material.dart';
import 'package:queuetrack/Database/sacco_official.dart';
import 'package:intl/intl.dart'; // You might need to add intl package to pubspec.yaml

class ViewDepartedLogs extends StatefulWidget {
  const ViewDepartedLogs({super.key});

  @override
  State<ViewDepartedLogs> createState() => _ViewDepartedLogsState();
}

class _ViewDepartedLogsState extends State<ViewDepartedLogs> {
  DateTime? _selectedDate;

  // Helper to format date string for display
  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return "Unknown Date";
    return dateStr.toString().replaceAll('T', ' ').split('.')[0];
  }

  // Helper to check if two dates are the same day
  bool _isSameDay(DateTime date1, String dateString2) {
    try {
      DateTime date2 = DateTime.parse(dateString2);
      return date1.year == date2.year &&
          date1.month == date2.month &&
          date1.day == date2.day;
    } catch (e) {
      return false;
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade900, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
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
          "Departed Vehicles",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Filter Reset Button
          if (_selectedDate != null)
            IconButton(
              icon: const Icon(Icons.filter_alt_off_rounded, color: Colors.white),
              onPressed: () => setState(() => _selectedDate = null),
            )
        ],
      ),
      body: Column(
        children: [
          // ----------------------------------------
          // NEW DATE FILTER SECTION
          // ----------------------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: InkWell(
              onTap: () => _pickDate(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded, color: Colors.white),
                        const SizedBox(width: 10),
                        Text(
                          _selectedDate == null
                              ? "Filter by Date"
                              : "Showing: ${DateFormat('MMM dd, yyyy').format(_selectedDate!)}",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // White Content Sheet
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FA),
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
                child: StreamBuilder(
                  stream: SaccoOfficial().viewDepartedLogs(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Error loading logs.", style: TextStyle(color: Colors.red.shade400)));
                    }
                    if (!snapshot.hasData) {
                      return _buildEmptyState();
                    }

                    List docs = snapshot.data! as List;

                    // 1. FILTERING LOGIC
                    if (_selectedDate != null) {
                      docs = docs.where((doc) {
                        return _isSameDay(_selectedDate!, doc['queue_date']);
                      }).toList();
                    }

                    // 2. SORTING LOGIC (Latest First)
                    docs.sort((a, b) {
                      String dateA = a['queue_date']?.toString() ?? '';
                      String dateB = b['queue_date']?.toString() ?? '';
                      return dateB.compareTo(dateA);
                    });

                    if (docs.isEmpty) {
                      return _buildEmptyState(
                          message: _selectedDate == null
                              ? "No departed records yet"
                              : "No vehicles departed on this date"
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.08),
                                spreadRadius: 1,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                (index + 1).toString(),
                                style: TextStyle(
                                  color: Colors.orange.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              data['vehicleId'] ?? 'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Row(
                                children: [
                                  Icon(Icons.access_time_rounded, size: 14, color: Colors.grey.shade500),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDate(data['queue_date']),
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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

  Widget _buildEmptyState({String message = "No departed records yet"}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}