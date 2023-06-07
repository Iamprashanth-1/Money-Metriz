import 'package:flutter/material.dart';
import 'dart:math';

SnackBar createErrorSnackBar(String? content) {
  return SnackBar(
    backgroundColor: Colors.red[900],
    content: Text(content ?? 'An error occurred'),
  );
}

class StatusMessagePopup extends StatelessWidget {
  final String message;
  final Duration duration;

  StatusMessagePopup({required this.message, required this.duration});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        height: 50.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.blue,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          message,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void show(BuildContext context) {
    OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.1,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: StatusMessagePopup(
                message: message,
                duration: duration,
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }
}

class MonthYearPicker extends StatefulWidget {
  final void Function(DateTime) onDateSelected;

  MonthYearPicker({required this.onDateSelected});

  @override
  _MonthYearPickerState createState() => _MonthYearPickerState();
}

class _MonthYearPickerState extends State<MonthYearPicker> {
  late final int _selectedMonth;
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now().month;
    _selectedYear = DateTime.now().year;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropdownButton<int>(
          value: _selectedMonth,
          items: List<DropdownMenuItem<int>>.generate(12, (int index) {
            return DropdownMenuItem<int>(
              value: index + 1,
              child: Text("${index + 1}"),
            );
          }),
          onChanged: (value) {
            setState(() {
              _selectedMonth = value!;
            });
            _onDateSelected();
          },
        ),
        SizedBox(width: 16.0),
        DropdownButton<int>(
          value: _selectedYear,
          items: List<DropdownMenuItem<int>>.generate(50, (int index) {
            return DropdownMenuItem<int>(
              value: DateTime.now().year - index,
              child: Text("${DateTime.now().year - index}"),
            );
          }),
          onChanged: (value) {
            setState(() {
              _selectedYear = value!;
            });
            _onDateSelected();
          },
        ),
      ],
    );
  }

  void _onDateSelected() {
    DateTime selectedDate = DateTime(_selectedYear, _selectedMonth);
    widget.onDateSelected(selectedDate);
  }
}

Color generateRandomColor() {
  Random random = Random();
  return Color.fromARGB(
    255,
    random.nextInt(256),
    random.nextInt(256),
    random.nextInt(256),
  );
}
