import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_attendance_system/view/leaveform.dart';

class LeaveRecord extends StatefulWidget {
  const LeaveRecord({super.key});

  @override
  State<LeaveRecord> createState() => _LeaveRecordState();
}

class _LeaveRecordState extends State<LeaveRecord> {
  late DateTime now;
  late String currentMonth;

  // Example Data
  List<Map<String, dynamic>> leaves = [
    {
      "type": "Sick Leave",
      "from": DateTime(2025, 9, 5),
      "to": DateTime(2025, 9, 7),
      "status": "Approved"
    },
    {
      "type": "Casual Leave",
      "from": DateTime(2025, 9, 12),
      "to": DateTime(2025, 9, 12),
      "status": "Pending"
    },
    {
      "type": "Annual Leave",
      "from": DateTime(2025, 8, 1),
      "to": DateTime(2025, 8, 10),
      "status": "Rejected"
    },
  ];

  @override
  void initState() {
    super.initState();
    now = DateTime.now();
    currentMonth = DateFormat('MMMM yyyy').format(now);
  }

  @override
  Widget build(BuildContext context) {
    final currentMonthLeaves = leaves
        .where((leave) =>
            (leave["from"] as DateTime).month == now.month &&
            (leave["from"] as DateTime).year == now.year)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,

      // ✅ AppBar with Notification Icon
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {
              // TODO: Navigate to Notifications Page or show popup
            },
          ),
        ],
      ),

      // ✅ Floating button for Apply Leave
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue,
        onPressed: () {
          Get.to(() => const ApplyLeavePage());
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Apply Leave",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // ✅ Title Row with Leaves text
            const Text(
              "All Leaves",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),

            // ✅ Leave Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard("12", "Leave Balance",
                      Colors.lightBlue.shade50, Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                      "8", "Approved", Colors.green.shade50, Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    "2",
                    "Pending",
                    Colors.green.shade50,
                    Colors.green.shade900,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                      "2", "Rejected", Colors.red.shade50, Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // ✅ Leave History (Current Month)
            Text(
              "Leave History – $currentMonth",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            if (currentMonthLeaves.isEmpty)
              const Text(
                "No leave record for this month",
                style: TextStyle(color: Colors.black54),
              )
            else
              ...currentMonthLeaves.map((leave) {
                final from = leave["from"] as DateTime;
                final to = leave["to"] as DateTime;
                String dateRange = from == to
                    ? DateFormat('d MMM').format(from)
                    : "${DateFormat('d MMM').format(from)} - ${DateFormat('d MMM').format(to)}";

                Color statusColor;
                switch (leave["status"]) {
                  case "Approved":
                    statusColor = Colors.green;
                    break;
                  case "Pending":
                    statusColor = Colors.green.shade900;
                    break;
                  case "Rejected":
                    statusColor = Colors.red;
                    break;
                  default:
                    statusColor = Colors.grey;
                }

                return _buildLeaveTile(
                  leave["type"].toString(),
                  dateRange,
                  leave["status"].toString(),
                  statusColor,
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  // ✅ Summary Card
  static Widget _buildSummaryCard(
      String value, String title, Color bgColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: borderColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Leave Tile
  static Widget _buildLeaveTile(
      String type, String date, String status, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.8), width: 1.2),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: color, size: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Text(
            status,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
