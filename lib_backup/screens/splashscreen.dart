import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scan_learn/screens/login.dart';
class SplashScreen extends StatefulWidget{
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3),(){
      Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => LoginScreen(),));
    });
  }
  final Color brandDarkBlue = Color(0xFF192B44);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/images/img4.png',width: 150,height: 150,fit: BoxFit.contain),
              SizedBox(height: 32),
              Text("Scan & Learn",style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: brandDarkBlue,
                letterSpacing: 2,)),
              SizedBox(height: 32),
              Text('See. Scan. Discover.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: brandDarkBlue.withOpacity(0.7),
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,)
            ],
          ),
        ),
      ),
    );
  }
}