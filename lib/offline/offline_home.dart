import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import 'screens/all_cards.dart';
import 'services/all_sms.dart';
import 'dart:core';
import 'screens/all_charts.dart';
import 'dart:math';
import 'package:collection/collection.dart';
import 'screens/all_popup.dart';
import 'screens/all_beautiful_charts.dart';
import 'package:intl/intl.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';
import '/online/components/app_theme.dart';
import 'screens/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

// void main() {
//   runApp(const OfflineApp());
// }

class OfflineApp extends StatelessWidget {
  const OfflineApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // queryAndStoreSMS();

    return MaterialApp(
      title: 'Money Metriz',
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bgColor,
        canvasColor: secondaryColor,
        appBarTheme: AppBarTheme(backgroundColor: Colors.black),
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
      debugShowCheckedModeBanner: false,
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
      home: OnboardingScreenStatus(),
    );
  }
}

// getdebit() async {
//   var credit = await getdata(
//       "select round(sum(debitAmount),2) as debitAmount from sms_data where transType='DEBIT'");

//   // print(credit);
//   return credit[0]['debitAmount'];
// }

// getcredit() async {
//   var credit = await getdata(
//       "select round(sum(creditAmount),2) as creditAmount from sms_data where transType='CREDIT'");

//   // print(credit);
//   return credit[0]['creditAmount'];
// }

// gettotalSavings() async {
//   var credit = await getdata(
//       "select round(sum(creditAmount) - sum(debitAmount),2) as savings from sms_data");

//   // print(credit);
//   return credit[0]['savings'];
// }

// getavailableBalance() async {
//   var credit = await getdata(
//       "select availableBalance as availablebalance from sms_data  order by transDate desc limit 1");

//   // print(credit);
//   return credit[0]['availablebalance'];
// }

// Map getbalances = {'getdebit': getdebit, 'getcredit': getcredit};

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePage createState() => _MyHomePage();
}

class _MyHomePage extends State<MyHomePage> {
  bool isLoading = true;
  String _username = '';
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Map<String, dynamic>> _data = [];
  List<dynamic> _names = [];
  String maxTimestamp = '1577836833000';
  List<String> _selectedValues = [];
  List<dynamic> _options = ['XXX'];
  String currentAccount = '';
  List<bool> _selectedOptions = [true];
  DateTime datenow = DateTime.now();
  late DateTime _selectedFromDate;
  late DateTime _selectedToDate;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  // prints the current year (e.g. 2023)

  List<dynamic> _options_years = ['2020'];
  List<bool> _selectedOptions_years = [true];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 100; i++) {
      _selectedOptions.add(false);
      _selectedOptions_years.add(false);
    }
    for (int i = 2021; i <= datenow.year; i++) {
      _options_years.add('$i');
    }
    _options_years = _options_years.reversed.toList();

    print('getting pre');
    _selectedFromDate = datenow.subtract(Duration(days: 15));
    _selectedToDate = datenow;
    getpermissions();
    // checkpermission();
    _loadDataFromSharedPrefs();
    getLastTimestamp();
    print('got pos');

    print('done popup');
  }

  _submitDataToSharedPrefs(String text) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_selected_state', text);
    // print('Text saved to shared preferences: $text');
  }

  getwherefilters() {
    if (_options.length == 0) return '';
    String lkm = ' and (';
    int grd = 0;
    for (int i = 0; i < _options_years.length; i++) {
      if (_selectedOptions_years[i]) {
        lkm += " year_col='${_options_years[i]}' ";
        lkm += " or ";
        grd = grd + 1;
      }
    }

    if (grd != 0) {
      lkm = lkm.substring(0, lkm.length - 4);
      lkm += ') and (';
    }
    int ktd = 0;

    for (int i = 0; i < _options.length; i++) {
      if (_selectedOptions[i]) {
        lkm += "  bankName='${_options[i]}' ";
        lkm += " or ";
        ktd = ktd + 1;
      }
    }
    if (ktd != 0) {
      lkm = lkm.substring(0, lkm.length - 4);

      lkm += ' ) ';
    }

    if (lkm == " and (") return '';
    return lkm;
  }

  getcredit() async {
    String sqlqu =
        "select round(sum(creditAmount),2) as creditAmount,strftime('%Y', transDate) as year_col from sms_data where transType='CREDIT'";
    sqlqu += getwherefilters();

    var credit = await getdata(sqlqu);
    try {
      var cr = credit[0]['creditAmount'];
      if (cr == null) return 0;
      return cr;
    } catch (e) {
      return 0;
    }
    // print(credit);
    return credit[0]['creditAmount'];
  }

  getdebit() async {
    String sqlu =
        "select round(sum(debitAmount),2) as debitAmount,strftime('%Y', transDate) as year_col from sms_data where transType='DEBIT'";
    sqlu += getwherefilters();
    var credit = await getdata(sqlu);

    try {
      var cr = credit[0]['debitAmount'];
      if (cr == null) return 0;
      return cr;
    } catch (e) {
      return 0;
    }
    // print(credit);
    return credit[0]['debitAmount'];
  }

  gettotaltrans() async {
    String sqlu =
        "select count(*) as tC,strftime('%Y', transDate) as year_col from sms_data where 1=1 ";
    sqlu += getwherefilters();
    var credit = await getdata(sqlu);

    try {
      var cr = credit[0]['tC'];
      if (cr == null) return 0;
      return cr;
    } catch (e) {
      return 0;
    }
    // print(credit);
    return credit[0]['debitAmount'];
  }

  getavgbalance() async {
    String sqlu =
        "select round(avg(availableBalance),2) as aB,strftime('%Y', transDate) as year_col from sms_data where 1=1 ";
    sqlu += getwherefilters();
    var credit = await getdata(sqlu);

    try {
      var cr = credit[0]['aB'];
      if (cr == null) return 0;
      return cr;
    } catch (e) {
      return 0;
    }

    // print(credit);
    return credit[0]['debitAmount'];
  }

  gettotalSavings() async {
    String sqlu =
        "select round(sum(creditAmount) - sum(debitAmount),2) as savings,strftime('%Y', transDate) as year_col from sms_data where 1=1";
    sqlu += getwherefilters();
    var credit = await getdata(sqlu);
    try {
      var cr = credit[0]['savings'];
      if (cr == null) return 0;
      return cr;
    } catch (e) {
      return 0;
    }
    // print(credit);
    return credit[0]['savings'];
  }

  getavailableBalance() async {
    String sqlu =
        "select availableBalance as availablebalance,strftime('%Y', transDate) as year_col from sms_data where 1=1 ";
    sqlu += getwherefilters();
    sqlu += " order by transDate desc limit 1";
    var credit = await getdata(sqlu);
    try {
      var cr = credit[0]['availablebalance'];
      if (cr == null || cr == 0.0) return 'NA';
      return cr;
    } catch (e) {
      return 0;
    }
    // print(credit);
    return credit[0]['availablebalance'];
  }

  Future<void> _loadDataFromSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String text = prefs.getString('user_text') ?? '';
    setState(() {
      _username = text;
    });
  }

  Future<void> getLastTimestamp() async {
    // await checkpermission();

    setState(() {
      isLoading = true;
    });

    // Retrieve the max timestamp from your SQLite database
    var storedMaxTimestamp = await _databaseHelper
        .rawquery("select max(date) as maxtimestamp from sms_max_time");
    List lastTimestamp =
        storedMaxTimestamp.map((result) => result['maxtimestamp']).toList();

    if (lastTimestamp.isNotEmpty) {
      if (lastTimestamp[0] != null) {
        String maxTimest = lastTimestamp[0];

        await queryAndStoreSMS(maxTimest);
      } else {
        await queryAndStoreSMS(maxTimestamp);
      }
    }
    await _loadallAccounts();
    await lasttransactions(_loadData);

    // Update the global variable

    setState(() {
      List currentAccount_b = [];
      for (int i = 0; i < _options.length; i++) {
        if (_selectedOptions[i]) {
          currentAccount_b.add(_options[i]);
        }
      }
      currentAccount = currentAccount_b.join(',');

      isLoading = false;
    });
  }

  checkpermission() async {
    var status = await telephony.requestSmsPermissions;
    if (status != null) {
      // We didn't ask for permission yet or the permission has been denied before but not permanently.

      // SMS permission is not granted
      // Show rationale to the user and request permission again
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("SMS Permission Required"),
            content: Text(
                "This APP requires SMS permission. Please grant the permission to continue."),
            actions: <Widget>[
              TextButton(
                child: Text("Request Permission"),
                onPressed: () async {
                  Navigator.of(context).pop();
                  // await openAppSettings();
                  // await Permission.sms.request();
                  // if (hasPermission == true) {
                  //   // SMS permission is granted after request, perform the desired action
                  // } else {
                  //   getpermissions();
                  //   // SMS permission is still not granted
                  //   // Handle accordingly
                  // }
                },
              ),
            ],
          );
        },
      );
    } else {
      return;
    }
  }

  Future<void> getpermissions() async {
    // var status = await Permission.sms.status;
    var per = await telephony.requestSmsPermissions;

    // print(status.isGranted);
    // if (!status.isGranted) {
    //   await Permission.sms.request();
    //   // await Permission.sms.request();

    //   // We didn't ask for permission yet or the permission has been denied before but not permanently.
    // } else {
    //   var status = await Permission.sms.status;
    //   if (status.isDenied) {
    //     // We didn't ask for permission yet or the permission has been denied before but not permanently.

    //     // SMS permission is not granted
    //     // Show rationale to the user and request permission again
    //     showDialog(
    //       context: context,
    //       builder: (BuildContext context) {
    //         return AlertDialog(
    //           title: Text("SMS Permission Required"),
    //           content: Text(
    //               "This APP requires SMS permission. Please grant the permission to continue."),
    //           actions: <Widget>[
    //             TextButton(
    //               child: Text("Request Permission"),
    //               onPressed: () async {
    //                 Navigator.of(context).pop();
    //                 await openAppSettings();
    //                 // await Permission.sms.request();
    //                 // if (hasPermission == true) {
    //                 //   // SMS permission is granted after request, perform the desired action
    //                 // } else {
    //                 //   getpermissions();
    //                 //   // SMS permission is still not granted
    //                 //   // Handle accordingly
    //                 // }
    //               },
    //             ),
    //           ],
    //         );
    //       },
    //     );
    //   }
    // }
  }

  Widget lasttransactions(Function trans) {
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

  Future<void> _loadData() async {
    List gg = getwherefilters().split('and');

    String allfil =
        "and ${gg[2]} and (transDate between '${_selectedFromDate.toString()}' and '${_selectedToDate.toString()}' ) ";
    List<Map<String, dynamic>> data = await _databaseHelper.queryAll(allfil);
    setState(() {
      _data = data;
    });
  }

  Future<void> _loadallAccounts() async {
    // await checkpermission();
    List<Map<String, dynamic>> results = await _databaseHelper.rawquery(
        'SELECT   bankName as accountNumber ,count(*) as tC  FROM sms_data  group by bankName  having tC > 10 order by tC desc ');
    setState(() {
      _names = results.map((result) => result['accountNumber']).toList();
      _options = _names;
    });

    if (_names.length == 0) {
      // await showDialog(
      //   context: context,
      //   builder: (BuildContext context) {
      //     return MyDialog();
      //   },
      // );
      await _loadallAccounts();
    }
  }

  String _selectedItem = 'Default ALL';

  void _onSelected(String value) {
    setState(() {
      _selectedItem = value;
    });
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // checkpermission();
    return Scaffold(
      drawer: appdrawer(),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          textAlign: TextAlign.center,
          'Money Metriz',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [nmg(context)],
      ),
      bottomNavigationBar: getbottombar(),
      body: isLoading
          ? Center(
              child: Stack(
              alignment: Alignment.center,
              children: const <Widget>[
                CircularProgressIndicator(),
                Text(
                  'Please Wait Loading Data from SMS...',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ))
          : bottomIndexCheck(_selectedIndex),
    );
  }

  Widget bottomIndexCheck(index_value) {
    return index_value == 0
        ? appBody()
        : BeautifulChart(options: getwherefilters());
  }

  Widget appBody() {
    return SafeArea(
        child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                filterQuality: FilterQuality.high,
                image: AssetImage("assets/images/img_back_noise.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (overscroll) {
                  overscroll
                      .disallowIndicator(); // disable the default overscroll glow effect
                  return false; // return false to allow the notification to propagate
                },
                child: SingleChildScrollView(
                    primary: false,
                    padding: EdgeInsets.all(defaultPadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Text('Height: ${MediaQuery.of(context).size.height}'),
                        // Text('Width: ${MediaQuery.of(context).size.width}'),

                        UserView(
                          currentAccount: currentAccount,
                          username: _username,
                        ),

                        Container(
                            height: MediaQuery.of(context).size.height / 2.3,
                            child: GridView.count(
                              crossAxisCount: 2,
                              mainAxisSpacing: 0.0,
                              crossAxisSpacing: 10.0,
                              childAspectRatio: MediaQuery.of(context)
                                      .size
                                      .width /
                                  (MediaQuery.of(context).size.height / 3.2),
                              physics: NeverScrollableScrollPhysics(),
                              children: [
                                InfoCard(
                                    title: "Total Credits",
                                    svgSrc: Colors.blue,
                                    amountOf: cardbalances('₹', getcredit)),
                                InfoCard(
                                  svgSrc: Color.fromARGB(255, 94, 146, 96),
                                  title: "Total Debits",
                                  amountOf: cardbalances('₹', getdebit),
                                ),
                                InfoCard(
                                  svgSrc: Color.fromARGB(255, 156, 72, 149),
                                  title: "Total Savings",
                                  amountOf: cardbalances('₹', gettotalSavings),
                                ),
                                InfoCard(
                                  svgSrc: Color.fromARGB(255, 172, 157, 71),
                                  title: "Last Avail Balance",
                                  amountOf:
                                      cardbalances('₹', getavailableBalance),
                                ),
                                InfoCard(
                                  svgSrc: Color.fromARGB(255, 163, 74, 74),
                                  title: "Total Transactions",
                                  amountOf: cardbalances('', gettotaltrans),
                                ),
                                InfoCard(
                                  svgSrc: Color.fromARGB(255, 200, 119, 216),
                                  title: "Total Avg Balance",
                                  amountOf: cardbalances('₹', getavgbalance),
                                ),
                              ],
                            )),
                        // Row(
                        //     crossAxisAlignment: CrossAxisAlignment.center,
                        //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                        //     children: [
                        //       InfoCard(
                        //           title: "Total Credits",
                        //           svgSrc: "assets/icons/Documents.svg",
                        //           amountOf: cardbalances('₹', getcredit)),
                        //       InfoCard(
                        //         svgSrc: "assets/icons/Documents.svg",
                        //         title: "Total Debits",
                        //         amountOf: cardbalances('₹', getdebit),
                        //       ),
                        //     ]),
                        // Row(
                        //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                        //     crossAxisAlignment: CrossAxisAlignment.center,
                        //     children: [
                        //       InfoCard(
                        //         svgSrc: "assets/icons/media.svg",
                        //         title: "Total Savings",
                        //         amountOf: cardbalances('₹', gettotalSavings),
                        //       ),
                        //       InfoCard(
                        //         svgSrc: "assets/icons/folder.svg",
                        //         title: "Last Avail Balance",
                        //         amountOf: cardbalances('₹', getavailableBalance),
                        //       ),
                        //     ]),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                        //   crossAxisAlignment: CrossAxisAlignment.center,
                        //   children: [
                        //     InfoCard(
                        //       svgSrc: "assets/icons/media.svg",
                        //       title: "Total Transactions",
                        //       amountOf: cardbalances('', gettotaltrans),
                        //     ),
                        //     InfoCard(
                        //       svgSrc: "assets/icons/folder.svg",
                        //       title: "Total Avg Balance",
                        //       amountOf: cardbalances('₹', getavgbalance),
                        //     ),
                        //   ],
                        // ),

                        SizedBox(height: 2),
                        lastTransdata()
                        // Container(
                        //     width: double.infinity,
                        //     padding: EdgeInsets.all(defaultPadding),
                        //     decoration: BoxDecoration(
                        //         color: secondaryColor,
                        //         borderRadius:
                        //             const BorderRadius.all(Radius.circular(10))),
                        //     child: ),
                        // lineChart(),
                        // Text('Your DEBIT/CREBIT Analysis'),
                        // multiLineChart(context)
                      ],
                    )))));
  }

  Widget getbottombar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Transactions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'Analytics',
        ),
      ],
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedItemColor: Colors.blue,
    );
  }

  Widget nmg(context) {
    return IconButton(
      icon: Icon(Icons.filter_alt),
      onPressed: () async {
        _loadallAccounts();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                surfaceTintColor: bgColor,
                shadowColor: bgColor,
                title: Text('Please Select Your Accounts',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        height: MediaQuery.of(context).size.height / 5,
                        width: 200,
                        decoration: BoxDecoration(
                          border: Border.all(
                              width: 2, color: primaryColor.withOpacity(0.15)),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(defaultPadding),
                          ),
                        ),
                        child: ListView(
                            children: _options.map((option) {
                          int index = _options.indexOf(option);
                          return CheckboxListTile(
                            title: Text("XX$option"),
                            onChanged: (bool? value) {
                              setState(() {
                                _selectedOptions[index] = value!;
                              });
                            },
                            value: _selectedOptions[index],
                          );
                        }).toList())),
                    SizedBox(height: 10),
                    Text(
                      'Please Choose Year ',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Container(
                        height: MediaQuery.of(context).size.height / 6,
                        decoration: BoxDecoration(
                          border: Border.all(
                              width: 2, color: primaryColor.withOpacity(0.15)),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(defaultPadding),
                          ),
                        ),
                        width: 200,
                        child: ListView(
                            children: _options_years.map((option) {
                          int index = _options_years.indexOf(option);
                          return CheckboxListTile(
                            title: Text("$option"),
                            onChanged: (bool? value) {
                              setState(() {
                                _selectedOptions_years[index] = value!;
                              });
                            },
                            value: _selectedOptions_years[index],
                          );
                        }).toList()))
                  ],
                ),
                actions: [
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  TextButton(
                    child: Text('Apply'),
                    onPressed: () {
                      getLastTimestamp();
                      // Perform filtering logic
                      // You can access selected options via _selectedOptions list
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            });
          },
        );
      },
    );
  }

  void _sort<T>(Comparable<T> getField(Map<String, dynamic> data),
      int columnIndex, bool ascending) {
    _data.sort((a, b) {
      if (!ascending) {
        final c = a;
        a = b;
        b = c;
      }
      final aValue = getField(a);
      final bValue = getField(b);
      return Comparable.compare(aValue, bValue);
    });
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  _showDateRangePicker(BuildContext context) async {
    final initialDateRange = DateTimeRange(
      start: _selectedFromDate,
      end: _selectedToDate,
    );

    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedFromDate = picked.start;
        _selectedToDate = picked.end;
      });
    }
  }

  _showDatePicker(bool isFromDate, String lables) async {
    final DateTime currentDate = DateTime.now();
    DateTime initialDate = isFromDate ? _selectedFromDate : _selectedToDate;
    if (!isFromDate) {
      initialDate = currentDate;
    }

    final DateTime? pickedDate = await showDatePicker(
      helpText: lables,
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDate: initialDate,
      firstDate: DateTime(currentDate.year - 10),
      lastDate: DateTime(currentDate.year + 10),
    );

    if (pickedDate != null) {
      setState(() {
        if (isFromDate) {
          _selectedFromDate = pickedDate;
          // print(_selectedFromDate);
          // _loadData();
          // Edited by me
        } else {
          _selectedToDate = pickedDate;
          // _loadData();
          /// Further edited by me
        }
      });
    }
  }

  Widget appdrawer() {
    return Drawer(
        child: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          filterQuality: FilterQuality.high,
          image: AssetImage("assets/images/img_back_noise.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName:
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Flexible(
                  child: Text(
                'Hello, $_username\u{1F60E}',
                maxLines: 1,
                style: TextStyle(
                    color: ThemeData.estimateBrightnessForColor(
                                Theme.of(context).colorScheme.background) ==
                            Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.normal),
              )),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    onPressed: () async {
                      await updateUserName(_username);
                    },
                    icon: Icon(Icons.edit),
                  )),
            ]),
            accountEmail: Text(''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.transparent,
              backgroundImage: ExactAssetImage('assets/images/img_user_3.png'),
            ),
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/img_back_noise.png"),
                    fit: BoxFit.cover)),
          ),
          // DrawerHeader(
          //   child: BackgroundWidget(
          //       child:
          //           Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          //     Flexible(
          //         child: Text(
          //       'Hello, $_username\u{1F60E}',
          //       maxLines: 1,
          //       style: TextStyle(
          //           overflow: TextOverflow.ellipsis,
          //           fontWeight: FontWeight.bold,
          //           fontStyle: FontStyle.italic),
          //     )),
          //     Padding(
          //         padding: const EdgeInsets.all(8.0),
          //         child: IconButton(
          //           onPressed: () async {
          //             await updateUserName(_username);
          //           },
          //           icon: Icon(Icons.edit),
          //         )),
          //   ])),
          //   // decoration: BoxDecoration(
          //   //   borderRadius: BorderRadius.circular(16.0),
          //   // ),
          // ),

          SizedBox(
            child: Text('   Your Accounts ',
                // textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.normal)),
          ),
          Container(
              height: MediaQuery.of(context).size.height / 2,
              child: ListView.builder(
                itemCount: _options.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(' Account $index :      XX${_options[index]}',
                        // textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        )),
                  );
                },
              )),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Swith to Online Mode'),
            onTap: () async {
              await _submitDataToSharedPrefs('online');
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => BaseScreen()));
            },
          ),
          const Divider(),
          Column(children: [
            SizedBox(height: 20),
            Text('!! Thanks for Using Our App !!',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold)),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 40.0, top: 10.0),
                child: Image.asset(
                  "assets/images/img_rocket_person.png",
                  fit: BoxFit.cover,
                  height: 190,
                ),
              ),
            ),
            Text('!! Made with \u{1F496} by Prashanth Reddy !!',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
          ])
        ],
      ),
    ));
  }

  Future<void> updateUserName(userName) async {
    String updatedUsername = await showDialog(
          context: context,
          builder: (BuildContext context) {
            String newUsername = ''; // Variable to hold the updated username
            return AlertDialog(
              title: Text('Edit Username'),
              content: TextField(
                controller: TextEditingController(text: userName),
                onChanged: (value) {
                  newUsername =
                      value; // Update the new username as the user types
                },
                decoration: InputDecoration(
                  labelText: 'Username',
                ),
              ),
              actions: [
                ElevatedButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context,
                        null); // Close the dialog without updating the username
                  },
                ),
                ElevatedButton(
                  child: Text('Save'),
                  onPressed: () {
                    Navigator.pop(context,
                        newUsername); // Close the dialog and pass the new username
                  },
                ),
              ],
            );
          },
        ) ??
        ''; // Use empty string as default return value if showDialog() returns null

    if (updatedUsername != null && updatedUsername.isNotEmpty) {
      // If a new username is provided, update the username in shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_text', updatedUsername);

      // Call setState() to rebuild the widget with the new username
      setState(() {
        _username = updatedUsername;
      });
    }
  }

  Widget lastTransdata() {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      SizedBox(
        height: 5,
      ),
      PaginatedDataTable(
        header: Text(
          'Your Transactions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        rowsPerPage: _rowsPerPage,
        onRowsPerPageChanged: (value) {
          setState(() {
            _rowsPerPage = value!;
          });
        },
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,

        // headingRowColor:
        //     MaterialStateColor.resolveWith((states) => Colors.grey),
        // showBottomBorder: true,
        // headingTextStyle: const TextStyle(
        //   fontWeight: FontWeight.bold,
        // ),
        columns: const [
          DataColumn(
              label: Text('Bank Name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ))),
          DataColumn(
            label: Text('Transaction Date',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                )),
          ),
          DataColumn(
              label: Text('Account Number',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ))),
          DataColumn(
              label: Text('Transaction Type',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ))),
          DataColumn(
              label: Text('Amount',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ))),
          DataColumn(
              label: Text('Available Balance',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ))),
        ],
        source: TranstableRow(dataList: _data),
        actions: [
          // Text(
          //   'From Date : ${_selectedFromDate} \nTo Date       :${_selectedToDate}',
          //   style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          // ),
          IconButton(
            icon: Icon(Icons.date_range, color: Colors.orangeAccent),
            onPressed: () async {
              // datepicker();
              await _showDateRangePicker(context);
              // await _showDatePicker(true, 'Select From Date');
              // await _showDatePicker(false, 'Select To Date');

              await _loadData();
            },
          ),
        ],
      )
    ]);
  }

  Widget cardview(context, String name, Function getbalances) {
    return Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(30.0),
          ),
        ),
        child: Container(
            width: MediaQuery.of(context).size.width / 3,
            height: MediaQuery.of(context).size.height / 8,
            padding: EdgeInsets.all(defaultPadding),
            decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: const BorderRadius.all(Radius.circular(10))),
            child: Stack(
              children: [
                Positioned(
                    bottom: 10,
                    right: 10,
                    left: 5,
                    top: 15,
                    child: cardbalances(name, getbalances))
              ],
            )));
  }

  Widget cardbalances(name, Function getbalance) {
    return FutureBuilder(
      future: getbalance(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('${name} Error: ${snapshot.error}',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold, height: 1));
        } else {
          return Text('${name} ${snapshot.data.toString()}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ));
        }
      },
    );
  }
}

class TranstableRow extends DataTableSource {
  final List<Map<String, dynamic>> dataList;

  TranstableRow({
    Key? key,
    required this.dataList,
  });

  @override
  DataRow? getRow(int index) {
    // if (index >= dataList.length) return null;

    final data = dataList[index];
    String amount = '';
    Color amount_color = Colors.red;
    if (data['transType'] == 'DEBIT') {
      amount += '\u{207B} ';
      amount += data['debitAmount'].toString();
    } else {
      amount += '\u{002B} ';
      amount += data['creditAmount'].toString();
      amount_color = Colors.green;
    }
    String availbal = '';
    if (data['availableBalance'] != 0.0) {
      availbal = data['availableBalance'].toString();
    } else {
      availbal = 'NA';
    }
    return DataRow(cells: [
      DataCell(Text(data['bankName'].toString())),
      DataCell(Text(DateFormat('MMM d, y h:mm:ss a')
          .format(DateTime.parse(data['transDate'])))),
      DataCell(Text("XX${data['accountNumber']}".toString())),
      DataCell(Text(data['transType'].toString())),
      DataCell(Text(
        "$amount",
        selectionColor: amount_color,
      )),
      DataCell(Text("$availbal")),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => dataList.length;

  @override
  int get selectedRowCount => 0;
}
