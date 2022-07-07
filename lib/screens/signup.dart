import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:deelz/core/presentation/notifiers/auth_state.dart';
import 'package:deelz/core/res/app_constants.dart';
import 'package:deelz/screens/widgets/auth_page_header.dart';
import 'package:provider/provider.dart';

class SignupPage extends StatefulWidget {
  SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  late TextEditingController _username = TextEditingController();
  late TextEditingController _email = TextEditingController();
  late TextEditingController _password = TextEditingController();
  late TextEditingController _repeatPassword = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AuthPageHeader(headline: 'Register'),
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
                      TextFormField(
                        controller: _username,
                        decoration: const InputDecoration(
                            hintText: "Name",
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: Colors.black,
                            )),
                        //TODO* if usernmae will be required add validator
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
                            return value;
                          }
                          return 'Email is required';
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                          controller: _password,
                          obscureText: true,
                          decoration: const InputDecoration(
                              hintText: "Password",
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: Colors.black,
                              )),
                          validator: (value) {
                            if (_repeatPassword.text != value || value == "") {
                              return 'Passwords must match';
                            }
                            return null;
                          }),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _repeatPassword,
                        validator: (value) {
                          if (_password.text != value || value == "") {
                            return 'Passwords must match';
                          }
                          return null;
                        },
                        obscureText: true,
                        decoration: const InputDecoration(
                            hintText: "Repeat Password",
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: Colors.black,
                            )),
                      ),
                      const SizedBox(height: 23),
                      Center(
                        child: MaterialButton(
                            minWidth: MediaQuery.of(context).size.width * 0.5,
                            color: Colors.black,
                            textColor: Colors.white,
                            shape: StadiumBorder(),
                            onPressed: () async {
                              AccountProvider state =
                                  Provider.of<AccountProvider>(context,
                                      listen: false);
                              //call login
                              if (_formKey.currentState!.validate()) {
                                try {
                                  final User user = await state.createAccount(
                                      _username.text,
                                      _email.text,
                                      _password.text);

                                  if (user.email.isNotEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "Successfully Signed up. Now sign in.")));
                                    Navigator.popAndPushNamed(
                                        context, '/loginpage');
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "Try again. Signing up.")));
                                  }
                                } on Exception catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text('Error signing up')));
                                }
                              }
                            },
                            child: Text('Sign Up')),
                      ),
                      const SizedBox(height: 30),
                    ]),
              ),
            ),
            //
            // const SizedBox(height: 23),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'Already have an account?',
                  style: TextStyle(color: Colors.white),
                ),
                TextButton(
                    onPressed: () =>
                        Navigator.popAndPushNamed(context, '/loginpage'),
                    child: Text(
                      'Sign in',
                      style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.kcSecondary),
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }
}
