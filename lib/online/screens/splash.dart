import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'onboarding.dart';
import '../../main.dart';

Widget getsplash() {
  return AnimatedSplashScreen(
    backgroundColor: Colors.transparent,
    splashIconSize: 250,
    splash: 'assets/images/splash.png',
    animationDuration: Duration(seconds: 2),
    nextScreen: PageSelectScreen(),
    splashTransition: SplashTransition.fadeTransition,
    pageTransitionType: PageTransitionType.fade,
  );
}
