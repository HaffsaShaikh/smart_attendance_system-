import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../../controller/admin_controller.dart';

class LeaveDetailsPage extends StatefulWidget {
  final Map<String, dynamic> leave;

  const LeaveDetailsPage({super.key, required this.leave});

  @override
  State<LeaveDetailsPage> createState() => _LeaveDetailsPageState();
}

class _LeaveDetailsPageState extends State<LeaveDetailsPage> {
  final AdminController _adminController = Get.find<AdminController>();
  final TextEditingController _remarksController = TextEditingController();
  String? status;
  final Color blueSteel = const Color(0xFF4682B4);

  @override
  void initState() {
    super.initState();
    status = widget.leave['status'] as String?;
    _remarksController.text = widget.leave['adminRemarks'] ?? '';
  }

  int _calculateDays(DateTime? from, DateTime? to) {
    if (from == null || to == null) return 0;
    return to.difference(from).inDays + 1;
  }

  Future<void> _updateLeaveStatus(String newStatus) async {
    final leaveId = widget.leave['id'];
    final remarks = _remarksController.text.trim();

    await _adminController.updateLeaveStatus(leaveId, newStatus, remarks);

    // Update local widget data reactively
    setState(() {
      status = newStatus.toLowerCase();
      widget.leave['status'] = newStatus.toLowerCase();
      widget.leave['adminRemarks'] = remarks;
    });
  }

  @override
  Widget build(BuildContext context) {
    final leave = widget.leave;
    final fromDate = leave['fromDate'] as DateTime?;
    final toDate = leave['toDate'] as DateTime?;
    final days = _calculateDays(fromDate, toDate);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title:
            const Text('Leave Details', style: TextStyle(color: Colors.white)),
        backgroundColor: blueSteel,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('User', leave['user'] ?? 'Unknown'),
                  _buildDetailRow(
                      'From',
                      fromDate != null
                          ? DateFormat('dd MMM yyyy').format(fromDate)
                          : 'N/A'),
                  _buildDetailRow(
                      'To',
                      toDate != null
                          ? DateFormat('dd MMM yyyy').format(toDate)
                          : 'N/A'),
                  _buildDetailRow('Days', days > 0 ? '$days days' : 'N/A'),
                  _buildDetailRow('Type', leave['type'] ?? 'Not specified'),
                  _buildDetailRow(
                      'Reason', leave['reason'] ?? 'No reason given'),
                  const SizedBox(height: 16),
                  const Text(
                    'Admin Remarks:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _remarksController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: 'Enter remarks here...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: blueSteel),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: status != 'approved'
                              ? () => _updateLeaveStatus('Approved')
                              : null,
                          icon: const Icon(Icons.check_circle,
                              color: Colors.white),
                          label: const Text('Approve',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: status != 'rejected'
                              ? () => _updateLeaveStatus('Rejected')
                              : null,
                          icon: const Icon(Icons.cancel, color: Colors.white),
                          label: const Text('Reject',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
                fontSize: 15),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(fontSize: 15, color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }
}
