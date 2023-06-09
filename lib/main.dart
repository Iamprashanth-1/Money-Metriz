import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'online/components/constants.dart';
import 'online/screens/login.dart';
import 'online/screens/logsign.dart';
import 'online/screens/home.dart';
import 'online/components/auth.dart';
import 'online/components/app_theme.dart';
import 'online/screens/splash.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import 'offline/screens/all_cards.dart';
import 'offline/services/all_sms.dart';
import 'dart:core';
import 'offline/screens/all_charts.dart';
import 'dart:math';
import 'package:collection/collection.dart';
import 'offline/screens/all_popup.dart';
import 'offline/screens/all_beautiful_charts.dart';
import 'package:intl/intl.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'offline/screens/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'offline/offline_home.dart';

void main() async {
  await dotenv.load();
  runApp(MoneyMetriz());

// Your project ID
}

class MoneyMetriz extends StatefulWidget {
  @override
  _MoneyMetrizState createState() => _MoneyMetrizState();
}

class _MoneyMetrizState extends State<MoneyMetriz> {
  var userselectedpage = '';
  @override
  void initState() {
    super.initState();
    checkSelectedScreen();
  }

  checkSelectedScreen() async {
    var uds = await _checkSelectedScreen();
    setState(() {
      userselectedpage = uds;
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Money Metriz',
        darkTheme: ThemeData.dark().copyWith(
          appBarTheme: AppBarTheme(backgroundColor: Colors.black),
          scaffoldBackgroundColor: bgColor,
          canvasColor: secondaryColor,
          cardColor: secondaryColor,
          dialogTheme: DialogTheme(
            backgroundColor: secondaryColor,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            contentTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          // brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          highlightColor: Colors.red,
        ),
        // theme: ThemeData(
        //     primaryColor: kPrimaryColor,
        //     scaffoldBackgroundColor: Colors.white,
        //     elevatedButtonTheme: ElevatedButtonThemeData(
        //       style: ElevatedButton.styleFrom(
        //         elevation: 0,
        //         primary: kPrimaryColor,
        //         shape: const StadiumBorder(),
        //         maximumSize: const Size(double.infinity, 56),
        //         minimumSize: const Size(double.infinity, 56),
        //       ),
        //     ),
        //     inputDecorationTheme: const InputDecorationTheme(
        //       filled: true,
        //       fillColor: kPrimaryLightColor,
        //       iconColor: kPrimaryColor,
        //       prefixIconColor: kPrimaryColor,
        //       contentPadding: EdgeInsets.symmetric(
        //           horizontal: defaultPadding, vertical: defaultPadding),
        //       border: OutlineInputBorder(
        //         borderRadius: BorderRadius.all(Radius.circular(30)),
        //         borderSide: BorderSide.none,
        //       ),
        //     )),
        // home: Auth(),
        home: getsplash(userselectedpage));
  }
}

_checkSelectedScreen() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var _getSelectedScreen = prefs.getString('user_selected_state') ?? '';
  return _getSelectedScreen;
}

Widget getsplash(String userselectedpage) {
  return AnimatedSplashScreen(
    backgroundColor: Colors.transparent,
    splashIconSize: 250,
    splash: 'assets/images/splash.png',
    animationDuration: Duration(seconds: 2),
    nextScreen: goToNextScreen(userselectedpage),
    splashTransition: SplashTransition.fadeTransition,
    pageTransitionType: PageTransitionType.fade,
  );
}

Widget goToNextScreen(screen) {
  if (screen == 'online') {
    return BaseScreen();
  } else if (screen == 'offline') {
    return OfflineApp();
  } else {
    return PageSelectScreen();
  }
}

class PageSelectScreen extends StatefulWidget {
  const PageSelectScreen({Key? key}) : super(key: key);

  @override
  _pageSelectScreenState createState() => _pageSelectScreenState();
}

class _pageSelectScreenState extends State<PageSelectScreen> {
  var _selectedScreen = 'online';
  _submitDataToSharedPrefs(String text) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_selected_state', text);
    // print('Text saved to shared preferences: $text');
  }

  _checkSelectedScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _getSelectedScreen = prefs.getString('user_selected_state') ?? '';
    setState(() {
      _selectedScreen = '';
    });
  }

  void initState() {
    super.initState();
    _checkSelectedScreen();
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedScreen == 'online') {
      return BaseScreen();
    } else if (_selectedScreen == 'offline') {
      return OfflineApp();
    } else
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Select Manual or Online',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await _submitDataToSharedPrefs('offline');
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => OfflineApp()));
                },
                child: Text('Offline Automated'),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  await _submitDataToSharedPrefs('online');
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => BaseScreen()));
                },
                child: Text('Manual Online'),
              ),
            ],
          ),
        ),
      );
  }
}

class BaseScreen extends StatefulWidget {
  const BaseScreen({Key? key}) : super(key: key);

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  bool isuserLoggedin = false;

  getuserId() async {
    var da = await AuthService().getuser();
    // var ds = await AuthService().getAuthStatus();
    // print(ds);
    setState(() {
      if (da.length > 0) {
        isuserLoggedin = true;
      }
    });
  }

  void initState() {
    super.initState();
    loaddata(getuserId);
  }

  @override
  Widget build(BuildContext context) {
    return isuserLoggedin ? HomeScreen() : LoginScreen();
  }

  Widget loaddata(trans) {
    return FutureBuilder<dynamic>(
        future: trans(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasData) {
            return Text(snapshot.data!);
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            // Show circular progress indicator until the data is loaded
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Expense Tracking',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // TRY THIS: Try running your application with "flutter run". You'll see
//         // the application has a blue toolbar. Then, without quitting the app,
//         // try changing the seedColor in the colorScheme below to Colors.green
//         // and then invoke "hot reload" (save your changes or press the "hot
//         // reload" button in a Flutter-supported IDE, or press "r" if you used
//         // the command line to start the app).
//         //
//         // Notice that the counter didn't reset back to zero; the application
//         // state is not lost during the reload. To reset the state, use hot
//         // restart instead.
//         //
//         // This works for code too, not just values: Most code changes can be
//         // tested with just a hot reload.
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: Auth(),
//       // home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.

//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // TRY THIS: Try changing the color here to a specific color (to
//         // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
//         // change color while the other colors stay the same.
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           //
//           // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
//           // action in the IDE, or press "p" in the console), to see the
//           // wireframe for each widget.
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
