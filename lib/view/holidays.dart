import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HolidaysPage extends StatefulWidget {
  const HolidaysPage({super.key});

  @override
  State<HolidaysPage> createState() => _HolidaysPageState();
}

class _HolidaysPageState extends State<HolidaysPage> {
  final Color blueSteel = const Color(0xFF4682B4);

  final List<Map<String, dynamic>> holidays = [
    {
      "title": "Independence Day",
      "date": DateTime(2025, 8, 14),
      "type": "Public Holiday"
    },
    {
      "title": "Eid-ul-Adha",
      "date": DateTime(2025, 6, 7),
      "type": "Religious Holiday"
    },
    {
      "title": "Company Foundation Day",
      "date": DateTime(2025, 3, 1),
      "type": "Company Holiday"
    },
  ];

  void _addOrEditHoliday({Map<String, dynamic>? holiday, int? index}) {
    final TextEditingController titleController =
        TextEditingController(text: holiday?["title"] ?? "");
    final TextEditingController typeController =
        TextEditingController(text: holiday?["type"] ?? "");
    DateTime? selectedDate = holiday?["date"];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(holiday == null ? "Add Holiday" : "Edit Holiday"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Holiday Name"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: typeController,
                decoration: const InputDecoration(labelText: "Holiday Type"),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: blueSteel,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    builder: (context, child) => Theme(
                      data: ThemeData.light().copyWith(
                        colorScheme: ColorScheme.light(
                          primary: blueSteel,
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: Colors.black,
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (pickedDate != null) selectedDate = pickedDate;
                  setState(() {});
                },
                child: Text(
                  selectedDate == null
                      ? "Select Date"
                      : DateFormat("dd MMM yyyy").format(selectedDate!),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: blueSteel),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: blueSteel,
            ),
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  typeController.text.isNotEmpty &&
                  selectedDate != null) {
                setState(() {
                  if (holiday == null) {
                    holidays.add({
                      "title": titleController.text,
                      "type": typeController.text,
                      "date": selectedDate!,
                    });
                  } else {
                    holidays[index!] = {
                      "title": titleController.text,
                      "type": typeController.text,
                      "date": selectedDate!,
                    };
                  }
                });
                Navigator.pop(context);
              }
            },
            child: const Text(
              "Add / Update",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteHolidayPlaceholder(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Delete will be handled from controller later"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: blueSteel,
        title: const Text(
          "Holidays",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: holidays.length,
        itemBuilder: (context, index) {
          final holiday = holidays[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: CircleAvatar(
                backgroundColor: blueSteel.withOpacity(0.15),
                child: const Icon(Icons.event, color: Color(0xFF4682B4)),
              ),
              title: Text(
                holiday["title"],
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(
                "${DateFormat("dd MMM yyyy").format(holiday["date"])} • ${holiday["type"]}",
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == "edit") {
                    _addOrEditHoliday(holiday: holiday, index: index);
                  } else if (value == "delete") {
                    _deleteHolidayPlaceholder(index);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: "edit", child: Text("Edit")),
                  PopupMenuItem(value: "delete", child: Text("Delete")),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: blueSteel,
        onPressed: () => _addOrEditHoliday(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
