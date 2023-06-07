import 'package:flutter/material.dart';

import '../../../components/account_check.dart';
import '../../../constants.dart';
import 'signup.dart';
import 'home.dart';
import '../components/auth.dart';
import '../responsive.dart';
import 'package:appwrite/appwrite.dart';
import '../../components/background.dart';
import '../utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

get default_string =>
    "Appwrite is using localStorage for session management. Increase your security by adding a custom domain as your API endpoint.";

class LoginScreenTopImage extends StatelessWidget {
  const LoginScreenTopImage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "LOGIN",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: defaultPadding * 2),
        Row(
          children: [
            const Spacer(),
            Expanded(
              flex: 8,
              child: SvgPicture.asset("assets/icons/login.svg"),
            ),
            const Spacer(),
          ],
        ),
        SizedBox(height: defaultPadding * 2),
      ],
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  final email = '';
  final password = '';
  TextEditingController email_contr = TextEditingController();
  TextEditingController password_contr = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _errorMessage = '';
  final _scrollController = ScrollController();
  bool _obscureText = true;

  void _validateLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      try {
        var ad = await AuthService()
            .login(email: email_contr.text, password: password_contr.text);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
          // _errorMessage = e.toString();
          _errorMessage = 'Invalid Email or Password';
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: defaultPadding * 8),
            LoginScreenTopImage(),
            Row(
              children: [
                Expanded(
                    child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Spacer(),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: defaultPadding),
                          child: TextFormField(
                            scrollPadding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            controller: email_contr,
                            cursorColor: kPrimaryColor,
                            validator: (email) {
                              if (email == null || email.isEmpty) {
                                return 'Please enter your Email';
                              }
                            },
                            onSaved: (email) {
                              email = email!;
                            },
                            decoration: InputDecoration(
                              hintText: "Your email",
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(defaultPadding),
                                child: Icon(Icons.person),
                              ),
                            ),
                          )),
                      SizedBox(height: defaultPadding),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: defaultPadding),
                        child: TextFormField(
                          scrollPadding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom),
                          textInputAction: TextInputAction.done,
                          obscureText: _obscureText,
                          controller: password_contr,
                          cursorColor: kPrimaryColor,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your Password';
                            }
                          },
                          onSaved: (password) {
                            password = password!;
                          },
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                            hintText: "Your password",
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(defaultPadding),
                              child: Icon(Icons.lock),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: defaultPadding),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _validateLogin,
                        child: _isLoading
                            ? CircularProgressIndicator()
                            : Text('Login'),
                      ),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _errorMessage,
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      // ElevatedButton(
                      //   onPressed: () async {
                      //     if (_formKey.currentState!.validate()) {

                      //   }
                      //   },

                      const SizedBox(height: defaultPadding),
                      AlreadyHaveAnAccountCheck(
                        press: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return SignUpScreen();
                              },
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).viewInsets.bottom + 20,
                      ),
                      SizedBox(height: defaultPadding * 2)
                    ],
                  ),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// class MobileLoginScreen extends StatelessWidget {
//   const MobileLoginScreen({
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: <Widget>[
//         LoginScreenTopImage(),
//         Row(
//           children: [
//             Spacer(),
//             Expanded(
//               flex: 8,
//               child: LoginForm(),
//             ),
//             Spacer(),
//           ],
//         ),
//       ],
//     );
//   }
// }

class LoginForm extends State<LoginScreen> {
  final email = '';
  final password = '';
  TextEditingController email_contr = TextEditingController();
  TextEditingController password_contr = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _errorMessage = '';

  void _validateLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            controller: email_contr,
            cursorColor: kPrimaryColor,
            validator: (email) {
              if (email == null || email.isEmpty) {
                return 'Please enter your Email';
              }
            },
            onSaved: (email) {
              email = email!;
            },
            decoration: InputDecoration(
              hintText: "Your email",
              prefixIcon: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: TextFormField(
              textInputAction: TextInputAction.done,
              obscureText: true,
              controller: password_contr,
              cursorColor: kPrimaryColor,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your Password';
                }
              },
              onSaved: (password) {
                password = password!;
              },
              decoration: InputDecoration(
                hintText: "Your password",
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.lock),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          Hero(
            tag: "login_btn",
            child: ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // print(email_contr.text);
                  // print(password_contr.text);
                  try {
                    var ad = await AuthService().login(
                        email: email_contr.text, password: password_contr.text);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return HomeScreen();
                        },
                      ),
                    );
                  } catch (e) {
                    print(e);
                  }
                }
              },
              child: Text(
                "Login".toUpperCase(),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          AlreadyHaveAnAccountCheck(
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return SignUpScreen();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
