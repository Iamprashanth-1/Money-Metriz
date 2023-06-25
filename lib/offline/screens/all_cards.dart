import 'dart:ui';

import 'package:flutter/material.dart';

import '../../online/components/app_theme.dart';

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
          SizedBox(height: 10),
          // Expanded(
          //   child: Padding(
          //     padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         Text(
          //           title,
          //           maxLines: 1,
          //           overflow: TextOverflow.ellipsis,
          //         ),
          //         // SizedBox(height: 1),
          //         // Text(
          //         //   "$numOfFiles Files",
          //         //   style: Theme.of(context)
          //         //       .textTheme
          //         //       .caption!
          //         //       .copyWith(color: Colors.white70),
          //         // ),
          //       ],
          //     ),
          //   ),
          // ),
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
              'Hello, $username \u{1F44B}\n\nCurrent A/C : $currentAccount \n\nYour Analytics \nIn Your Hand',
              style: TextStyle(
                color: Color.fromARGB(255, 255, 1, 213),
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
