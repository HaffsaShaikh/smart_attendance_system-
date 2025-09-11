import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controller/leave_controller.dart';
import '../model/leave_model.dart';

class ApplyLeavePage extends StatefulWidget {
  const ApplyLeavePage({super.key});

  @override
  State<ApplyLeavePage> createState() => _ApplyLeavePageState();
}

class _ApplyLeavePageState extends State<ApplyLeavePage> {
  final _formKey = GlobalKey<FormState>();
  final LeaveController _leaveController = Get.find<LeaveController>();

  String? _leaveType;
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _reasonController = TextEditingController();

  // Date Picker
  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  // Success Bottom Sheet
  void _showSuccessDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.blue, size: 70),
              const SizedBox(height: 16),
              const Text(
                "Leave Applied Successfully",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx); // close bottom sheet
                    Navigator.pop(context, true); // go back
                  },
                  child: const Text(
                    "Done",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Apply Leave Function
  void _applyLeave() async {
    if (_formKey.currentState!.validate()) {
      if (_leaveType != null && _startDate != null && _endDate != null) {
        final leave = LeaveModel(
          uid: FirebaseAuth.instance.currentUser!.uid,
          type: _leaveType!,
          fromDate: _startDate!,
          toDate: _endDate!,
          reason: _reasonController.text.trim(),
          status: 'Pending',
        );

        try {
          await _leaveController.applyLeave(leave);
          print("✅ Leave saved to Firestore");
          if (!mounted) return;
          _showSuccessDialog();
        } catch (e) {
          print("❌ Firestore error: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error applying leave: $e")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill all fields")),
        );
      }
    }
  }

  // Input Decoration
  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.blue, width: 1.5),
      ),
    );
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Apply Leave", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Leave Type
                const Text("Leave Type",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _leaveType,
                  hint: const Text("Select Leave Type"),
                  decoration: _fieldDecoration("Select Leave Type"),
                  items: ["Annual", "Casual", "Sick"]
                      .map((type) =>
                          DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (value) => setState(() => _leaveType = value),
                  validator: (value) =>
                      value == null ? "Please select leave type" : null,
                ),
                const SizedBox(height: 16),

                // Start Date
                const Text("Start Date",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _pickDate(context, true),
                  child: InputDecorator(
                    decoration: _fieldDecoration("Select Start Date"),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_startDate == null
                            ? "Select Start Date"
                            : DateFormat('dd MMM yyyy').format(_startDate!)),
                        const Icon(Icons.calendar_today, color: Colors.blue),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // End Date
                const Text("End Date",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _pickDate(context, false),
                  child: InputDecorator(
                    decoration: _fieldDecoration("Select End Date"),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_endDate == null
                            ? "Select End Date"
                            : DateFormat('dd MMM yyyy').format(_endDate!)),
                        const Icon(Icons.calendar_today, color: Colors.blue),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Reason
                const Text("Reason",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _reasonController,
                  decoration: _fieldDecoration("Enter reason for leave"),
                  maxLines: 3,
                  validator: (value) =>
                      value!.isEmpty ? "Please enter reason" : null,
                ),
                const SizedBox(height: 30),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _applyLeave,
                    child: const Text(
                      "Apply Leave",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
