import 'package:flutter/material.dart';
import '../services/all_sms.dart';
import '/online/components/app_theme.dart';

class AddPopup extends StatefulWidget {
  const AddPopup({Key? key}) : super(key: key);

  @override
  _AddPopupState createState() => _AddPopupState();
}

class _AddPopupState extends State<AddPopup> {
  List<TextEditingController> controllers = [TextEditingController()];

  void addTextField() {
    setState(() {
      controllers.add(TextEditingController());
    });
  }

  void removeTextField(int index) {
    setState(() {
      controllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Please add last 4 digits of your Account Number'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...controllers.asMap().entries.map((entry) {
            final int index = entry.key;
            final TextEditingController controller = entry.value;

            return Row(
              children: [
                Expanded(child: TextField(controller: controller)),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => removeTextField(index),
                ),
              ],
            );
          }).toList(),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: addTextField,
            child: Text('Add one more Account Number'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            print(controllers.map((e) => e.text).toList());
            // Handle the submit button press here
          },
          child: Text('Done'),
        ),
      ],
    );
  }
}

class MyDialog extends StatefulWidget {
  @override
  _MyDialogState createState() => _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
  List<String> _fields = [''];
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  void _addTextField() {
    setState(() {
      _fields.add('');
    });
  }

  void _deleteTextField(int index) {
    setState(() {
      if (_fields.length == 1) {
        return;
      }
      _fields.removeAt(index);
    });
  }

  void _saveData(_fields) async {
    // for (var i = 0; i < _fields.length; i++) {
    //   var ae = await _databaseHelper.checkAccountExists(_fields[i]);
    // }
    await _databaseHelper.rawinsert(_fields);

    // Perform your desired action with the entered fields
    // For example, you can save them to a database
    // Or display them on the screen
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        " Please add last 4 digits of your Account Number \n\n If you don't have any a/c number in sms then add account name",
        style: TextStyle(fontSize: 15),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < _fields.length; i++)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.account_balance),
                      hintText: 'A/c Number ${i + 1}',
                      errorText:
                          _fields[i].isEmpty ? 'Field is required' : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _fields[i] = value;
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _deleteTextField(i);
                  },
                ),
              ],
            ),
          SizedBox(height: 20),
          ElevatedButton(
            child: Text('Add One More Account Number',
                style: TextStyle(fontSize: 15)),
            onPressed: _addTextField,
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        ElevatedButton(
          child: Text('Save'),
          onPressed: () {
            bool fieldsValid = true;
            _fields.forEach((field) {
              if (field.isEmpty) {
                fieldsValid = false;
              }
            });
            if (fieldsValid) {
              _saveData(_fields);
              Navigator.pop(context);
            } else {
              setState(() {});
            }
          },
        ),
      ],
    );
  }
}

class MyDialogRemove extends StatefulWidget {
  final List options;

  const MyDialogRemove({Key? key, required this.options}) : super(key: key);
  @override
  _MyDialogStateremove createState() => _MyDialogStateremove();
}

class _MyDialogStateremove extends State<MyDialogRemove> {
  List<String> _fields = [''];
  List _options = ['XX'];
  List _selectedOptions = [true];
  @override
  void initState() {
    super.initState();

    setState(() {
      _options = widget.options;
    });
    for (int i = 0; i < 100; i++) {
      _selectedOptions.add(false);
    }
  }

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  void _addTextField() {
    setState(() {
      _fields.add('');
    });
  }

  void _deleteTextField(int index) {
    setState(() {
      if (_fields.length == 1) {
        return;
      }
      _fields.removeAt(index);
    });
  }

  void deletedata() async {
    for (int i = 0; i < _options.length; i++) {
      if (_selectedOptions[i]) {
        await _databaseHelper.remove(_options[i]);
      }
    }

    // Perform your desired action with the entered fields
    // For example, you can save them to a database
    // Or display them on the screen
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Please Choose Your Account Number to Delete'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              height: MediaQuery.of(context).size.height / 5,
              width: 200,
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
          SizedBox(height: 20),
        ],
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        ElevatedButton(
          child: Text('Delete'),
          onPressed: () {
            bool fieldsValid = true;

            if (fieldsValid) {
              deletedata();
              setState(() {});
              Navigator.pop(context);
            } else {
              setState(() {});
            }
          },
        ),
      ],
    );
  }
}
