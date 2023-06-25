import 'package:flutter/material.dart';
import 'package:intro_screen_onboarding_flutter/intro_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../offline_home.dart';

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
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isShown = prefs.getBool('onboardingShown') ?? false;
    setState(() {
      _isOnboardingShown = isShown;
    });
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
    return _isOnboardingShown ? MyHomePage() : OnboardingScreen();
  }
}

class OnboardingScreen extends StatelessWidget {
  void _submitDataToSharedPrefs(String text) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_text', text);
    // print('Text saved to shared preferences: $text');
  }

  final TextEditingController _textEditingController = TextEditingController();

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
          'Rest assured, we prioritize your data privacy.\nAs part of our commitment to protecting your information, we do not store any of your data in any cloud storage.\n You can trust that your data remains secure and confidential',
      imageUrl: 'assets/images/onboarding2.png',
      titleTextStyle: TextStyle(color: Colors.black),
      subTitleTextStyle: TextStyle(color: Colors.black),
    ),
    Introduction(
      title: 'Finish',
      subTitle:
          'We have completed the process, and as a final step, we kindly request your permission to access your SMS messages in order to proceed.',
      imageUrl: 'assets/images/onboarding3.png',
      titleTextStyle: TextStyle(color: Colors.black),
      subTitleTextStyle: TextStyle(color: Colors.black),
    ),
  ];
  Widget gettextwidget(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                padding: const EdgeInsets.all(32.0),
                child: TextField(
                  controller: _textEditingController,
                  decoration: InputDecoration(
                    labelText: 'Enter Your Name',
                  ),
                )),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                String text = _textEditingController.text;
                if (text.isNotEmpty) {
                  _submitDataToSharedPrefs(text);
                  {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => getintro(context),
                      ), //MaterialPageRoute
                    );
                  }
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Please enter text in the text field.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget getintro(context) {
    return IntroScreenOnboarding(
      backgroudColor: Colors.white,
      introductionList: list,
      onTapSkipButton: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
          (Route<dynamic> route) => false,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _OnboardingScreenState()._markOnboardingAsShown();
    return gettextwidget(context);
  }
}
