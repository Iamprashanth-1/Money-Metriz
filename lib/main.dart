import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'constants.dart';
import 'screens/login.dart';
import 'screens/logsign.dart';
import 'screens/home.dart';
import 'components/auth.dart';
import '/components/app_theme.dart';
import 'screens/splash.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  runApp(MyApps());

// Your project ID
}

class MyApps extends StatelessWidget {
  const MyApps({Key? key}) : super(key: key);

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
        home: getsplash());
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
