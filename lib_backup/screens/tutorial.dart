import 'package:flutter/material.dart';
import 'homescreen.dart';

class TutorialScreen extends StatefulWidget {
  @override
  _TutorialScreenState createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Welcome to Scan & Learn!',
      'subtitle':
      'Unlock knowledge in a snap. Quickly scan codes, pictures, or text to discover new information.',
      'image': 'assets/tutorial1.png',
    },
    {
      'title': 'How to Scan',
      'subtitle':
      'Tap the scan button and point your camera at a QR code, barcode, or page to begin.',
      'image': 'assets/tutorial2.png',
    },
    {
      'title': 'Instant Feedback',
      'subtitle':
      'See results and related learning materials right after scanning, all in one place!',
      'image': 'assets/tutorial3.png',
    },
    {
      'title': 'Get the Best Experience',
      'subtitle':
      'Grant camera and storage permissions to use all features effectively.',
      'image': 'assets/onboarding4.png',
    },
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _controller.previousPage(
        duration: Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = Color(0xFF0E3C6E);
    final lightBlue = Color(0xFF4A7EBB);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) =>
                    setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 20.0),
                    child: Column(
                      children: [
                        // IMAGE takes big portion
                        Expanded(
                          flex: 4,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: lightBlue.withOpacity(0.25),
                                  blurRadius: 18,
                                  offset: Offset(0, 8),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                page['image']!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 24),

                        // TEXT section
                        Expanded(
                          flex: 3,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Text(
                                  page['title']!,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: primaryBlue,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  page['subtitle']!,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[700],
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 20),

                        // DOTS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _pages.length,
                                (i) => AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              margin: EdgeInsets.symmetric(horizontal: 5),
                              width: _currentPage == i ? 18 : 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _currentPage == i
                                    ? primaryBlue
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 20),

                        // BUTTONS
                        if (index == _pages.length - 1)
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomeScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              padding: EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 6,
                            ),
                            child: Text(
                              'Get Started',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.1,
                              ),
                            ),
                          )
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (_currentPage > 0)
                                OutlinedButton.icon(
                                  onPressed: _previousPage,
                                  icon: Icon(Icons.arrow_back,
                                      color: primaryBlue),
                                  label: Text(
                                    'Back',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: primaryBlue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: primaryBlue),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                )
                              else
                                SizedBox(width: 96),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HomeScreen()),
                                  );
                                },
                                child: Text(
                                  'Skip',
                                  style: TextStyle(
                                    color: primaryBlue,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: _nextPage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: lightBlue,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 28),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Next',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Icon(Icons.arrow_forward,
                                        color: Colors.white, size: 20),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        SizedBox(height: 12),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
