import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var account_global;
  @override
  void initState() {
    super.initState();
  }

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () async {
                  final user = await account_global.create(
                      userId: ID.unique(),
                      email: _emailController.text,
                      password: _passwordController.text,
                      name: 'My Name');
                  // try {
                  //   UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                  //     email: _emailController.text,
                  //     password: _passwordController.text,
                  //   );
                  //   // handle successful login
                  // } on FirebaseAuthException catch (e) {
                  //   if (e.code == 'user-not-found') {
                  //     // handle user not found
                  //   } else if (e.code == 'wrong-password') {
                  //     // handle incorrect password
                  //   }
                  // }
                },
                child: Text('Login'),
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupPage()),
                  );
                },
                child: Text('Create an account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create an account'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () async {
                  // try {
                  //   UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  //     email: _emailController.text,
                  //     password: _passwordController.text,
                  //   );
                  //   // handle successful signup
                  // } on FirebaseAuthException catch (e) {
                  //   if (e.code == 'weak-password') {
                  //     // handle weak password
                  //   } else if (e.code == 'email-already-in-use') {
                  //     // handle email already registered
                  //   }
                  // }
                },
                child: Text('Create account'),
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
