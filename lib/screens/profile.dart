import 'package:flutter/material.dart';
import '../components/auth.dart';
import '../utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'login.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  TextEditingController _inputController2 = TextEditingController();
  String _username = '';
  String _password = '';
  String _email = '';
  String _version = 'Unknown';

  getuserrelateddata() async {
    Map _userdata = await AuthService().getuserdata();

    setState(() {
      _username = _userdata['name'];
      _email = _userdata['email'];
    });
  }

  Future<void> _getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
    });
  }

  void initState() {
    super.initState();
    getuserrelateddata();
    _getVersion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: Text('User Profile'),
        // ),
        body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              CircleAvatar(
                backgroundImage: AssetImage('assets/images/img_user.png'),
                radius: 50,
              ),
              Text(
                '$_username',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                  onPressed: () {
                    showdialog('name');
                  },
                  icon: Icon(Icons.edit))
            ],
          ),
          SizedBox(
            height: 50,
          ),

          getcards(
              'Email: $_email ',
              Icon(
                Icons.email,
                color: Colors.black54,
              ),
              'email'),
          SizedBox(
            height: 10,
          ),
          getcards(
              'Password:  ',
              Icon(
                Icons.password,
                color: Colors.black54,
              ),
              'password'),
          SizedBox(height: 500),
          Center(
              child: Column(
            children: [
              ElevatedButton(
                  onPressed: () {
                    AuthService().logout();
                    AuthService().removeuserSession();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                  child: Text('Logout')),
              SizedBox(
                height: 10,
              ),
              Text(
                'Version $_version',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ],
          )),

          // add more user profile information here
        ],
      ),
    ));
  }

  Widget getcards(String wtext, icon, String updatetext) {
    return Card(
      // color: Colors.white70,
      margin: const EdgeInsets.only(left: 35, right: 35, bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: ListTile(
        leading: icon,
        title: Text(
          wtext,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        trailing: InkWell(
            onTap: () {
              showdialog(updatetext);
            },
            child: Icon(Icons.edit)),
      ),
    );
    // const SizedBox(
    //   height: 10,
    // )
  }

  void showdialog(String updatedType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Return the popup window
        return AlertDialog(
          title: Text('Enter $updatedType'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _inputController2,
                decoration: InputDecoration(
                  labelText: 'Updated $updatedType',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('OK'),
              onPressed: () async {
                var statusmessage = '';
                if (updatedType == 'name') {
                  var dat =
                      await AuthService().updateName(_inputController2.text);
                  statusmessage = dat;
                } else if (updatedType == 'password') {
                  var dat = await AuthService()
                      .updatepassword(_inputController2.text);
                  statusmessage = dat;
                } else {
                  var dat =
                      await AuthService().updateEmail(_inputController2.text);
                  statusmessage = dat;
                }
                if (statusmessage == 'true') {
                  StatusMessagePopup(
                          message: 'Updated $updatedType Succesfully',
                          duration: Duration(seconds: 2))
                      .show(context);
                } else {
                  StatusMessagePopup(
                          message: 'Unable to Update',
                          duration: Duration(seconds: 2))
                      .show(context);
                }

                _inputController2.text = '';
                // Close the popup window
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
