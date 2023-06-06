import 'dart:math';

import 'package:flutter/material.dart';
import '../constants.dart';
import '../responsive.dart';
import '../../components/background.dart';

import '../../../components/account_check.dart';
import 'login.dart';
import '../components/auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils.dart';

class SignUpScreenTopImage extends StatelessWidget {
  const SignUpScreenTopImage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Sign Up".toUpperCase(),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: defaultPadding),
        Row(
          children: [
            const Spacer(),
            Expanded(
              flex: 8,
              child: SvgPicture.asset("assets/icons/signup.svg"),
            ),
            const Spacer(),
          ],
        ),
        SizedBox(height: defaultPadding),
      ],
    );
  }
}

class SignUpForm extends StatelessWidget {
  const SignUpForm({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            onSaved: (email) {},
            decoration: InputDecoration(
              hintText: "Your Name",
              prefixIcon: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person),
              ),
            ),
          ),
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            onSaved: (email) {},
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
              cursorColor: kPrimaryColor,
              decoration: InputDecoration(
                hintText: "Your password",
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.lock),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding / 2),
          ElevatedButton(
            onPressed: () {},
            child: Text("Sign Up".toUpperCase()),
          ),
          const SizedBox(height: defaultPadding),
          AlreadyHaveAnAccountCheck(
            login: false,
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return LoginScreen();
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

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _signUpScreenState createState() => _signUpScreenState();
}

class _signUpScreenState extends State<SignUpScreen> {
  final email = '';
  final password = '';
  final name = '';
  TextEditingController email_contr = TextEditingController();
  TextEditingController password_contr = TextEditingController();
  TextEditingController name_contr = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _errorMessage = '';
  bool _obscureText = true;

  void _validateSignup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      try {
        var ad = await AuthService().signUp(
            name: name_contr.text,
            email: email_contr.text,
            password: password_contr.text);
        StatusMessagePopup(message: 'Signed Up', duration: Duration(seconds: 2))
            .show(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
          // _errorMessage = e.toString();
          _errorMessage = 'Something went wrong please try again';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: defaultPadding * 8),
            SignUpScreenTopImage(),
            Row(
              children: [
                Expanded(
                    flex: 8,
                    child:
                        // SocalSignUp()
                        Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: defaultPadding),
                              child: TextFormField(
                                scrollPadding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context)
                                        .viewInsets
                                        .bottom),
                                keyboardType: TextInputType.name,
                                controller: name_contr,
                                textInputAction: TextInputAction.next,
                                cursorColor: kPrimaryColor,
                                onSaved: (name) {
                                  email_contr.text = name!;
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your Name';
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: "Your Name",
                                  prefixIcon: Padding(
                                    padding:
                                        const EdgeInsets.all(defaultPadding),
                                    child: Icon(Icons.person),
                                  ),
                                ),
                              )),
                          SizedBox(height: defaultPadding / 2),
                          Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: defaultPadding),
                              child: TextFormField(
                                scrollPadding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context)
                                        .viewInsets
                                        .bottom),
                                controller: email_contr,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                cursorColor: kPrimaryColor,
                                onSaved: (email) {
                                  email_contr.text = email!;
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your Email';
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: "Your email",
                                  prefixIcon: Padding(
                                    padding:
                                        const EdgeInsets.all(defaultPadding),
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
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom),
                              controller: password_contr,
                              textInputAction: TextInputAction.done,
                              obscureText: _obscureText,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your Password';
                                }
                              },
                              cursorColor: kPrimaryColor,
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
                          // ElevatedButton(
                          //   onPressed: () {},
                          //   child: Text("Sign Up".toUpperCase()),
                          // ),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _validateSignup,
                            child: _isLoading
                                ? CircularProgressIndicator()
                                : Text('Signup'),
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
                          const SizedBox(height: defaultPadding),
                          AlreadyHaveAnAccountCheck(
                            login: false,
                            press: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return LoginScreen();
                                  },
                                ),
                              );
                            },
                          ),
                          SizedBox(
                            height:
                                MediaQuery.of(context).viewInsets.bottom + 20,
                          ),
                          SizedBox(height: defaultPadding * 2),
                        ],
                      ),
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }
}

class MobileSignupScreen extends StatelessWidget {
  const MobileSignupScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SignUpScreenTopImage(),
        Row(
          children: [
            Spacer(),
            Expanded(
              flex: 8,
              child: SignUpForm(),
            ),
            Spacer(),
          ],
        ),
        // const SocalSignUp()
      ],
    );
  }
}
