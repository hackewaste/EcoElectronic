import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? currentUser() {
    return _auth.currentUser;
  }
}

class DailyActivity extends StatefulWidget {
  @override
  _DailyActivityState createState() => _DailyActivityState();
}

class _DailyActivityState extends State<DailyActivity> {
  Map<String, int> dailyCounts = {};
  bool isLoading = true;
  DateTime? selectedDate;
  int currentItemCount = 0;

  @override
  void initState() {
    super.initState();
    fetchCompletedRequests();
  }

  Future<void> fetchCompletedRequests() async {
    final user = AuthService().currentUser();
    if (user == null) {
      print("No authenticated user found.");
      setState(() => isLoading = false);
      return;
    }

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('usertemporary')
          .where('status', isEqualTo: 'completed')
          .where('uid', isEqualTo: user.uid)
          .get();

      Map<String, int> counts = {};

      for (var doc in snapshot.docs) {
        DateTime? scheduledDate = DateTime.tryParse(doc['scheduledDate']);
        if (scheduledDate == null) {
          print("Invalid date format: ${doc['scheduledDate']}");
          continue;
        }

        String formattedDate =
            "${scheduledDate.year}-${scheduledDate.month.toString().padLeft(2, '0')}-${scheduledDate.day.toString().padLeft(2, '0')}";

        var results = doc['results'] ?? [];
        int itemCount = 0;
        for (var result in results) {
          if (result['detections'] != null) {
            itemCount += result['detections'].length as int;
          }
        }

        counts.update(formattedDate, (value) => value + itemCount,
            ifAbsent: () => itemCount);
      }

      // Find the date with the maximum count
      String? maxDate;
      int maxCount = 0;
      counts.forEach((date, count) {
        if (count > maxCount) {
          maxCount = count;
          maxDate = date;
        }
      });

      setState(() {
        dailyCounts = counts;
        isLoading = false;

        // Initialize with the max date
        if (maxDate != null) {
          selectedDate = DateTime.parse(maxDate);
          currentItemCount = maxCount;
        } else {
          selectedDate = DateTime.now();
          currentItemCount = 0;
        }
      });
    } catch (e) {
      print("Error fetching completed requests: $e");
      setState(() => isLoading = false);
    }
  }

  Widget _buildActivityLegendItem(String title, Color color) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildDailyActivity(int itemCount, String month, String day) {
    double progress = (itemCount / 100).clamp(0.0, 1.0);

    return Row(
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: Stack(
            children: [
              Center(
                child: SizedBox(
                  width: 130,
                  height: 130,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[300],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$day',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF324F5E),
                      ),
                    ),
                    Text(
                      month,
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Daily Activity',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF324F5E),
                ),
              ),
              const SizedBox(height: 10),
              _buildActivityLegendItem('Recycled Electronics', Colors.green),
              _buildActivityLegendItem('Waste Collected', Colors.amber),
              _buildActivityLegendItem('Volunteers Participated', Colors.red),
            ],
          ),
        ),
      ],
    );
  }

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;

        // Update item count based on the new date
        String formattedDate =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
        currentItemCount = dailyCounts[formattedDate] ?? 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (dailyCounts.isEmpty || selectedDate == null) {
      return const Center(child: Text("No activity found"));
    }

    // Extract day and month for display
    String monthName = _getMonthName(selectedDate!.month);
    String day = selectedDate!.day.toString();

    return Column(
      children: [
        ElevatedButton(
          onPressed: _pickDate,
          child: const Text("Select Date"),
        ),
        _buildDailyActivity(currentItemCount, monthName, day),
      ],
    );
  }

  String _getMonthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return monthNames[month - 1];
  }
}
