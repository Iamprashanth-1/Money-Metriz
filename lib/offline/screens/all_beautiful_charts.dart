import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../services/all_sms.dart';
import '../offline_home.dart';
import '/online/components/app_theme.dart';

Map monthMap = {
  '01': 'Jan',
  '02': 'Feb',
  '03': 'Mar',
  '04': 'Apr',
  '05': 'May',
  '06': 'Jun',
  '07': 'Jul',
  '08': 'Aug',
  '09': 'Sep',
  '10': 'Oct',
  '11': 'Nov',
  '12': 'Dec',
};

Future<List<ChartData>> getmonthtrend(whereFilters) async {
  final DatabaseHelper _databaseHelp = DatabaseHelper();

  final List<ChartData> data1 = [];
  String sqlqu =
      "SELECT strftime('%m', transDate) as month,strftime('%Y', transDate) as year_col, round(SUM(creditAmount),2) as cA, round(SUM(debitAmount),2) as dA ,count(*) as tC FROM sms_data where 1=1 ";
  sqlqu += whereFilters;
  sqlqu += " GROUP BY month";
  List<Map<String, dynamic>> monthtrend = await _databaseHelp.rawquery(sqlqu);

  int count = 1;
  for (Map<String, dynamic> map in monthtrend) {
    String monthString = monthMap[map['month']];
    double value1 = map['cA'];
    double value2 = map['dA'];
    int value3 = map['tC'];

    // Parse the month and year from the monthString
    // int month = int.parse(monthString.split('-')[0]);
    // int year = int.parse(monthString.split('-')[1]);

    data1.add(ChartData(count, monthString, value1, value2, value3));
  }
  return data1;
}

Future<List<ChartDatatC>> gettotaltrans(whereFilters) async {
  final DatabaseHelper _databaseHelp = DatabaseHelper();

  final List<ChartDatatC> data1 = [];
  String sqlqu =
      "SELECT strftime('%m', transDate) as month,strftime('%Y', transDate) as year_col,strftime('%d', transDate) as day_col  ,count(*) as tC FROM sms_data where 1=1 $whereFilters  GROUP BY month,day_col";

  List<Map<String, dynamic>> monthtrend = await _databaseHelp.rawquery(sqlqu);

  int count = 1;
  for (Map<String, dynamic> map in monthtrend) {
    int month = int.parse(map['month']);
    int year = int.parse(map['year_col']);
    int day = int.parse(map['day_col']);
    int value3 = map['tC'];
    DateTime dt = DateTime(year, month, day);

    // Parse the month and year from the monthString
    // int month = int.parse(monthString.split('-')[0]);
    // int year = int.parse(monthString.split('-')[1]);

    data1.add(ChartDatatC(count, dt, value3));
  }
  return data1;
}

getChartDatamoney(whereFilters) async {
  final DatabaseHelper _databaseHelp = DatabaseHelper();

  final List<ChartDatamoney> data_c = [];
  final List<ChartDatamoney> data_d = [];
  int tCK = 0;
  double sdj_d = 0;
  double sdj_c = 0;
  String modifiedWhereFilters = 'and ';
  List modifiedWhereFiltersList = whereFilters.split('and');
  String yearcol =
      modifiedWhereFiltersList[1].split('=')[1].replaceAll(")", '');
  modifiedWhereFilters += modifiedWhereFiltersList[2];
  modifiedWhereFilters += " and ( strftime('%Y', transDate) =$yearcol ) ";
  String sqlqul =
      '''SELECT strftime('%Y', transDate) as year_col,(select count(*)  from sms_data where debitAmount between 1 and 100  $modifiedWhereFilters  ) as low_d ,
      (select count(*) from sms_data where debitAmount between 100 and 1000  $modifiedWhereFilters ) as Average_D ,
      (select count(*) from sms_data where debitAmount >1000  $modifiedWhereFilters ) as High_D ,
      (select count(*) from sms_data where creditAmount between 1 and 100  $modifiedWhereFilters  ) as Low_C ,
      (select count(*) from sms_data where creditAmount between 100 and 1000  $modifiedWhereFilters ) as Average_C ,
      (select count(*) from sms_data where creditAmount >1000  $modifiedWhereFilters ) as High_C ,
      count(*) as tC FROM sms_data where 1=1 $modifiedWhereFilters  ''';

  List<Map<dynamic, dynamic>> distibtrend =
      await _databaseHelp.rawquery(sqlqul);
  for (Map<dynamic, dynamic> maps in distibtrend) {
    double low_d = double.parse(maps['low_d'].toString());
    double avg_d = double.parse(maps['Average_D'].toString());
    double high_d = double.parse(maps['High_D'].toString());
    double low_c = double.parse(maps['Low_C'].toString());
    double avg_c = double.parse(maps['Average_C'].toString());
    double high_c = double.parse(maps['High_C'].toString());

    sdj_d = low_d + high_d + avg_d;
    sdj_c = low_c + high_c + avg_c;

    data_d.add(
        ChartDatamoney('LOW', low_d, '1-100', Color.fromRGBO(235, 97, 143, 1)));
    data_d.add(ChartDatamoney(
        'Average', avg_d, '100-1000', const Color.fromRGBO(145, 132, 202, 1)));
    data_d.add(ChartDatamoney(
        'High', high_d, '>1000', const Color.fromRGBO(69, 187, 161, 1)));
    data_c.add(ChartDatamoney(
        'LOW', low_c, '1-100', const Color.fromRGBO(235, 97, 143, 1)));
    data_c.add(ChartDatamoney(
        'Average', avg_c, '100-1000', const Color.fromRGBO(145, 132, 202, 1)));
    data_c.add(ChartDatamoney(
        'High', high_c, '>1000', const Color.fromRGBO(69, 187, 161, 1)));
  }
  return [data_d, data_c, sdj_d, sdj_c];
}

class BeautifulChart extends StatefulWidget {
  final String options;

  const BeautifulChart({Key? key, required this.options}) : super(key: key);
  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<BeautifulChart> {
  List<ChartData> chartData = [];
  List<ChartDatatC> chartDatatC = [];
  List<ChartDatamoney> ChartDatamoneiD = [];
  double tCC_C = 0;
  double tCC_D = 0;
  List<ChartDatamoney> ChartDatamoneiC = [];
  late TooltipBehavior _tooltipBehavior;

  // final List<ChartData> data = [
  //   ChartData(1, 'Jan', 20, 10),
  //   ChartData(2, 'Feb', 30, 15),
  //   ChartData(3, 'Mar', 25, 12),
  //   ChartData(4, 'Apr', 20, 10),
  //   ChartData(5, 'May', 35, 20),
  //   ChartData(6, 'Jun', 30, 15),
  // ];
  @override
  void initState() {
    super.initState();

    _tooltipBehavior = TooltipBehavior(enable: true);

    getmonthtrend(widget.options).then((data) {
      setState(() {
        chartData = data;
      });
    });
    gettotaltrans(widget.options).then((data) {
      setState(() {
        chartDatatC = data;
      });
    });
    getChartDatamoney(widget.options).then((data) {
      setState(() {
        ChartDatamoneiC = data[1];
        ChartDatamoneiD = data[0];
        tCC_C += double.parse(data[3].toString());
        tCC_D += double.parse(data[2].toString());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
  final double y;
  final Color color;

  ChartDatamoney(this.x, this.y, this.text, this.color);
}
