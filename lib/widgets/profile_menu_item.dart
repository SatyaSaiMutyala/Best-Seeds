import 'package:flutter/material.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Color? iconColor;
  final bool isLogout;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.iconColor,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.05,
          vertical: height * 0.02,
        ),
        // decoration: BoxDecoration(
        //   color: isLogout ? const Color(0xFFF5F5F5) : Colors.white,
        //   border: Border(
        //     bottom: BorderSide(
        //       color: Colors.grey.shade200,
        //       width: 1,
        //     ),
        //   ),
        // ),
        child: Row(
          children: [
            Icon(
              icon,
              size: width * 0.06,
              color: iconColor ?? const Color(0xFF0077C8),
            ),
            SizedBox(width: width * 0.04),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: width * 0.042,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: width * 0.06,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
