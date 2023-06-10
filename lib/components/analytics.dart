import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'app_theme.dart';

import 'auth.dart';
import '../constants.dart';
import 'dart:math';
import '../utils.dart';

Future<List<ChartData>> getmonthtrend(_data) async {
  final List<ChartData> data1 = [];
  var tempcd = {'CREDIT': 0, 'DEBIT': 0, 'tC': 0};
  var tempmap = {};

  int count = 1;
  for (Map<String, dynamic> map in _data) {
    var datestrip = DateTime.parse(map['createdAt']);
    String monthString = monthMap[datestrip.month.toString()];
    if (tempmap.containsKey(monthString)) {
      if (map['transactionType'] == 'CREDIT') {
        tempmap[monthString]['CREDIT'] =
            tempmap[monthString]['CREDIT'] + map['amount'];
      } else {
        tempmap[monthString]['DEBIT'] =
            tempmap[monthString]['DEBIT'] + map['amount'];
      }
      tempmap[monthString]['tC'] = tempmap[monthString]['tC'] + 1;
    } else {
      tempmap[monthString] = tempcd;
    }

    // Parse the month and year from the monthString
    // int month = int.parse(monthString.split('-')[0]);
    // int year = int.parse(monthString.split('-')[1]);

    // data1.add(ChartData(count, monthString, value1, value2, value3));
  }
  // print(tempmap);
  for (var mk in tempmap.keys) {
    data1.add(ChartData(count, mk, tempmap[mk]['CREDIT'], tempmap[mk]['DEBIT'],
        tempmap[mk]['tC']));
  }
  return data1;
}

// Future<List<ChartDatatC>> gettotaltrans(whereFilters) async {
//   // final DatabaseHelper _databaseHelp = DatabaseHelper();

//   final List<ChartDatatC> data1 = [];
//   String sqlqu =
//       "SELECT strftime('%m', transDate) as month,strftime('%Y', transDate) as year_col,strftime('%d', transDate) as day_col  ,count(*) as tC FROM sms_data where 1=1 $whereFilters  GROUP BY month,day_col";

//   // List<Map<String, dynamic>> monthtrend = await _databaseHelp.rawquery(sqlqu);

//   int count = 1;
//   for (Map<String, dynamic> map in monthtrend) {
//     int month = int.parse(map['month']);
//     int year = int.parse(map['year_col']);
//     int day = int.parse(map['day_col']);
//     int value3 = map['tC'];
//     DateTime dt = DateTime(year, month, day);

//     // Parse the month and year from the monthString
//     // int month = int.parse(monthString.split('-')[0]);
//     // int year = int.parse(monthString.split('-')[1]);

//     data1.add(ChartDatatC(count, dt, value3));
//   }
//   return data1;
// }

// getChartDatamoney(whereFilters) async {
//   final DatabaseHelper _databaseHelp = DatabaseHelper();

//   final List<ChartDatamoney> data_c = [];
//   final List<ChartDatamoney> data_d = [];
//   int tCK = 0;
//   double sdj_d = 0;
//   double sdj_c = 0;
//   String modifiedWhereFilters = 'and ';
//   List modifiedWhereFiltersList = whereFilters.split('and');
//   String yearcol =
//       modifiedWhereFiltersList[1].split('=')[1].replaceAll(")", '');
//   modifiedWhereFilters += modifiedWhereFiltersList[2];
//   modifiedWhereFilters += " and ( strftime('%Y', transDate) =$yearcol ) ";
//   String sqlqul =
//       '''SELECT strftime('%Y', transDate) as year_col,(select count(*)  from sms_data where debitAmount between 1 and 100  $modifiedWhereFilters  ) as low_d ,
//       (select count(*) from sms_data where debitAmount between 100 and 1000  $modifiedWhereFilters ) as Average_D ,
//       (select count(*) from sms_data where debitAmount >1000  $modifiedWhereFilters ) as High_D ,
//       (select count(*) from sms_data where creditAmount between 1 and 100  $modifiedWhereFilters  ) as Low_C ,
//       (select count(*) from sms_data where creditAmount between 100 and 1000  $modifiedWhereFilters ) as Average_C ,
//       (select count(*) from sms_data where creditAmount >1000  $modifiedWhereFilters ) as High_C ,
//       count(*) as tC FROM sms_data where 1=1 $modifiedWhereFilters  ''';

//   List<Map<dynamic, dynamic>> distibtrend =
//       await _databaseHelp.rawquery(sqlqul);
//   for (Map<dynamic, dynamic> maps in distibtrend) {
//     double low_d = double.parse(maps['low_d'].toString());
//     double avg_d = double.parse(maps['Average_D'].toString());
//     double high_d = double.parse(maps['High_D'].toString());
//     double low_c = double.parse(maps['Low_C'].toString());
//     double avg_c = double.parse(maps['Average_C'].toString());
//     double high_c = double.parse(maps['High_C'].toString());

//     sdj_d = low_d + high_d + avg_d;
//     sdj_c = low_c + high_c + avg_c;

//     data_d.add(
//         ChartDatamoney('LOW', low_d, '1-100', Color.fromRGBO(235, 97, 143, 1)));
//     data_d.add(ChartDatamoney(
//         'Average', avg_d, '100-1000', const Color.fromRGBO(145, 132, 202, 1)));
//     data_d.add(ChartDatamoney(
//         'High', high_d, '>1000', const Color.fromRGBO(69, 187, 161, 1)));
//     data_c.add(ChartDatamoney(
//         'LOW', low_c, '1-100', const Color.fromRGBO(235, 97, 143, 1)));
//     data_c.add(ChartDatamoney(
//         'Average', avg_c, '100-1000', const Color.fromRGBO(145, 132, 202, 1)));
//     data_c.add(ChartDatamoney(
//         'High', high_c, '>1000', const Color.fromRGBO(69, 187, 161, 1)));
//   }
//   return [data_d, data_c, sdj_d, sdj_c];
// }

class BeautifulChart extends StatefulWidget {
  final String options;
  final selectedYear;
  final selectedMonth;

  const BeautifulChart(
      {Key? key,
      required this.options,
      required this.selectedYear,
      required this.selectedMonth})
      : super(key: key);
  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<BeautifulChart> {
  List<ChartData> chartData = [];
  List<ChartDatatC> chartDatatC = [];
  List<ChartDatamoney> ChartDatamoneiD = [];
  List<ChartCategoryDataByMonth> chartCategoryData = [];
  double tCC_C = 0;
  double tCC_D = 0;
  List<ChartDatamoney> ChartDatamoneiC = [];
  List<Map<String, dynamic>> _data = [];
  List<Map<String, dynamic>> _dataOfCurrentYear = [];
  late TooltipBehavior _tooltipBehavior;
  late LabelIntersectAction _labelIntersectAction;

  // final List<ChartData> data = [
  //   ChartData(1, 'Jan', 20, 10),
  //   ChartData(2, 'Feb', 30, 15),
  //   ChartData(3, 'Mar', 25, 12),
  //   ChartData(4, 'Apr', 20, 10),
  //   ChartData(5, 'May', 35, 20),
  //   ChartData(6, 'Jun', 30, 15),
  // ];

  getYearlydataofUser() async {
    var dataofYear = await AuthService().getDocumentsForCurrentYear(
        tranactionCollectionId, widget.selectedYear, context);

    setState(() {
      _dataOfCurrentYear = dataofYear;
    });

    final List<ChartData> credit_debit_tc = [];
    final List<ChartDatatC> totalTranscations = [];

    Map<String, dynamic> tempmap_credit_debit_tc = {};
    var totaltransactionsdailycount = {};
    int count = 1;

    for (Map<String, dynamic> mapdata in _dataOfCurrentYear) {
      var tempcd = {'CREDIT': 0, 'DEBIT': 0, 'tC': 0};
      var datestrip = DateTime.parse(mapdata['createdAt'].toString());
      var currentdate = datestrip.toString().split(' ')[0];

      if (totaltransactionsdailycount.containsKey(currentdate)) {
        totaltransactionsdailycount[currentdate] =
            totaltransactionsdailycount[currentdate] + 1;
      } else {
        totaltransactionsdailycount[currentdate] = 1;
      }

      String monthStringInCreated = monthMap[datestrip.month.toString()];

      if (!tempmap_credit_debit_tc.containsKey(monthStringInCreated)) {
        tempmap_credit_debit_tc[monthStringInCreated] = tempcd;
      }

      if (mapdata['transactionType'] == 'CREDIT') {
        tempmap_credit_debit_tc[monthStringInCreated]['CREDIT'] =
            tempmap_credit_debit_tc[monthStringInCreated]['CREDIT'] +
                mapdata['amount'];
      } else {
        tempmap_credit_debit_tc[monthStringInCreated]['DEBIT'] =
            tempmap_credit_debit_tc[monthStringInCreated]['DEBIT'] +
                mapdata['amount'];
      }
      tempmap_credit_debit_tc[monthStringInCreated]['tC'] =
          tempmap_credit_debit_tc[monthStringInCreated]['tC'] + 1;
    }

    for (var mk in tempmap_credit_debit_tc.keys) {
      credit_debit_tc.add(ChartData(
          count,
          mk.toString(),
          double.parse(tempmap_credit_debit_tc[mk]['CREDIT'].toString()),
          double.parse(tempmap_credit_debit_tc[mk]['DEBIT'].toString()),
          tempmap_credit_debit_tc[mk]['tC']));
    }

    for (var mia in totaltransactionsdailycount.keys) {
      totalTranscations.add(ChartDatatC(
          1, DateTime.parse(mia), totaltransactionsdailycount[mia]));
    }

    setState(() {
      chartDatatC = totalTranscations;

      chartData = credit_debit_tc;
    });
  }

  getfulldataofuser() async {
    var dar = await AuthService().getDocuments(tranactionCollectionId,
        widget.selectedYear, widget.selectedMonth, context);

    setState(() {
      _data = dar;
    });

    final List<ChartCategoryDataByMonth> chardataCategories = [];
    final List<ChartDatamoney> data_credit = [];
    final List<ChartDatamoney> data_debit = [];

    var totaltransactionsdailycount = {};
    var tempdata_debit_range = {'1-100': 0, '100-1000': 0, '>1000': 0};
    var tempdata_credit_range = {'1-100': 0, '100-1000': 0, '>1000': 0};
    var tempdata_category = {};

    int count = 1;

    for (Map<String, dynamic> map in _data) {
      // print(map);
      // print(map['category']);

      var datestrip = DateTime.parse(map['createdAt'].toString());
      var currentdate = datestrip.toString().split(' ')[0];

      if (tempdata_category.containsKey(map['category'])) {
        if (map['transactionType'] == 'DEBIT')
          tempdata_category[map['category']] =
              tempdata_category[map['category']]! + map['amount'];
      } else {
        if (map['transactionType'] == 'DEBIT') {
          tempdata_category[map['category']] = map['amount'];
        } else {
          tempdata_category[map['category']] = 0;
        }
      }

      if (map['transactionType'] == 'CREDIT') {
        if (map['amount'] > 1000) {
          tempdata_credit_range['>1000'] = tempdata_credit_range['>1000']! + 1;
        } else if (map['amount'] > 100 && map['amount'] < 1000) {
          tempdata_credit_range['100-1000'] =
              tempdata_credit_range['100-1000']! + 1;
        } else {
          tempdata_credit_range['1-100'] = tempdata_credit_range['1-100']! + 1;
        }
      } else {
        if (map['amount'] > 1000) {
          tempdata_debit_range['>1000'] = tempdata_debit_range['>1000']! + 1;
        } else if (map['amount'] > 100 && map['amount'] < 1000) {
          tempdata_debit_range['100-1000'] =
              tempdata_debit_range['100-1000']! + 1;
        } else {
          tempdata_debit_range['1-100'] = tempdata_debit_range['1-100']! + 1;
        }
      }
      // print(datestrip.month);

      // Parse the month and year from the monthString
      // int month = int.parse(monthString.split('-')[0]);
      // int year = int.parse(monthString.split('-')[1]);

      // data1.add(ChartData(count, monthString, value1, value2, value3));
    }

    for (var tempcat in tempdata_category.keys) {
      chardataCategories.add(ChartCategoryDataByMonth(
          tempcat, tempdata_category[tempcat]!, generateRandomColor()));
    }
    // print(tempmap);

    data_debit.add(ChartDatamoney('LOW', tempdata_debit_range['1-100']!,
        '1-100', Color.fromRGBO(235, 97, 143, 1)));
    data_debit.add(ChartDatamoney('Average', tempdata_debit_range['100-1000']!,
        '100-1000', const Color.fromRGBO(145, 132, 202, 1)));
    data_debit.add(ChartDatamoney('High', tempdata_debit_range['>1000']!,
        '>1000', const Color.fromRGBO(69, 187, 161, 1)));

    data_credit.add(ChartDatamoney(
      'LOW',
      tempdata_credit_range['1-100']!,
      '1-100',
      Color.fromRGBO(235, 97, 143, 1),
    ));
    data_credit.add(ChartDatamoney(
      'Average',
      tempdata_credit_range['100-1000']!,
      '100-1000',
      const Color.fromRGBO(145, 132, 202, 1),
    ));
    data_credit.add(ChartDatamoney(
      'High',
      tempdata_credit_range['>1000']!,
      '>1000',
      const Color.fromRGBO(69, 187, 161, 1),
    ));

    var total_debit_range = tempdata_debit_range['1-100']! +
        tempdata_debit_range['100-1000']! +
        tempdata_debit_range['>1000']!;
    var total_credit_range = tempdata_credit_range['1-100']! +
        tempdata_credit_range['100-1000']! +
        tempdata_credit_range['>1000']!;

    setState(() {
      chartCategoryData = chardataCategories;
      ChartDatamoneiC = data_credit;
      ChartDatamoneiD = data_debit;
      tCC_C += total_credit_range;
      tCC_D += total_debit_range;
    });
  }

  @override
  void initState() {
    super.initState();

    _tooltipBehavior = TooltipBehavior(enable: true);
    // loaddatas(getfulldataofuser);
    getYearlydataofUser();
    getfulldataofuser();

    _labelIntersectAction = LabelIntersectAction.shift;

    // getmonthtrend(_data).then((data) {
    //   setState(() {
    //     chartData = data;
    //   });
    // });

    // gettotaltrans(widget.options).then((data) {
    //   setState(() {
    //     chartDatatC = data;
    //   });
    // });
    // getChartDatamoney(widget.options).then((data) {
    //   setState(() {
    //     ChartDatamoneiC = data[1];
    //     ChartDatamoneiD = data[0];
    //     tCC_C += double.parse(data[3].toString());
    //     tCC_D += double.parse(data[2].toString());
    //   });
    // });
  }

  Future<void> _refreshData() async {
    // Simulate a delay of 2 seconds
    await Future.delayed(Duration(seconds: 2));
    getfulldataofuser();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
                primary: false,
                padding: EdgeInsets.all(defaultPadding),
                child: Column(
                  children: [
                    Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Container(
                            padding: EdgeInsets.all(defaultPadding),
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10))),
                            child: SfCartesianChart(
                              title: ChartTitle(
                                  text: 'Debit / Credit Monthly Analysis ',
                                  textStyle:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              legend: Legend(isVisible: true),
                              tooltipBehavior: _tooltipBehavior,
                              primaryXAxis: CategoryAxis(),
                              trackballBehavior: TrackballBehavior(
                                enable: true,
                                activationMode: ActivationMode.singleTap,
                                tooltipSettings:
                                    InteractiveTooltip(enable: true),
                                markerSettings: TrackballMarkerSettings(
                                    markerVisibility:
                                        TrackballVisibilityMode.visible),
                              ),
                              series: <LineSeries<ChartData, String>>[
                                LineSeries<ChartData, String>(
                                    xAxisName: 'Credit',
                                    yAxisName: 'Total',
                                    enableTooltip: true,
                                    dataSource: chartData,
                                    xValueMapper: (ChartData data, _) =>
                                        data.month,
                                    yValueMapper: (ChartData data, _) =>
                                        data.value1,
                                    name: 'Credit',
                                    dataLabelSettings:
                                        DataLabelSettings(isVisible: true)),
                                LineSeries<ChartData, String>(
                                    yAxisName: 'Total',
                                    dataSource: chartData,
                                    xValueMapper: (ChartData data, _) =>
                                        data.month,
                                    yValueMapper: (ChartData data, _) =>
                                        data.value2,
                                    name: 'Debit',
                                    dataLabelSettings:
                                        DataLabelSettings(isVisible: true)),
                                LineSeries<ChartData, String>(
                                    color: Colors.red, // Colors.red,
                                    yAxisName: 'Total',
                                    dataSource: chartData,
                                    xValueMapper: (ChartData data, _) =>
                                        data.month,
                                    yValueMapper: (ChartData data, _) =>
                                        data.value3,
                                    name: 'Transactions',
                                    dataLabelSettings:
                                        DataLabelSettings(isVisible: true))
                              ],
                            ))),
                    Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 5,
                        child: Container(
                            padding: EdgeInsets.all(defaultPadding),
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10))),
                            child: SfCircularChart(
                                title: ChartTitle(
                                    text: 'Category Analysis',
                                    textStyle:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                legend: Legend(isVisible: true),

                                // Enables the tooltip for all the series in chart
                                tooltipBehavior: TooltipBehavior(enable: true),
                                series: [
                                  // Initialize line series
                                  PieSeries<ChartCategoryDataByMonth, String>(
                                      explode: true,
                                      explodeIndex: 0,
                                      explodeOffset: '10%',
                                      // Enables the tooltip for individual series
                                      enableTooltip: true,
                                      dataSource: chartCategoryData,
                                      xValueMapper:
                                          (ChartCategoryDataByMonth data, _) =>
                                              data.x,
                                      yValueMapper:
                                          (ChartCategoryDataByMonth data, _) =>
                                              data.y,
                                      name: 'Debits',
                                      dataLabelMapper:
                                          (ChartCategoryDataByMonth data, _) =>
                                              '${data.y}',
                                      dataLabelSettings:
                                          DataLabelSettings(isVisible: true)),
                                ]))),
                    Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 5,
                        child: Container(
                            padding: EdgeInsets.all(defaultPadding),
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10))),
                            child: SfCircularChart(
                                title: ChartTitle(
                                    text: 'Debit Analysis',
                                    textStyle:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                legend: Legend(isVisible: true),

                                // Enables the tooltip for all the series in chart
                                tooltipBehavior: TooltipBehavior(enable: true),
                                series: [
                                  // Initialize line series
                                  PieSeries<ChartData, String>(
                                      explode: true,
                                      explodeIndex: 0,
                                      explodeOffset: '10%',
                                      // Enables the tooltip for individual series
                                      enableTooltip: true,
                                      dataSource: chartData,
                                      xValueMapper: (ChartData data, _) =>
                                          data.month,
                                      yValueMapper: (ChartData data, _) =>
                                          data.value2,
                                      name: 'Debits',
                                      dataLabelSettings:
                                          DataLabelSettings(isVisible: true)),
                                ]))),
                    Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 5,
                        child: Container(
                            padding: EdgeInsets.all(defaultPadding),
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10))),
                            child: SfCircularChart(
                                title: ChartTitle(
                                    text: 'Credit Analysis',
                                    textStyle:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                legend: Legend(isVisible: true),

                                // Enables the tooltip for all the series in chart
                                tooltipBehavior: TooltipBehavior(enable: true),
                                series: [
                                  // Initialize line series

                                  PieSeries<ChartData, String>(
                                      explode: true,
                                      explodeIndex: 0,
                                      explodeOffset: '10%',
                                      // Enables the tooltip for individual series
                                      enableTooltip: true,
                                      dataSource: chartData,
                                      xValueMapper: (ChartData data, _) =>
                                          data.month,
                                      yValueMapper: (ChartData data, _) =>
                                          data.value1,
                                      name: 'Credits',
                                      dataLabelSettings:
                                          DataLabelSettings(isVisible: true))
                                ]))),
                    Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 5,
                        child: Container(
                            padding: EdgeInsets.all(defaultPadding),
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10))),
                            child: SfCircularChart(
                                title: ChartTitle(
                                    text: 'Savings Analysis',
                                    textStyle:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                legend: Legend(isVisible: true),

                                // Enables the tooltip for all the series in chart
                                tooltipBehavior: TooltipBehavior(enable: true),
                                series: [
                                  // Initialize line series
                                  PieSeries<ChartData, String>(
                                      explode: true,
                                      explodeIndex: 0,
                                      explodeOffset: '10%',
                                      // Enables the tooltip for individual series
                                      enableTooltip: true,
                                      dataSource: chartData,
                                      xValueMapper: (ChartData data, _) =>
                                          data.month,
                                      yValueMapper: (ChartData data, _) =>
                                          (data.value1 - data.value2).round(),
                                      name: 'Savings',
                                      dataLabelSettings:
                                          DataLabelSettings(isVisible: true)),
                                ]))),
                    Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 5,
                        child: Container(
                            padding: EdgeInsets.all(defaultPadding),
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10))),
                            child: getdaystrans())),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 5,
                      child: getbardistribution_c(),
                    ),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 5,
                      child: getbardistribution_d(),
                    )
                  ],
                ))));
  }

  Widget loaddatas(Function trans) {
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

  // SfCircularChart _buildSmartLabelPieChart() {
  //   return SfCircularChart(
  //     title: ChartTitle(text: 'Category Analysis'),
  //     series: _getDefaultPieSeries(),
  //     tooltipBehavior: _tooltipBehavior,
  //   );
  // }

  Widget getdaystrans() {
    return SfCartesianChart(
        plotAreaBorderWidth: 0,
        title: ChartTitle(
            text: 'Total Transactions Per Day',
            textStyle: TextStyle(fontWeight: FontWeight.bold)),
        primaryXAxis:
            DateTimeAxis(majorGridLines: const MajorGridLines(width: 0)),
        primaryYAxis: NumericAxis(),
        series: _getDefaultDateTimeSeries(),
        trackballBehavior: TrackballBehavior(
            enable: true,
            activationMode: ActivationMode.singleTap,
            tooltipSettings:
                const InteractiveTooltip(format: 'point.x : point.y')));
  }

  List<LineSeries<ChartDatatC, DateTime>> _getDefaultDateTimeSeries() {
    return <LineSeries<ChartDatatC, DateTime>>[
      LineSeries<ChartDatatC, DateTime>(
        dataSource: chartDatatC,
        xValueMapper: (ChartDatatC data, _) => data.dates as DateTime,
        yValueMapper: (ChartDatatC data, _) => data.value1,
        color: const Color.fromRGBO(242, 117, 7, 1),
      )
    ];
  }

  Widget getbardistribution_c() {
    return Container(
        child: SfCircularChart(
            tooltipBehavior: TooltipBehavior(enable: true),
            title: ChartTitle(
                text: 'Range Wise Credit Money Spent',
                textStyle: TextStyle(fontWeight: FontWeight.bold)),
            series: <CircularSeries<ChartDatamoney, String>>[
          RadialBarSeries<ChartDatamoney, String>(
              name: 'Amount Range',
              useSeriesColor: true,
              trackOpacity: 0.3,
              dataLabelSettings: DataLabelSettings(

                  // Renders the data label
                  isVisible: true),
              enableTooltip: true,
              maximumValue: tCC_C,
              radius: '100%',
              gap: '5%',
              dataSource: ChartDatamoneiC,
              cornerStyle: CornerStyle.bothCurve,
              dataLabelMapper: (ChartDatamoney data, _) => data.text,
              xValueMapper: (ChartDatamoney data, _) => data.x,
              yValueMapper: (ChartDatamoney data, _) => data.y,
              pointColorMapper: (ChartDatamoney data, _) => data.color)
        ]));
  }

  Widget getbardistribution_d() {
    return Container(
        child: SfCircularChart(
            title: ChartTitle(
                text: 'Range Wise Debit Money Spent',
                textStyle: TextStyle(fontWeight: FontWeight.bold)),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CircularSeries<ChartDatamoney, String>>[
          RadialBarSeries<ChartDatamoney, String>(
              name: 'Amount Range',
              useSeriesColor: true,
              enableTooltip: true,
              trackOpacity: 0.3,
              dataLabelSettings: DataLabelSettings(
                  // Renders the data label
                  isVisible: true),
              maximumValue: tCC_D,
              radius: '100%',
              gap: '5%',
              dataSource: ChartDatamoneiD,
              cornerStyle: CornerStyle.bothCurve,
              dataLabelMapper: (ChartDatamoney data, _) => data.text,
              xValueMapper: (ChartDatamoney data, _) => data.x,
              yValueMapper: (ChartDatamoney data, _) => data.y,
              pointColorMapper: (ChartDatamoney data, _) => data.color)
        ]));
  }
}

class ChartData {
  final int id;
  final String month;
  final double value1;
  final double value2;
  final int value3;

  ChartData(this.id, this.month, this.value1, this.value2, this.value3);
}

class ChartDatatC {
  final int id;
  final DateTime dates;
  final int value1;

  ChartDatatC(this.id, this.dates, this.value1);
}

class ChartDatamoney {
  final String x;
  final String text;
  final int y;
  final Color color;

  ChartDatamoney(this.x, this.y, this.text, this.color);
}

// class ChartCategoryData {
//   final String x;
//   final double y;

//   ChartCategoryData(this.x, this.y);
// }

class ChartCategoryDataByMonth {
  final String x;
  final int y;
  final Color color;

  ChartCategoryDataByMonth(this.x, this.y, this.color);
}
