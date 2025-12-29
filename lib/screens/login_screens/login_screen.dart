import 'package:bestseeds/screens/login_screens/employee_login_screen.dart';
import 'package:flutter/material.dart';
import '../main_navigation_screen.dart';

class DriverLoginScreen extends StatelessWidget {
  const DriverLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final height = media.size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0077C8),
              Color(0xFF3FA9F5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    /// ================= Header + Text =================
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.06,
                        vertical: height * 0.02,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Header row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                               Text(
                                'Login as Driver',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: width * 0.055 ,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const EmployeeLoginScreen(),
                                    ),
                                  ),
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.more_horiz,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
                          ),

                          SizedBox(height: height * 0.07),

                          /// Title
                          Text(
                            'Ready To Begin Your\nFirst Delivery',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: width * 0.07,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),

                          SizedBox(height: height * 0.02),

                          /// Subtitle
                          Text(
                            'Just One Quick Step Remains To Get Started\nWith Your Deliveries.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: width * 0.038,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// ================= Image Section =================
                    Flexible(
                      child: Center(
                        child: Image.asset(
                          'assets/images/login_truck.png',
                          width: width * 1,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    /// ================= Bottom Card =================
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.06,
                        vertical: height * 0.035,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Log in using your mobile number to\nstart delivering',
                            style: TextStyle(
                              fontSize: width * 0.045,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          SizedBox(height: height * 0.025),

                          /// Mobile input
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  '+91',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    keyboardType: TextInputType.phone,
                                    decoration: const InputDecoration(
                                      hintText: 'Enter Mobile Number',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: height * 0.03),

                          /// Continue button
                          SizedBox(
                            width: double.infinity,
                            height: height * 0.06,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const MainNavigationScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0077C8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Continue',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ),

                          SizedBox(height: height * 0.02),

                          /// Footer text
                          Center(
                            child: Text(
                              'By sign-in, I agree to the Terms & Conditions\nand Privacy Policy of BestSeed.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: width * 0.032,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
