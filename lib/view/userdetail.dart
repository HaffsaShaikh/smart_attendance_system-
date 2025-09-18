import 'package:flutter/material.dart';

class UserDetailsPage extends StatefulWidget {
  final String name;
  final String email;
  final String designation;
  final bool isPending;

  const UserDetailsPage({
    super.key,
    required this.name,
    required this.email,
    required this.designation,
    this.isPending = false,
  });

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  bool? approved;

  final Color primaryColor = const Color(0xFF4682B4);
  final Color backgroundColor = const Color(0xFFF3F4F6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 50, color: primaryColor),
                ),
                const SizedBox(height: 12),
                Text(widget.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(widget.email,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 10),
                _buildStatusBadge(),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildInfoCard(
                    icon: Icons.person, title: "Full Name", value: widget.name),
                _buildInfoCard(
                    icon: Icons.email,
                    title: "Email Address",
                    value: widget.email),
                _buildInfoCard(
                    icon: Icons.badge,
                    title: "Designation",
                    value: widget.designation),
              ],
            ),
          ),
          if (widget.isPending && approved == null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSimpleButton(
                      color: Colors.green,
                      text: "Approve",
                      onTap: () => setState(() => approved = true)),
                  _buildSimpleButton(
                      color: Colors.red,
                      text: "Reject",
                      onTap: () => setState(() => approved = false)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    if (approved == true) return _statusChip("Approved", Colors.green);
    if (approved == false) return _statusChip("Rejected", Colors.red);
    if (widget.isPending) return _statusChip("Pending", Colors.orange);
    return _statusChip("Registered", Colors.green);
  }

  Widget _statusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child:
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
    );
  }

  Widget _buildInfoCard(
      {required IconData icon, required String title, required String value}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: primaryColor.withOpacity(0.15),
          child: Icon(icon, color: primaryColor),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: Text(value, style: const TextStyle(fontSize: 14)),
      ),
    );
  }

  Widget _buildSimpleButton(
      {required Color color,
      required String text,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        decoration:
            BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
