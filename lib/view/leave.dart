import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_attendance_system/view/leaveform.dart';
import '../../controller/leave_controller.dart';

class LeaveDashboardPage extends StatefulWidget {
  const LeaveDashboardPage({super.key});

  @override
  State<LeaveDashboardPage> createState() => _LeaveDashboardPageState();
}

class _LeaveDashboardPageState extends State<LeaveDashboardPage> {
  final LeaveController _leaveController = Get.put(LeaveController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // 🔹 Custom Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            decoration: const BoxDecoration(
              color: Color(0xFF4682B4),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Leave Dashboard",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // 🔹 Body
          Expanded(
            child: Obx(() {
              final currentStats = _leaveController.currentMonthStats;
              final monthLeaves = _leaveController.currentMonthLeaves;

              return Column(
                children: [
                  // Current Month Label
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      _leaveController.currentMonthLabel,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),

                  // Top Stats Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        _StatCard(
                            label: "Total",
                            count: currentStats['totalQuota']!,
                            color: Colors.blue),
                        const SizedBox(width: 8),
                        _StatCard(
                            label: "Approved",
                            count: currentStats['approved']!,
                            color: Colors.green),
                        const SizedBox(width: 8),
                        _StatCard(
                            label: "Pending",
                            count: currentStats['pending']!,
                            color: Colors.orange),
                        const SizedBox(width: 8),
                        _StatCard(
                            label: "Rejected",
                            count: currentStats['rejected']!,
                            color: Colors.red),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  const Divider(),

                  // Leave List (Scrollable)
                  Expanded(
                    child: monthLeaves.isEmpty
                        ? const Center(
                            child: Text(
                              "No leaves this month",
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black54),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: monthLeaves.length,
                            itemBuilder: (context, index) {
                              final leave = monthLeaves[index];

                              if (leave.status == 'cancelled') {
                                return const SizedBox.shrink();
                              }

                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blue[50],
                                    child: const Icon(Icons.description,
                                        color: Colors.blue),
                                  ),
                                  title: Text(
                                    leave.type,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        "From: ${DateFormat('dd MMM yyyy').format(leave.fromDate)}",
                                        style: const TextStyle(
                                            color: Colors.black54),
                                      ),
                                      Text(
                                        "To: ${DateFormat('dd MMM yyyy').format(leave.toDate)}",
                                        style: const TextStyle(
                                            color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                  trailing: leave.status == 'pending'
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.orange,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                leave.status.toUpperCase(),
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            IconButton(
                                              icon: const Icon(Icons.cancel,
                                                  color: Colors.red, size: 30),
                                              onPressed: () {
                                                _leaveController
                                                    .cancelLeave(leave.leaveId);
                                              },
                                            ),
                                          ],
                                        )
                                      : Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: leave.status == 'approved'
                                                ? Colors.green
                                                : Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            leave.status.toUpperCase(),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12),
                                          ),
                                        ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF4682B4),
        onPressed: () {
          Get.to(() => const LeaveApplyForm());
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Apply Leave",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

// 🔹 StatCard Widget
class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatCard({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
