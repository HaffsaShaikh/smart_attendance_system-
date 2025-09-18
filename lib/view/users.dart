import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_attendance_system/controller/admin_controller.dart';
import 'package:smart_attendance_system/view/userdetail.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Color blueSteel = const Color(0xFF4682B4);
  final AdminController _adminController = Get.put(AdminController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: blueSteel,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Users", style: TextStyle(color: Colors.white)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "Registered"),
            Tab(text: "Pending"),
          ],
        ),
      ),
      body: Obx(() {
        if (_adminController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return TabBarView(
          controller: _tabController,
          children: [
            // Registered Users
            _buildUserList(_adminController.registeredUsers, false),
            // Pending Users
            _buildUserList(_adminController.pendingUsers, true),
          ],
        );
      }),
    );
  }

  Widget _buildUserList(List users, bool isPending) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final profile = user['profile'] ?? {};

        return GestureDetector(
          onTap: () {
            Get.to(() => UserDetailsPage(
                  name: profile['fullName'] ?? 'No Name',
                  email: user['email'] ?? 'No Email',
                  designation: profile['designation'] ?? 'Staff',
                  isPending: isPending,
                ));
          },
          child: Container(
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
                backgroundColor: blueSteel.withOpacity(0.2),
                child: const Icon(Icons.person, color: Color(0xFF4682B4)),
              ),
              title: Text(profile['fullName'] ?? 'No Name',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(user['email'] ?? 'No Email'),
              trailing: isPending
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildActionIcon(Colors.green, () {
                          _adminController.approveUser(user['id']);
                        }),
                        const SizedBox(width: 8),
                        _buildActionIcon(Colors.red, () {
                          _adminController.rejectUser(user['id']);
                        }),
                      ],
                    )
                  : const Icon(Icons.check, color: Colors.green),
            ),
          ),
        );
      },
    );
  }

  // Tick / Cross icons
  Widget _buildActionIcon(Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(color == Colors.green ? Icons.check : Icons.close,
            color: color, size: 20),
      ),
    );
  }
}
