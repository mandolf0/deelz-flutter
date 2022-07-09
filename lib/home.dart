import 'dart:async';
import 'dart:io' show Platform;

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:deelz/api/client.dart';
import 'package:deelz/core/presentation/notifiers/auth_state.dart';
import 'package:deelz/core/res/app_constants.dart';
import 'package:deelz/data/model/transaction.dart';
import 'package:deelz/screens/deal_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uni_links/uni_links.dart';

bool _initialURILinkHandled = false;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Uri? _initialUri;
  Uri? _latestUri;
  Object? _err;
  StreamSubscription? _sub;

  late Future<User> _user;
  Transaction? transaction;

  @override
  void initState() {
    super.initState();
    _handleIncomingLinks();
    _initURIHandler();
    // _user = AuthState().current!;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _initURIHandler() async {
    if (!_initialURILinkHandled) {
      _initialURILinkHandled = true;
      Fluttertoast.showToast(
          msg: "Invoked _initURIHandler",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white);
      try {
        final initialURI = await getInitialUri();
        // Use the initialURI and warn the user if it is not correct,
        // but keep in mind it could be `null`.
        if (initialURI != null) {
          debugPrint("Initial URI received $initialURI");
          if (!mounted) {
            return;
          }
          setState(() {
            _initialUri = initialURI;
          });
        } else {
          debugPrint("Null Initial URI received");
        }
      } on PlatformException {
        // Platform messages may fail, so we use a try/catch PlatformException.
        // Handle exception by warning the user their action did not succeed
        debugPrint("Failed to receive initial uri");
      } on FormatException catch (err) {
        if (!mounted) {
          return;
        }
        debugPrint('Malformed Initial URI received');
        setState(() => _err = err);
      }
    }
  }

  void _handleIncomingLinks() {
    if (!kIsWeb) {
      // It will handle app links while the app is already started - be it in
      // the foreground or in the background.
      _sub = uriLinkStream.listen((Uri? uri) {
        if (!mounted) return;
        print('got uri: $uri');

        Navigator.popAndPushNamed(context, '/logout');
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
  }

  @override
  Widget build(BuildContext context) {
    final queryParams = _latestUri?.queryParametersAll.entries.toList();
    if (queryParams != null) {
      print(queryParams);
    }
    return Scaffold(
      drawer: buildDrawer(context),
      appBar: !Platform.isWindows
          ? AppBar(
              actions: [
                IconButton(
                  color: Colors.white,
                  onPressed: () async {
                    try {
                      await AccountProvider().logout();

                      Navigator.popAndPushNamed(context, '/loginpage');
                    } on AppwriteException catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(e.message ?? 'Error login out')));
                    }
                  },
                  icon: const Icon(Icons.logout),
                ),
              ],
              title: const Text('Deelz Mobile'),
            )
          : AppBar(
              backgroundColor: Colors.transparent,
              title: WindowTitleBarBox(
                child: MoveWindow(
                  child: Text('Deelz'),
                ),
              ),
            ),
      body: const DealsList(),
    );
  }
}

Widget buildDrawer(BuildContext context) {
  return FutureBuilder(
      future: ApiClient.account.get(),
      builder: ((BuildContext context, AsyncSnapshot<User> snapshot) {
        // builder: ((context, snapshot) {
        //
        return snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done
            ? Drawer(
                child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserAccountsDrawerHeader(
                    onDetailsPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/profilepage');
                    },
                    accountName: Text(snapshot.data?.name ?? 'n/a'),

                    accountEmail: Text(snapshot.data?.email ?? ''
                        // snapshot.data!.email,
                        ),
                    currentAccountPicture: CircleAvatar(
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/mando.jpg',
                          height: 110,
                          width: 110,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    //TODO!: implement user avatar
                    decoration: const BoxDecoration(
                      color: Colors.indigoAccent,
                      /*  image: DecorationImage(
                  image: AssetImage('assets/images/headerbg.png'),
                  fit: BoxFit.cover), */
                    ),
                  ),
                  ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text(
                        'Settings',
                        style: AppConstants.ksTextStyleLightSecondary,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/settingspage');
                      }),
                  Divider(),
                  ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text(
                        'Logout',
                        style: AppConstants.ksTextStyleLightSecondary,
                      ),
                      onTap: () async {
                        /*      final api = context.read<AuthState>();
                        await api.logout(); */
                        await AccountProvider().logout();
                        Navigator.pushNamed(context, '/loginpage');

                        /*  .then((value) {
                          Navigator.pushNamedAndRemoveUntil(context,
                              '/loginpage', ModalRoute.withName("/loginpage"));
                        }); */
                      }
                      //Navigator.pushNamed(context, '/loginscreen'),
                      ),
                ],
              ))
            : CircularProgressIndicator();
        //
      }));
}

/* return Drawer(
      // backgroundColor: Color(0xff366CF6),
      child: Wrap(
        runSpacing: 16,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              image: SvgPicture.asset('assets/images/mando.jpg')
                  as DecorationImage,
              color: Colors.blue,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                GestureDetector(
                    child: const Hero(
                      tag: 'myprofile',
                      child: CircleAvatar(
                        backgroundImage: AssetImage('assets/images/mando.jpg'),
                        radius: 54.0,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/profilepage');
                      ;
                    }),
                Text(
                  AuthState().user!.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
r    ); */
