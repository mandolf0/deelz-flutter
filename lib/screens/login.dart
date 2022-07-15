import 'package:deelz/core/res/app_constants.dart';
import 'package:deelz/data/store.dart';
import 'package:deelz/screens/widgets/auth_page_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/presentation/notifiers/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _email =
      TextEditingController(text: 'mando@me.com');
  late final TextEditingController _password =
      TextEditingController(text: 'asdfasdf');
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AuthPageHeader(headline: ''),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(29),
                ),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(16.0),
                    children: <Widget>[
                      IconButton(
                        onPressed: () async => await Store.remove("session"),
                        icon: Icon(Icons.delete),
                        color: Colors.red,
                      ),

                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _email,
                        decoration: const InputDecoration(
                            hintText: "E-mail",
                            prefixIcon: Icon(
                              Icons.mail_outline,
                              color: Colors.black,
                            )),
                        validator: (value) {
                          if (value != "" && value!.length > 8) {
                            return null;
                          }
                          return 'Email is required';
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _password,
                        obscureText: true,
                        decoration: const InputDecoration(
                            hintText: "password",
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: Colors.black,
                            )),
                        validator: (value) {
                          if (value != null) {
                            if (value.length >= 8) {
                              return null;
                            } else {
                              return 'Double check your email and password';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 23),

                      //login button here centered
                      Center(
                        child: MaterialButton(
                          minWidth: MediaQuery.of(context).size.width * 0.5,
                          color: Colors.black,
                          textColor: Colors.white,
                          shape: StadiumBorder(),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final api = context.read<AccountProvider>();

                              final email = _email.text;
                              final password = _password.text;

                              if (email.isEmpty || password.isEmpty) {
                                showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                          title: const Text('Error'),
                                          content: const Text(
                                              'Please enter your email and password'),
                                          actions: [
                                            TextButton(
                                                child: const Text('OK'),
                                                onPressed: () =>
                                                    Navigator.pop(context))
                                          ],
                                        ));

                                return;
                              }
                              await api
                                  .login(email: email, password: password)
                                  .then((value) =>
                                      Navigator.pushNamed(context, '/homepage'))
                                  .onError((error, stackTrace) =>
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content:
                                                  Text(error.toString()))));

                              /*   Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const HomeScreen()),
                            ); */

                            }
                          },
                          child: const Text('Sign In'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              //Widgets below the container: forgot, create account
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  //forgot
                  TextButton(
                    onPressed: () {
                      AccountProvider().forgotPassword(email: _email.text);

                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Password reset link sent')));
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const Spacer(),
                  //register
                  GestureDetector(
                    onTap: () =>
                        Navigator.popAndPushNamed(context, '/signuppage'),
                    child: const Text(
                      'Register',
                      style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.kcSecondary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
