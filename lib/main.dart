import 'dart:async';
import 'dart:convert';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:deelz/core/presentation/notifiers/auth_state.dart';
import 'package:deelz/core/presentation/notifiers/providers.dart';
import 'package:deelz/home.dart';
import 'package:deelz/screens/login.dart';
import 'package:deelz/screens/manage_status.dart';
import 'package:deelz/screens/profile.dart';
import 'package:deelz/screens/settings_screen.dart';
import 'package:deelz/screens/signup.dart';
import 'package:deelz/screens/teams_detail_page.dart';
import 'package:deelz/screens/teams_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_theme/json_theme.dart';
import 'package:json_theme/json_theme_schemas.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SchemaValidator.enabled = false;

  final themeStr = await rootBundle.loadString('assets/appainter_theme.json');
  final themeJson = jsonDecode(themeStr);
  final theme = ThemeDecoder.decodeThemeData(themeJson)!;

  //stater kit
  //https://github.com/lohanidamodar/flutter_appwrite_starter

//https://blog.logrocket.com/appwrite-flutter-tutorial-with-examples/
  runApp(MultiProvider(
    providers: providers,
    child: MyApp(theme: theme),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key, required this.theme}) : super(key: key);
  final ThemeData theme;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Uri? _latestUri;
  // Object? _err;

  // StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    // _handleIncomingLinks();
  }

  /* Future<void> initUniLinks() async {
    _sub = linkStream.listen((String? link) {
      //
      if (link != null) {
        print('listener is working');
        print(link);
      } else {
        print('something else');
      }
    }, onError: (err) {
      //handle this. tell user their action did not succeed.
    });
  } */

  /*  void _handleIncomingLinks() {
    if (!kIsWeb) {
      // It will handle app links while the app is already started - be it in
      // the foreground or in the background.
      _sub = uriLinkStream.listen((Uri? uri) {
        if (!mounted) return;
        print('got uri: $uri');
        setState(() {
          _latestUri = uri;
          _err = null;
        });
      }, onError: (Object err) {
        if (!mounted) return;
        print('got err: $err');
        setState(() {
          _latestUri = null;
          if (err is FormatException) {
            _err = err;
          } else {
            _err = null;
          }
        });
      });
    }
  } */

  /*  final ButtonStyle flatButtonStyle = TextButton.styleFrom(
    backgroundColor: const Color(0xffe4332c),
    primary: Colors.white,
    minimumSize: const Size(88, 40),
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(9.0)),
    ), */
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        routes: {
          // '/': (context) => LoginPage(),
          '/loginpage': (context) => const LoginPage(),

          '/signuppage': (context) => SignupPage(),
          '/homepage': (context) => const HomePage(),
          '/profilepage': (context) => const ProfilePage(),
          '/teamlistpage': (context) => const TeamListPage(),
          '/teamdetailspage': (context) => TeamDetailsPage(
                teamId: null,
              ),
          '/settingsStatus': (context) => const ManageStatus(),
          '/settingspage': (context) => SettingsPage(),
          //DealManage is called with MaterialPageRoute builder
        },
        title: 'Deelz',
        // fontFamily: GoogleFonts.aleo().toString(), fontSize: 30.0)
        debugShowCheckedModeBanner: false,
        theme: widget.theme,
        home: FutureBuilder(
          future: context.read<AccountProvider>().isValid(),
          builder: (context, snapshot) =>
              context.watch<AccountProvider>().session == null
                  ? const LoginPage()
                  : const HomePage(),
        )
        /* if (snapshot.connectionState == ConnectionState.waiting) {
                return const SpinKitWave(
                  color: Colors.redAccent,
                  // duration: Duration(seconds: 6),
                );
              } */

        /* 
          if (status == 'authenticating') {
            return const Scaffold(
                body: Center(
                    child: SpinKitChasingDots(
              color: Colors.teal,
            )));
          }

          if (notLoggedIn.contains(status)) {
            return const LoginPage();
          } else if (status == 'authenticated') {
            return const HomePage();
          }
          throw ('No primary view to load. Please contact app developer'); */

        );
  }

  WindowTitleBarBox buildTitleBarButtons() {
    return WindowTitleBarBox(
      child: Row(
        children: [
          Expanded(child: Container()),
          Row(
            children: [
              MinimizeWindowButton(),
              MaximizeWindowButton(),
              CloseWindowButton()
            ],
          )
        ],
      ),
    );
  }
}
