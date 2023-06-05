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
  String _username = '';
  String currentMonthBudgetDocumentId = '';
  bool _isLoading = false;
  bool _isMonlthyBudgetLoading = false;

  String currentSelectedMonth = '';
  String currentSelectedYear = '';

  Map<String, dynamic> _options = {
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

  DateTime datenow = DateTime.now();

  void initState() {
    super.initState();
    for (int i = 1; i < 13; i++) {
      if (datenow.month == i) {
        _options[i.toString()] = true;
      } else {
        _options[i.toString()] = false;
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
    lasttransactions(gettotaltrans);
    // lasttransactions(getmonthlybugetid);
    AuthService().getuser();
    getusernames();

    // getmonthlybugetid();

    // _data = responseList.map((json) => Expense.fromJson(json)).toList();
  }

  @override
  void dispose() {
    super.dispose();
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
    for (var sk in _options.keys) {
      if (_options[sk] == true) {
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
          content: TextField(
            onChanged: (value) {
              setState(() {
                MonthlyBudget = value;
              });
            },
            decoration: InputDecoration(hintText: 'Enter text here'),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Ok'),
              onPressed: () async {
                var checkadded = await AuthService().checkmonthlybudgetadded(
                    DateTime.now().month.toString() +
                        DateTime.now().year.toString());
                if (checkadded) {
                  StatusMessagePopup(
                          message: 'Budget Already Added',
                          duration: Duration(seconds: 2))
                      .show(context);
                  Navigator.of(context).pop();
                  return;
                } else {
                  await AuthService().insertDocument(data: {
                    'monthYear': DateTime.now().month.toString() +
                        DateTime.now().year.toString(),
                    'budgetAmount': MonthlyBudget,
                    'createdAt': DateTime.now().toString(),
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
      if (dateTime.month == DateTime.now().month &&
          dateTime.year == DateTime.now().year) {
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

  gettotalcreditamount() async {
    totalcreditamount = 0.0;
    for (var i in _data) {
      if (i['transactionType'] == 'CREDIT') {
        totalcreditamount = totalcreditamount + i['amount'];
      }
    }

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

    var da = await AuthService().getDocuments(
        tranactionCollectionId, currentSelectedYear, currentSelectedMonth);
    var da1 = await AuthService().getDocuments(
        monthlyBudgetCollectionId, currentSelectedYear, currentSelectedMonth);

    setState(() {
      _data = da;
      _monthlyBudget = da1;
    });
    await getmonthlybudget();
    await gettotaldebitcount();
    setState(() {
      _isLoading = false;
    });
    // _data = await AuthService().getDocuments();
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
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
        title: Text('Money Metriz'),
        actions: [
          nmg(context),
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
              return MyDialog();
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
    // lasttransactions(getmonthlybugetid);
    AuthService().getuser();
    getusernames();
  }

  Widget appBody() {
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
                                  title: 'Month Budget',
                                  svgSrc: Colors.red,
                                  amountOf:
                                      cardbalances('₹ ', getmonthlybudget),
                                ),
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
          ElevatedButton(
              onPressed: () {
                AuthService().logout();
                AuthService().removeuserSession();
                Navigator.push(context,
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

  Widget nmg(context) {
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
                title: Text('Please Select Month and Year',
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
                        itemCount: _options.length,
                        itemBuilder: (BuildContext context, int index) {
                          String key = _options.keys.elementAt(index);
                          return CheckboxListTile(
                            title: Text("${monthMap[key]}"),
                            onChanged: (bool? value) {
                              setState(() {
                                _options[key] = value!;
                              });
                            },
                            value: _options[key],
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
      future: await AuthService().getDocuments(
          tranactionCollectionId, currentSelectedYear, currentSelectedMonth),
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
              // await _showDateRangePicker(context);
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

class MyDialog extends StatefulWidget {
  @override
  _MyDialogState createState() => _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
  // Define variables to store dropdown and input field values
  late String credit_debit = 'DEBIT';
  late String amount = '0';
  late String category = 'Groceries';
  late var category_list = category_icon_list_map.keys.toList();
  late String description;
  late var datetime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Inputs Below and Press Ok'),
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
          TextField(
            decoration: InputDecoration(
              labelText: 'Amount',
            ),
            onChanged: (value) {
              amount = value;
            },
          ),
          TextField(
            decoration: InputDecoration(
              labelText: 'Description',
            ),
            onChanged: (String value) {
              description = value;
            },
          ),
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
            await AuthService().insertDocument(data: {
              "transactionType": credit_debit,
              "amount": int.parse(amount),
              "category": category.toString(),
              "description": description.toString(),
              "createdAt": datetime.toString(),
              "updatedAt": datetime.toString(),
            }, collectionId: tranactionCollectionId);
            // Do something with the dropdown and input field values
            createErrorSnackBar('Expense Added');
            StatusMessagePopup(
                    message: 'Expense Added', duration: Duration(seconds: 2))
                .show(context);

            Navigator.of(context).pop();
          },
        ),
      ],
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
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => dataList.length;

  @override
  int get selectedRowCount => 0;
}
