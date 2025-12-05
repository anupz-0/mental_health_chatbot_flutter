import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/background.dart';
import 'next_screen.dart'; // Import NextScreen here

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double logoWidth = screenWidth * 0.9 > 550 ? 550 : screenWidth * 0.9;
    final double logoHeight = screenHeight * 0.4 > 550 ? 550 : screenHeight * 0.4;

    return Scaffold(
      body: Stack(
        children: [
          const Background(),

          // Logo at top center (bigger responsive)
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Image.asset(
                'assets/images/logo.png',
                width: logoWidth,
                height: logoHeight,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // MindCare title
          Positioned(
            top: screenHeight * 0.4,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'MindCare',
                style: GoogleFonts.poppins(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF7A8CFF),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Mental Health Support subtitle
          Positioned(
            top: screenHeight * 0.47,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Mental Health Support',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2F756B),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Start Button with navigation
          Positioned(
            top: screenHeight * 0.6,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NextScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7A8CFF),
                  minimumSize: const Size(190, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Start',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // Bottom description text
          Positioned(
            bottom: 65,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Text(
                  'Your AI companion for mental health support.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Share your thoughts and feelings in a safe, non-judgmental space',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          // Footer
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/images/l1.png',
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'Private & Secure',
                      style: GoogleFonts.nunito(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Image.asset(
                      'assets/images/l2.png',
                      width: 13,
                      height: 13,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '24/7 Support',
                      style: GoogleFonts.nunito(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
