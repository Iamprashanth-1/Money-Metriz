import 'package:flutter/material.dart';
import 'package:intro_screen_onboarding_flutter/intro_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreenStatus extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreenStatus> {
  bool _isOnboardingShown = false;

  @override
  void initState() {
    _checkOnboardingStatus();
    super.initState();
  }

  Future<void> _checkOnboardingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isShown = prefs.getBool('onboardingShown') ?? false;
    if (isShown) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => BaseScreen()),
        (Route<dynamic> route) => false,
      );
    } else {
      _setOnboardingStatus(true);

      setState(() {
        _isOnboardingShown = true;
      });
      // OnboardingScreen();
      // Navigator.pushAndRemoveUntil(
      //   context,
      //   MaterialPageRoute(builder: (context) => BaseScreen()),
      //   (Route<dynamic> route) => false,
      // );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _setOnboardingStatus(bool shown) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingShown', shown);
  }

  void _markOnboardingAsShown() async {
    await _setOnboardingStatus(true);
  }

  @override
  Widget build(BuildContext context) {
    return _isOnboardingShown
        ? OnboardingScreen()
        : CircularProgressIndicator(
            backgroundColor: Colors.black,
            color: Colors.black,
          );
  }
}

class OnboardingScreen extends StatelessWidget {
  late Widget OnboardingScreenStatus;
  final List<Introduction> list = [
    Introduction(
      title: 'Credits and Debits',
      subTitle:
          'Analyze your spending to gain insights into your expenses, track spending patterns, and make informed financial decisions.',
      imageUrl: 'assets/images/onboarding4.png',
      titleTextStyle: TextStyle(color: Colors.black),
      subTitleTextStyle: TextStyle(color: Colors.black),
    ),
    Introduction(
      title: 'Analyse your spends',
      subTitle: 'Analyse your spends in different categories',
      imageUrl: 'assets/images/onboarding1.png',
      titleTextStyle: TextStyle(color: Colors.black),
      subTitleTextStyle: TextStyle(color: Colors.black),
    ),
    Introduction(
      title: 'Data Storage',
      subTitle:
          'Rest assured, we prioritize your data privacy.\nAs part of our commitment to protecting your information.\n You can trust that your data remains secure and confidential',
      imageUrl: 'assets/images/onboarding2.png',
      titleTextStyle: TextStyle(color: Colors.black),
      subTitleTextStyle: TextStyle(color: Colors.black),
    ),
    Introduction(
      title: 'Finish',
      subTitle: 'We have completed the process, you are good to go!',
      imageUrl: 'assets/images/onboarding3.png',
      titleTextStyle: TextStyle(color: Colors.black),
      subTitleTextStyle: TextStyle(color: Colors.black),
    ),
  ];

  Widget getintro(context) {
    return IntroScreenOnboarding(
      backgroudColor: Colors.white,
      introductionList: list,
      onTapSkipButton: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => BaseScreen()),
          (Route<dynamic> route) => false,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // _OnboardingScreenState()._markOnboardingAsShown();
    return getintro(context);
  }
}
