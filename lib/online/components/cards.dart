import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'constants.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'auth.dart';

import '../utils.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({
    Key? key,
    required this.title,
    required this.svgSrc,
    required this.amountOf,
  }) : super(key: key);

  final String title;
  final Widget amountOf;
  final Color svgSrc;

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 200,
      // width: MediaQuery.of(context).size.width - 290,

      margin: EdgeInsets.only(top: defaultPadding),
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: primaryColor.withOpacity(0.15)),
        borderRadius: const BorderRadius.all(
          Radius.circular(defaultPadding),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
                width: 20,
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: svgSrc,
                ),
              ),
              SizedBox(width: defaultPadding),
              Text(
                title,
                textAlign: TextAlign.center,
                // maxLines: 1,
                overflow: TextOverflow.fade,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          amountOf
        ],
      ),
    );
  }
}

// final kBackgroundWidgetGradientDecoration = BoxDecoration(
//   gradient: LinearGradient(
//     begin: Alignment.topLeft,
//     colors: [
//       AppColors.white.withOpacity(0.3),
//       AppColors.greyBlack.withOpacity(0.3),
//     ],
//   ),
//   borderRadius: BorderRadius.circular(16.0),
// );

// final kBackgroundWidgetInnerDecoration = BoxDecoration(
//   image:  DecorationImage(
//     filterQuality: FilterQuality.high,
//     image: AssetImage(AssetImages.imgNoise),
//     fit: BoxFit.fill,
//   ),
//   color: AppColors.greyBlack,
//   borderRadius: BorderRadius.circular(backgroundBorderRadius),
// );

class BackgroundWidget extends StatelessWidget {
  const BackgroundWidget({required this.child});

  final Widget child;
  Color calculateTextColor(Color background) {
    return ThemeData.estimateBrightnessForColor(background) == Brightness.light
        ? Colors.white
        : Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 4,
      color: calculateTextColor(Theme.of(context).colorScheme.background),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Stack(
            fit: StackFit.loose,
            alignment: Alignment.center,
            children: [
              Container(
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserView extends StatelessWidget {
  final String currentAccount;
  final String username;
  const UserView(
      {Key? key, required this.currentAccount, required this.username})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BackgroundWidget(
      child: Stack(
        children: [
          _showRightUserImage(context),
          // _widgetBlurView(),
          _widgetUserViewTextColumn(context),
        ],
      ),
    );
  }

  Widget _widgetUserViewTextColumn(context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 32,
        left: 25,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Flexible(
                child: Text(
              'Hello, $username \u{1F44B} \n\nHow was it going today?',
              style: TextStyle(
                // color: Color.fromARGB(255, 255, 1, 213),
                fontSize: MediaQuery.of(context).size.width / 25,
                fontFamily: 'Rubik',
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.bold,
              ),
            ))
          ]),
          const SizedBox(
            height: 18,
          ),
        ],
      ),
    );
  }

  Widget _showRightUserImage(context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 10.0, top: 10.0),
        child: Image.asset(
          "assets/images/img_user_2.png",
          fit: BoxFit.cover,
          height: MediaQuery.of(context).size.height / 6,
        ),
      ),
    );
  }

  Widget _widgetBlurView() {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16.0),
            bottomRight: Radius.circular(16.0),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 3,
              sigmaY: 3,
            ),
            child: Container(
              height: 62,
            ),
          ),
        ),
      ),
    );
  }
// }
}

class MonthlyBudgetCard extends StatefulWidget {
  // final String currentAccount;
  // final String username;
  final double monthlybudgetAmount;
  final double monthlybudgetSpent;
  final String currentMonthBudgetDocumentId;
  const MonthlyBudgetCard({
    Key? key,
    required this.monthlybudgetAmount,
    required this.monthlybudgetSpent,
    required this.currentMonthBudgetDocumentId,
  }) : super(key: key);
  @override
  _MonthlyBudgetState createState() => _MonthlyBudgetState();
}

class _MonthlyBudgetState extends State<MonthlyBudgetCard> {
  double _size = 200;
  double _value = 400;
  @override
  void initState() {
    super.initState();
    // Do some calculations...
    // Set the final value
    setState(() {
      _value = widget.monthlybudgetSpent;
    });
  }

  TextEditingController _monthlybudgetEditController =
      new TextEditingController(); // this is the controller
  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size.height / 5.5;
    _monthlybudgetEditController.text = widget.monthlybudgetAmount.toString();
    return BackgroundWidget(
      child: Stack(
        children: [
          getEditIcon(),
          _getFirstProgressBar(),

          // _widgetBlurView(),
          _widgetUserViewTextColumn(context),
        ],
      ),
    );
  }

  Widget _getFirstProgressBar() {
    return Align(
        alignment: Alignment.centerRight,
        child: Padding(
            padding: const EdgeInsets.only(right: 30.0, top: 10.0),
            child: SizedBox(
              height: _size,
              width: _size,
              child: SfRadialGauge(axes: <RadialAxis>[
                RadialAxis(
                    showLabels: false,
                    showTicks: false,
                    radiusFactor: 0.8,
                    minimum: -1,
                    maximum: widget.monthlybudgetAmount,
                    axisLineStyle: const AxisLineStyle(
                      thickness: 0.2,
                      cornerStyle: CornerStyle.bothCurve,
                      color: Color.fromARGB(30, 181, 0, 142),
                      thicknessUnit: GaugeSizeUnit.factor,
                    ),
                    pointers: <GaugePointer>[
                      RangePointer(
                          value: _value,
                          cornerStyle: CornerStyle.bothCurve,
                          width: 0.2,
                          sizeUnit: GaugeSizeUnit.factor,
                          enableAnimation: true,
                          animationDuration: 3000,
                          animationType: AnimationType.linear)
                    ],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                          positionFactor: 0.1,
                          angle: 90,
                          widget: Text(
                            _value.toStringAsFixed(0) +
                                ' / ${widget.monthlybudgetAmount}',
                            style: const TextStyle(fontSize: 11),
                          ))
                    ])
              ]),
            )));
  }

  Widget _widgetUserViewTextColumn(context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 32,
        left: 25,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Flexible(
                child: Text(
              'Monthly Budget \n \nAmount ${widget.monthlybudgetAmount}\u{1F4B0} \n \n  ',
              style: TextStyle(
                // color: Color.fromARGB(255, 255, 1, 213),
                fontSize: MediaQuery.of(context).size.width / 25,
                fontFamily: 'Rubik',
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.bold,
              ),
            ))
          ]),
          const SizedBox(
            height: 18,
          ),
        ],
      ),
    );
  }

  Widget getEditIcon() {
    return Align(
        alignment: Alignment.centerRight,
        child: InkWell(
            onTap: () {
              showbudgeteditpopup();
            },
            child: Padding(
                padding: const EdgeInsets.only(right: 5.0, top: 10.0),
                child: IconButton(
                  icon: Icon(
                    Icons.edit,
                  ),
                  onPressed: () {
                    showbudgeteditpopup();
                  },
                ))));
  }

  showbudgeteditpopup() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Edit Monthly Budget'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextField(
                    controller: _monthlybudgetEditController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter Monthly Budget',
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: Text('Cancel'),
                onPressed: () {
                  // Handle OK button press
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: Text('Save'),
                onPressed: () {
                  AuthService().updateDocument(monthlyBudgetCollectionId,
                      widget.currentMonthBudgetDocumentId, {
                    'budgetAmount': double.parse(
                        _monthlybudgetEditController.text.toString())
                  });
                  StatusMessagePopup(
                          message: 'Updated', duration: Duration(seconds: 2))
                      .show(context);

                  // Handle OK button press
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
