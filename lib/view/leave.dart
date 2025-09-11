import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/leave_controller.dart';
import '../model/leave_model.dart';

class LeaveRecordPage extends StatelessWidget {
  LeaveRecordPage({super.key});

  final LeaveController _leaveController = Get.find<LeaveController>();

  String _formatDate(DateTime date) {
    return DateFormat("dd MMM yyyy").format(date);
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Approved":
        return Colors.green;
      case "Rejected":
        return Colors.red;
      default:
        return Colors.orange; // Pending
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Leave Records", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.grey.shade100,
      body: Obx(() {
        if (_leaveController.leaves.isEmpty) {
          return const Center(
            child: Text(
              "No leave records found",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _leaveController.leaves.length,
          itemBuilder: (context, index) {
            final LeaveModel leave = _leaveController.leaves[index];
            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Leave type + status chip
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          leave.type,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _statusColor(leave.status).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            leave.status,
                            style: TextStyle(
                              color: _statusColor(leave.status),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Date Range
                    Row(
                      children: [
                        const Icon(Icons.date_range,
                            size: 18, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          "${_formatDate(leave.fromDate)} → ${_formatDate(leave.toDate)}",
                          style: const TextStyle(
                              fontSize: 15, color: Colors.black87),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Reason
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.notes, size: 18, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            leave.reason,
                            style: const TextStyle(
                                fontSize: 15, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
