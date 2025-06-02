import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Политики конфиденциальности'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. Types of Data We Collect',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 12),

            Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
              style: TextStyle(
                height: 1.6,
                color: Colors.black87,
              ),
            ),

            SizedBox(height: 24),

            Text(
              '2. Use of Your Personal Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 12),

            Text(
              'Magna etiam tempor orci eu lobortis elementum nibh tellus molestie. Vulputate enim nulla aliquet porttitor lacus. Orci sagittis eu volutpat odio. Cras semper auctor neque vitae tempus quam pellentesque nec nam. Ornare massa eget egestas purus viverra accumsan in nisl.',
              style: TextStyle(
                height: 1.6,
                color: Colors.black87,
              ),
            ),

            SizedBox(height: 24),

            Text(
              '3. Disclosure of Your Personal Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 12),

            Text(
              'Consequat id porta nibh venenatis cras sed felis eget velit aliquet. Donec pretium vulputate sapien nec sagittis aliquam malesuada bibendum arcu. Sed libero enim sed faucibus turpis in eu mi bibendum neque. Bibendum ut tristique et egestas quis. Id neque aliquam vestibulum morbi blandit cursus risus at. Purus ut faucibus pulvinar elementum integer enim. Tellus cras adipiscing enim eu turpis egestas pretium aenean pharetra.',
              style: TextStyle(
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}