import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:deelz/data/store.dart';
import 'package:flutter/material.dart';
import 'package:deelz/api/client.dart';
import 'package:deelz/core/presentation/notifiers/auth_state.dart';
import 'package:deelz/core/res/app_constants.dart';
import 'package:deelz/screens/teams_detail_page.dart';
import 'package:provider/provider.dart';
// import 'package:deelz/data/model/team.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<Team> teams = [];

  @override
  void initState() {
    super.initState();
    _getTeams();
  }

  _getTeams() async {
    try {
      final res = await AccountProvider().listTeams();
      setState(() {
        teams = res.teams.map((team) => Team.fromMap(team.toMap())).toList();
      });
    } on AppwriteException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  //for form validation
  final formKey = GlobalKey<FormState>();
  late String teamName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Profile'), actions: [
        IconButton(
          onPressed: () async {
            /*  await Store.get('mycompanyid').then((value) {
                print(value);
 }); */
            AccountProvider().usersAvailable?.forEach((myUser) {
              print(myUser['userName']);
            });
          },
          icon: Icon(Icons.account_box),
        )
      ]),
      body: Consumer<AccountProvider>(
        builder: (context, state, child) {
          final user = state.current;
          if (state.signedIn == false) return Container();

          return Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 11.0),
              children: [
                const Hero(
                  tag: 'myprofile',
                  child: CircleAvatar(
                    backgroundImage: AssetImage('assets/images/mando.jpg'),
                    radius: 184.0,
                  ),
                ),
                state.current?.emailVerification == false
                    ? ElevatedButton(
                        child: const Text('Send Verification email'),
                        onPressed: () => AccountProvider().verifyEmail().then(
                            (value) => ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                                    content: const Text(
                                        'Email verification link sent')))),
                      )
                    : Container(
                        child: const Icon(
                        Icons.circle,
                        color: Colors.green,
                      )),
                ListTile(
                  title: Text(state.current?.name ?? '',
                      style: AppConstants.ksTextStyleLightSecondary),
                ),
                ListTile(
                  title: Text(state.current!.email,
                      style: AppConstants.ksTextStyleLightSecondary),
                ),
                const ListTile(
                  title: Text("https://youtu.be/X9vw4PGDbGc?t=383",
                      style: AppConstants.ksTextStyleLightSecondary),
                ),
                const SizedBox(height: 10.0),
                Center(
                  child: Text(
                    'Preferences',
                    style: AppConstants.ksTextStyleLightSecondary.copyWith(
                      fontSize: 23,
                    ),
                  ),
                ),
                Text(state.current!.prefs.data['company']),
                Center(
                  child: Text(
                    'My Teams',
                    style: AppConstants.ksTextStyleLightSecondary.copyWith(
                      fontSize: 23,
                    ),
                  ),
                ),
                ...teams.map(
                  (team) => ListTile(
                    title: Text(team.name),
                    /*  trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Members ${team.total.toString()}"),
                        IconButton(
                            onPressed: () async {
                              try {
                                await AccountProvider()
                                    .deleteTeam(teamId: team.$id)
                                    .then((value) => _getTeams());
                              } on AppwriteException catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('error deleting team')));
                              }
                            },
                            icon: const Icon(Icons.delete))
                      ],
                    ), */
                    /*onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TeamDetailsPage(
                                  teamId: team.$id,
                                  teamName: team.name,
                                ))),*/
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
