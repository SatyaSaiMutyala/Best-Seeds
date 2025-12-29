import 'package:flutter/material.dart';
import '../widgets/profile_menu_item.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            /// ================= Header =================
            _buildHeader(context, width, height),

            /// ================= Profile Info =================
            _buildProfileInfo(width, height),

            SizedBox(height: height * 0.03),

            /// ================= Menu Items =================
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ProfileMenuItem(
                      icon: Icons.notifications_outlined,
                      title: 'Notification',
                      onTap: () {},
                    ),
                    ProfileMenuItem(
                      icon: Icons.description_outlined,
                      title: 'Bookings',
                      onTap: () {},
                    ),
                    ProfileMenuItem(
                      icon: Icons.local_shipping_outlined,
                      title: 'Vehicle Tracking',
                      onTap: () {},
                    ),
                    ProfileMenuItem(
                      icon: Icons.help_outline,
                      title: 'Help',
                      onTap: () {},
                    ),
                    ProfileMenuItem(
                      icon: Icons.share_outlined,
                      title: 'Share this app',
                      onTap: () {},
                    ),
                    ProfileMenuItem(
                      icon: Icons.description_outlined,
                      title: 'Terms & conditions',
                      onTap: () {},
                    ),
                    ProfileMenuItem(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: () {},
                    ),
                    SizedBox(height: height * 0.02),
                    ProfileMenuItem(
                      icon: Icons.logout,
                      title: 'Logout',
                      iconColor: const Color(0xFF0077C8),
                      isLogout: true,
                      onTap: () {
                        _showLogoutDialog(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double width, double height) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.05,
        vertical: height * 0.02,
      ),
      color: Colors.white,
      child: Row(
        children: [
          Text(
            'Profile section',
            style: TextStyle(
              fontSize: width * 0.055,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(double width, double height) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.05,
        vertical: height * 0.02,
      ),
      color: Colors.white,
      child: Row(
        children: [
          /// Profile Avatar
          Container(
            width: width * 0.25,
            height: width * 0.25,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade300,
            ),
            child: Icon(
              Icons.person,
              size: width * 0.12,
              color: Colors.grey.shade500,
            ),
          ),
          SizedBox(width: width * 0.04),

          /// Name and Phone
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ramesh Kumar',
                style: TextStyle(
                  fontSize: width * 0.048,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: height * 0.005),
              Text(
                '+91875867688',
                style: TextStyle(
                  fontSize: width * 0.04,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Logout',
            style: TextStyle(
              fontSize: width * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              fontSize: width * 0.04,
              color: Colors.grey.shade700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: width * 0.04,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                 Navigator.pushReplacementNamed(context, '/employeeLogin');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0077C8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Logout',
                style: TextStyle(
                  fontSize: width * 0.04,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
