import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class LoginPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _Login(),
    );
  }
}

class _Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();

}

class _LoginState extends State<_Login> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isSubmitting;

  @override
  void initState() {
    _isSubmitting = false;
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(hintText: 'Email'),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter email';
                }
              },
            ),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(hintText: 'Password'),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter password';
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: SizedBox(
                  width: 100.0,
                  height: 50.0,
                  child: RaisedButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _login();
                      setState(() {
                        _isSubmitting = true;
                      });
                    }
                  },
                  child: _isSubmitting ? CircularProgressIndicator() : Text('Login'),
                ),),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _login() async {

    try {
      final FirebaseUser user = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (user != null) {
        setState(() {
          _isSubmitting = false;
        });
        _afterLogin(user);
      }
    } on PlatformException catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.message), duration: Duration(milliseconds: 2000),));
      print(e.toString());
    }
  }

  void _afterLogin(FirebaseUser user) async {
    final QuerySnapshot result = await Firestore.instance.collection('users').where('id', isEqualTo: user.uid).getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    if (documents.length == 0) {
      // create a new user if it doesn't exist in users collection
      await Firestore.instance.collection('users').document(user.uid).setData(
          {'nickname': user.displayName, 'email': user.email, 'id': user.uid});
    }
    Navigator.of(context).pushReplacementNamed('/chat_list');
  }
}
