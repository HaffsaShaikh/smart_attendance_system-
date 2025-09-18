import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controller/admin_controller.dart';
import 'leavedetails.dart';

class LeavesPage extends StatefulWidget {
  const LeavesPage({super.key});

  @override
  State<LeavesPage> createState() => _LeavesPageState();
}

class _LeavesPageState extends State<LeavesPage> {
  final Color blueSteel = const Color(0xFF4682B4);
  final AdminController _adminController = Get.put(AdminController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Leaves", style: TextStyle(color: Colors.white)),
        backgroundColor: blueSteel,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () async {
              final now = DateTime.now();
              final picked = await showMonthPicker(
                context: context,
                initialDate: _adminController.selectedMonth.value,
                firstDate: DateTime(now.year - 5),
                lastDate: DateTime(now.year + 5),
              );
              if (picked != null) {
                _adminController
                    .changeMonth(DateTime(picked.year, picked.month));
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        if (_adminController.isLoadingLeaves.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final leaves = _adminController.monthLeaves;
        if (leaves.isEmpty) {
          return const Center(
            child: Text(
              "No leaves found for this month.",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: leaves.length,
          itemBuilder: (context, index) {
            final leave = leaves[index];
            final fromDate = leave['fromDate'] as DateTime?;
            final toDate = leave['toDate'] as DateTime?;
            final status = leave['status'] ?? 'pending';

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 4))
                ],
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                leading: CircleAvatar(
                  backgroundColor: _getStatusColor(status).withOpacity(0.15),
                  child: Icon(Icons.person, color: _getStatusColor(status)),
                ),
                title: Text(leave['user'] ?? 'Unknown',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16)),
                subtitle: Text(
                  "${fromDate != null ? DateFormat('dd MMM yyyy').format(fromDate) : '-'} → ${toDate != null ? DateFormat('dd MMM yyyy').format(toDate) : '-'}",
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                trailing: Text(status.toUpperCase(),
                    style: TextStyle(
                        color: _getStatusColor(status),
                        fontWeight: FontWeight.bold)),
                onTap: () async {
                  final updatedStatus = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => LeaveDetailsPage(leave: leave)),
                  );

                  if (updatedStatus != null) {
                    _adminController.fetchLeaves(); // refresh after update
                  }
                },
              ),
            );
          },
        );
      }),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

/// Custom month picker using showDatePicker
Future<DateTime?> showMonthPicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) async {
  return await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    initialEntryMode: DatePickerEntryMode.calendar,
    selectableDayPredicate: (day) => day.day == 1, // only first day selectable
    helpText: 'Select Month',
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Color(0xFF4682B4),
            onPrimary: Colors.white,
            onSurface: Colors.black87,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: Color(0xFF2575FC)),
          ),
        ),
        child: child!,
      );
    },
  );
}
