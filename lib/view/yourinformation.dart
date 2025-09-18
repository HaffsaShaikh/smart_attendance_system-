import 'package:flutter/material.dart';

class InformationPage extends StatelessWidget {
  const InformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color blueSteel = const Color(0xFF4682B4);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: blueSteel,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "Your Information",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),
          _buildInfoCard(
            icon: Icons.work_outline,
            title: "Designation",
            value: "Software Engineer",
            themeColor: blueSteel,
          ),
          _buildInfoCard(
            icon: Icons.cake_outlined,
            title: "Date of Birth",
            value: "15 March 2000",
            themeColor: blueSteel,
          ),
          _buildInfoCard(
            icon: Icons.location_on_outlined,
            title: "Address",
            value: "Karachi, Pakistan",
            themeColor: blueSteel,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color themeColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: themeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: themeColor),
        ),
        title: Text(
          title,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600, color: themeColor),
        ),
        subtitle: Text(
          value,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
        ),
      ),
    );
  }
}
