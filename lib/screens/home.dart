import 'package:flutter/material.dart';
import 'package:money_metriz/screens/login.dart';
import 'package:money_metriz/screens/logsign.dart';
import '../components/auth.dart';
import '../utils.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';
import '../constants.dart';
import '../components/cards.dart';
import '../components/analytics.dart';
import '../components/app_theme.dart';
import 'profile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static String routeName = "/home";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ExpenseTrackerHomePage(),
    );
  }
}

class ExpenseTrackerHomePage extends StatefulWidget {
  @override
  _ExpenseTrackerHomePageState createState() => _ExpenseTrackerHomePageState();
}

class _ExpenseTrackerHomePageState extends State<ExpenseTrackerHomePage> {
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  List<Map<String, dynamic>> _data = [];
  List<Map<String, dynamic>> _monthlyBudget = [];
  String MonthlyBudget = '0';
  double totaltranscount = 0.0;
  double totalcreditamount = 0.0;
  double totaldebitamount = 0.0;
  double currentMonthBudgetValue = 0.1;
  int _todayTransactions = 0;
  String _username = '';
  String currentMonthBudgetDocumentId = '';
  bool _isLoading = false;
  bool _isMonlthyBudgetLoading = false;
  late DateTime _selectedFromDate;
  late DateTime _selectedToDate;

  String currentSelectedMonth = '';
  String currentSelectedYear = '';

  Map<String, dynamic> _options_months = {
    '1': false,
    '2': false,
    '3': false,
    '4': false,
    '5': false,
    '6': false,
    '7': false,
    '8': false,
    '9': false,
    '10': false,
    '11': false,
    '12': false
  };
  Map<String, dynamic> _options_years = {'2023': false};
  var checkBudgetAdded = false;
  final TextEditingController _controllerBudgetAdded = TextEditingController();

  DateTime datenow = DateTime.now();

  void initState() {
    super.initState();
    for (int i = 1; i < 13; i++) {
      if (datenow.month == i) {
        _options_months[i.toString()] = true;
      } else {
        _options_months[i.toString()] = false;
      }
    }
    for (int i = 2023; i <= datenow.year; i++) {
      if (_options_years.containsKey(i.toString())) {
        _options_years[i.toString()] = true;
      } else {
        _options_years[i.toString()] = false;
      }
    }
    checkcurrentselectmonthyear();
    checkbudgetaddedinauth();
    lasttransactions(gettotaltrans);
    // lasttransactions(getmonthlybugetid);
    AuthService().getuser();
    getusernames();
    _selectedFromDate = datenow.subtract(Duration(days: 15));
    _selectedToDate = datenow;

    // getmonthlybugetid();

    // _data = responseList.map((json) => Expense.fromJson(json)).toList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void checkbudgetaddedinauth() async {
    var kdr = await AuthService()
        .checkmonthlybudgetadded(currentSelectedMonth + currentSelectedYear);
    setState(() {
      checkBudgetAdded = kdr;
    });
  }

  void checkcurrentselectmonthyear() {
    for (var sk in _options_years.keys) {
      if (_options_years[sk] == true) {
        setState(() {
          currentSelectedYear = sk;
        });
        // currentSelectedYear = sk;
      }
    }
    for (var sk in _options_months.keys) {
      if (_options_months[sk] == true) {
        setState(() {
          currentSelectedMonth = sk;
        });
      }
    }
  }

  void _showBudgetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Budget For This Month'),
          content: TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please Add Budget';
              } else if (value.contains(RegExp(r'[a-zA-Z]'))) {
                return 'Please Add Valid Budget';
              }
            },

            controller: _controllerBudgetAdded,
            // onChanged: (value) {
            //   setState(() {
            //     MonthlyBudget = value;
            //   });
            // },
            decoration: InputDecoration(hintText: 'Enter Budget'),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Ok'),
              onPressed: () async {
                var checkadded = await AuthService().checkmonthlybudgetadded(
                    currentSelectedMonth +
                        currentSelectedYear); //check if budget already added
                if (checkadded) {
                  StatusMessagePopup(
                          message: 'Budget Already Added',
                          duration: Duration(seconds: 2))
                      .show(context);
                  Navigator.of(context).pop();
                  return;
                } else {
                  // print(currentSelectedMonth);
                  await AuthService().insertDocument(data: {
                    'monthYear': currentSelectedMonth + currentSelectedYear,
                    'budgetAmount': _controllerBudgetAdded.text,
                    'createdAt': DateTime(int.parse(currentSelectedYear),
                            int.parse(currentSelectedMonth))
                        .toString(),
                    'updatedAt': DateTime.now().toString()
                  }, collectionId: monthlyBudgetCollectionId);

                  // createErrorSnackBar('Budget Added');
                  StatusMessagePopup(
                          message: 'Budget Added',
                          duration: Duration(seconds: 2))
                      .show(context);

                  Navigator.of(context).pop();
                }
              },
            ),
            ElevatedButton(
              child: Text('Cancel'),
              onPressed: () {
                // Handle OK button press
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  gettotaltransactionCount() async {
    totaltranscount = 0.0;

    return _data.length;
    // _data = await AuthService().getDocuments();
  }

  getmonthlybudget() async {
    double currentMonthBudgetValueTemp = 0.0;
    String currentMonthBudgetDocumentIdTemp = "";
    // var da = await AuthService().getDocuments(monthlyBudgetCollectionId);
    // setState(() {
    //   currentMonthBudgetValue = 0.01;
    // });
    // print(_monthlyBudget);
    // print(_monthlyBudget);
    for (var i in _monthlyBudget) {
      // print(i['\$id']);
      DateTime dateTime = DateTime.parse(i['createdAt']);
      if (dateTime.month.toString() == currentSelectedMonth &&
          dateTime.year.toString() == currentSelectedYear) {
        // print(i['budgetAmount']);
        currentMonthBudgetValueTemp += i['budgetAmount'];
        currentMonthBudgetDocumentIdTemp = i['\$id'];
      }
    }
    setState(() {
      currentMonthBudgetValue = currentMonthBudgetValueTemp;
      currentMonthBudgetDocumentId = currentMonthBudgetDocumentIdTemp;
    });
    // print(currentMonthBudgetValue);
    // print(_monthlyBudget);
    // _data = await AuthService().getDocuments();
    return currentMonthBudgetValue;
  }

  getmonthlybugetid() async {
    setState(() {
      _isMonlthyBudgetLoading = true;
    });
    await getmonthlybudget();
    setState(() {
      _isMonlthyBudgetLoading = false;
    });
    return currentMonthBudgetDocumentId;
  }

  gettotaldebitcount() async {
    double totaldebitamountTemp = 0.0;
    for (var i in _data) {
      if (i['transactionType'] == 'DEBIT') {
        totaldebitamountTemp = totaldebitamountTemp + i['amount'];
      }
    }
    setState(() {
      totaldebitamount = totaldebitamountTemp;
      _isLoading = false;
    });

    return totaldebitamount;
    // _data = await AuthService().getDocuments();
  }

  gettodaysTransactions() async {
    var today = DateTime.now();
    var todayTransactions = 0;
    for (var i in _data) {
      DateTime dateTime = DateTime.parse(i['createdAt']);
      if (dateTime.day == today.day &&
          dateTime.month == today.month &&
          dateTime.year == today.year) {
        todayTransactions += 1;
      }
    }
    setState(() {
      _todayTransactions = todayTransactions;
    });
    return todayTransactions;
  }

  gettotalcreditamount() async {
    var totalcreditamountTemp = 0.0;
    for (var i in _data) {
      if (i['transactionType'] == 'CREDIT') {
        totalcreditamountTemp = totalcreditamountTemp + i['amount'];
      }
    }
    setState(() {
      totalcreditamount = totalcreditamountTemp;
      _isLoading = false;
    });

    return totalcreditamount;
    // _data = await AuthService().getDocuments();
  }

  gettotalsavings() async {
    return totalcreditamount + currentMonthBudgetValue - totaldebitamount;
  }

  getbalanceleft() async {
    return currentMonthBudgetValue - totaldebitamount + totalcreditamount;
  }

  getusernames() async {
    Map usern = await AuthService().getuserdata();
    setState(() {
      _username = usern['name'];
    });
  }

  gettotaltrans() async {
    setState(() {
      _isLoading = true;
    });

    var da = await AuthService().getDocuments(tranactionCollectionId,
        currentSelectedYear, currentSelectedMonth, context);
    var da1 = await AuthService().getDocuments(monthlyBudgetCollectionId,
        currentSelectedYear, currentSelectedMonth, context);
    setState(() {
      _data = da;
      _monthlyBudget = da1;
    });
    await gettotaldebitcount();
    await getmonthlybudget();

    setState(() {
      _isLoading = false;
    });
    // _data = await AuthService().getDocuments();
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    checkbudgetaddedinauth();
    gettotaldebitcount();
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: appdrawer(),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Money Metriz',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          monthYearfilterWidget(context),
          IconButton(
            icon: Icon(Icons.add_task),
            onPressed: () {
              // MonthYearPicker(onDateSelected: (p0) => '');
              // AuthService().getuserdata();

              _showBudgetDialog();
              // Handle button press
            },
          ),
        ],
      ),
      bottomNavigationBar: getbottombar(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : bottomIndexCheck(_selectedIndex),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddBudgetState();
            },
          );
          // TODO: Add expense
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget bottomIndexCheck(index_value) {
    if (index_value == 0) {
      return appBody();
    } else if (index_value == 1) {
      return BeautifulChart(
        options: '',
        selectedMonth: currentSelectedMonth,
        selectedYear: currentSelectedYear,
      );
    } else
      return UserProfilePage();
  }

  Future<void> _refreshData() async {
    // Simulate a delay of 2 seconds
    await Future.delayed(Duration(seconds: 2));
    lasttransactions(gettotaltrans);
    checkbudgetaddedinauth();

    // lasttransactions(getmonthlybugetid);
    AuthService().getuser();
    getusernames();
  }

  Widget appBody() {
    if (checkBudgetAdded == false) {
      WidgetsBinding.instance.addPostFrameCallback((_20) {
        _showBudgetDialog();
      });
    }
    return RefreshIndicator(
        onRefresh: _refreshData,
        child: SafeArea(
            child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                    image: DecorationImage(
                  filterQuality: FilterQuality.high,
                  image: AssetImage("assets/images/img_back_noise.png"),
                  fit: BoxFit.cover,
                )),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      UserView(
                        currentAccount: 'Current Account',
                        username: _username,
                      ),
                      MonthlyBudgetCard(
                        monthlybudgetSpent: totaldebitamount,
                        monthlybudgetAmount: currentMonthBudgetValue,
                        currentMonthBudgetDocumentId:
                            currentMonthBudgetDocumentId,
                      ),
                      Container(
                          height: MediaQuery.of(context).size.height / 2.2,
                          child: GridView.count(
                              crossAxisCount: 2,
                              mainAxisSpacing: 0.0,
                              crossAxisSpacing: 10.0,
                              childAspectRatio: MediaQuery.of(context)
                                      .size
                                      .width /
                                  (MediaQuery.of(context).size.height / 3.4),
                              physics: NeverScrollableScrollPhysics(),
                              children: [
                                InfoCard(
                                  title: 'Total Expense',
                                  svgSrc: Colors.red,
                                  amountOf:
                                      cardbalances('₹ ', gettotaldebitcount),
                                ),
                                InfoCard(
                                  title: 'Total Savings',
                                  svgSrc: Colors.green,
                                  amountOf: cardbalances('₹ ', gettotalsavings),
                                ),
                                InfoCard(
                                  title: 'Total Credits',
                                  svgSrc: Colors.blue,
                                  amountOf:
                                      cardbalances('₹ ', gettotalcreditamount),
                                ),
                                InfoCard(
                                  title: 'Total Balance Left',
                                  svgSrc: Colors.yellow,
                                  amountOf: cardbalances('₹ ', getbalanceleft),
                                ),
                                InfoCard(
                                  title: "Today's Transactions",
                                  svgSrc:
                                      const Color.fromARGB(255, 54, 244, 235),
                                  amountOf:
                                      cardbalances(' ', gettodaysTransactions),
                                ),
                                InfoCard(
                                  title: 'Total Transactions',
                                  svgSrc: Colors.orange,
                                  amountOf: cardbalances(
                                      ' ', gettotaltransactionCount),
                                ),
                              ])),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      lastTransdata(),
                      SizedBox(
                        height: 80,
                      ),
                    ],
                  ),
                ))));
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
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      // selectedItemColor: Colors.blue,
    );
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
            ]),
            accountEmail: Text(''),
            // currentAccountPicture: CircleAvatar(
            //   backgroundColor: Colors.transparent,
            //   backgroundImage: ExactAssetImage('assets/images/img_user_3.png'),
            // ),
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
          SizedBox(height: MediaQuery.of(context).size.height / 2),
          ElevatedButton(
              onPressed: () {
                AuthService().logout();
                AuthService().removeuserSession();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              },
              child: Text('Logout')),

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

  Widget monthYearfilterWidget(context) {
    return IconButton(
      icon: Icon(Icons.filter_alt),
      onPressed: () async {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                surfaceTintColor: bgColor,
                shadowColor: bgColor,
                title: Text('Please Select Month',
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
                      child: ListView.builder(
                        itemCount: _options_months.length,
                        itemBuilder: (BuildContext context, int index) {
                          String key = _options_months.keys.elementAt(index);
                          return CheckboxListTile(
                            title: Text("${monthMap[key]}"),
                            onChanged: (bool? value) {
                              setState(() {
                                _options_months = Map.fromIterable(
                                    _options_months.keys,
                                    key: (k) => k,
                                    value: (_) => false);
                                _options_months[key] = value!;
                              });
                            },
                            value: _options_months[key],
                          );
                        },
                      ),
                    ),
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
                        child: ListView.builder(
                          itemCount: _options_years.length,
                          itemBuilder: (BuildContext context, int index) {
                            String key = _options_years.keys.elementAt(index);
                            return CheckboxListTile(
                              title: Text("$key"),
                              onChanged: (bool? value) {
                                setState(() {
                                  _options_years = Map.fromIterable(
                                      _options_years.keys,
                                      key: (k) => k,
                                      value: (_) => false);
                                  _options_years[key] = value!;
                                });
                              },
                              value: _options_years[key],
                            );
                          },
                        ))
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
                      checkcurrentselectmonthyear();
                      checkbudgetaddedinauth();
                      lasttransactions(gettotaltrans);
                      // getLastTimestamp();
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

  loaddata() async {
    FutureBuilder<dynamic>(
      future: await AuthService().getDocuments(tranactionCollectionId,
          currentSelectedYear, currentSelectedMonth, context),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // If the future has resolved and returned data, display it
          final data = snapshot.data!;
          setState(() {
            _data = data;
            // print(_data);
          });
          // Build your widget tree with the returned data
          return Text('Hr');
        } else if (snapshot.hasError) {
          // If the future has resolved with an error, display an error message
          return Text('Error loading data: ${snapshot.error}');
        } else {
          // If the future is still resolving, display a loading indicator
          return CircularProgressIndicator();
        }
      },
    );
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
        columnSpacing: 36,
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
              label: Text('Category Type',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ))),
          DataColumn(
              label: Text('Category',
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
              label: Text('Amount',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ))),
          DataColumn(
              label: Text('Description',
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
              // // await _showDatePicker(true, 'Select From Date');
              // // await _showDatePicker(false, 'Select To Date');

              // await _loadData();
            },
          ),
        ],
      )
    ]);
  }
}

class AddBudgetState extends StatefulWidget {
  @override
  _MyDialogState createState() => _MyDialogState();
}

class _MyDialogState extends State<AddBudgetState> {
  // Define variables to store dropdown and input field values
  late String credit_debit = 'DEBIT';
  late String amount = '0';
  late String category = 'Groceries';
  late var category_list = category_icon_list_map.keys.toList();
  late String description;
  late var datetime = DateTime.now();
  final _addBudgetFormKey = GlobalKey<FormState>();
  final _currentTransactiondateController = TextEditingController();

  void initState() {
    super.initState();
    _currentTransactiondateController.text =
        DateFormat('MM/dd/yyyy HH:mm:ss').format(datetime);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed
    _currentTransactiondateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Budget Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<String>(
            value: credit_debit,
            onChanged: (value) {
              setState(() {
                credit_debit = value!;
              });
            },
            items: [
              DropdownMenuItem(
                value: 'DEBIT',
                child: Text('DEBIT'),
              ),
              DropdownMenuItem(
                value: 'CREDIT',
                child: Text('CREDIT'),
              ),
            ],
          ),
          DropdownButton<String>(
            value: category,
            onChanged: (value) {
              setState(() {
                category = value!;
              });
            },
            items: [
              for (int i = 0; i < category_list.length; i++)
                DropdownMenuItem(
                  value: category_list[i],
                  child: Text(category_list[i]),
                ),
            ],
          ),
          Form(
            key: _addBudgetFormKey,
            child: Column(children: [
              TextField(
                  readOnly: true,
                  controller: _currentTransactiondateController,
                  decoration: const InputDecoration(hintText: 'Pick your Date'),
                  onTap: () async {
                    var transactionDateTime =
                        await showDateTimePicker(context: context);
                    if (transactionDateTime != null) {
                      _currentTransactiondateController.text =
                          DateFormat('MM/dd/yyyy HH:mm:ss')
                              .format(transactionDateTime);
                    } else {
                      _currentTransactiondateController.text =
                          DateFormat('MM/dd/yyyy HH:mm:ss').format(datetime);
                    }
                  }),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Add Amount';
                  } else if (value.contains(RegExp(r'[a-zA-Z]'))) {
                    return 'Please Add Valid Amount';
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Amount',
                ),
                onChanged: (value) {
                  amount = value;
                },
              ),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Add Description';
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Description',
                ),
                onChanged: (String value) {
                  description = value;
                },
              ),
            ]),
          )
        ],
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('OK'),
          onPressed: () async {
            // var sm = await AuthService()
            //     .login(email: 'abcd@gmail.com', password: '12345678');
            // print(sm);
            if (_addBudgetFormKey.currentState!.validate()) {
              await AuthService().insertDocument(data: {
                "transactionType": credit_debit,
                "amount": int.parse(amount),
                "category": category.toString(),
                "description": description.toString(),
                "createdAt": _currentTransactiondateController.text.toString(),
                "updatedAt": datetime.toString(),
              }, collectionId: tranactionCollectionId);
              // Do something with the dropdown and input field values
              createErrorSnackBar('Expense Added');
              StatusMessagePopup(
                      message: 'Expense Added', duration: Duration(seconds: 2))
                  .show(context);

              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  Future<DateTime?> showDateTimePicker({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    initialDate ??= DateTime.now();
    firstDate ??= initialDate.subtract(const Duration(days: 365 * 100));
    lastDate ??= DateTime.now();

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (selectedDate == null) return null;

    if (!context.mounted) return selectedDate;

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDate),
    );

    return selectedTime == null
        ? selectedDate
        : DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
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
    if (data['transactionType'] == 'DEBIT') {
      amount += '\u{207B} ₹';
      amount += data['amount'].toString();
    } else {
      amount += '\u{002B} ₹';
      amount += data['amount'].toString();
      amount_color = Colors.green;
    }

    return DataRow(cells: [
      // DataCell(RichText(
      //     text: TextSpan(
      //   text: data['category'].toString(),
      //   children: [
      //     WidgetSpan(
      //       child: Padding(
      //         padding: EdgeInsets.symmetric(horizontal: 4),
      //         child: category_icon_list_map[data['category'].toString()],
      //       ),
      //     )
      //   ],
      // ))),
      DataCell(category_icon_list_map[data['category'].toString()]),
      DataCell(Text("${data['category'].toString()}")),
      DataCell(Text(DateFormat('MMM d, y h:mm:ss a')
          .format(DateTime.parse(data['createdAt'])))),
      DataCell(Text(
        "$amount",
        selectionColor: amount_color,
      )),
      DataCell(Text("${data['description'].toString()}")),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => dataList.length;

  @override
  int get selectedRowCount => 0;
}
