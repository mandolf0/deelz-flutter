import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:deelz/api/client.dart';

import 'package:deelz/core/presentation/notifiers/auth_state.dart';
import 'package:deelz/core/res/app_constants.dart';
import 'package:deelz/extensions.dart';
import 'package:deelz/screens/teams_detail_page.dart';

class TeamListPage extends StatefulWidget {
  const TeamListPage({Key? key}) : super(key: key);

  @override
  State<TeamListPage> createState() => _TeamListPageState();
}

class _TeamListPageState extends State<TeamListPage> {
  List<Team> teams = [];
  final TextEditingController? _teamEditId = TextEditingController();
  final TextEditingController? _teamEditName = TextEditingController();

  late String editBoxLabel = 'Add Team';
  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  init() async {
    _teamEditId?.text = '';
    _teamEditName?.text = '';
    editBoxLabel = 'Add Team';

    _getTeams();
  }

//upsert team
  saveTeam({required String name, String? id}) async {
    switch (id) {
      case "":
        //insert
        await ApiClient.teams.create(teamId: 'unique()', name: name);

        break;
      default:
        await ApiClient.teams.update(teamId: id!, name: name);

      //update
    }
  }

  _getTeams() async {
    try {
      TeamList res = await AccountProvider().listTeams();
      setState(() {
        teams = res.teams.map((team) => Team.fromMap(team.toMap())).toList();
      });
    } on AppwriteException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  final _formKeyGeneral = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        // backgroundColor: AppConstants.kcScaffoldBkg,
        appBar: AppBar(
          title: const Text("Teams"),
          actions: [
            IconButton(
              onPressed: () {
                init();
              },
              icon: Icon(Icons.cancel),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ListView(
              // shrinkWrap: true,
              // controller: controller,
              children: [
                // textfield to add team.
                const SizedBox(height: 8),

                Form(
                  key: _formKeyGeneral,
                  child: Column(
                    children: [
                      Text(editBoxLabel, style: AppConstants.ksTextStyleLight),
                      Row(
                        // mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TextFormField(
                              validator: (value) {
                                if (value!.length < 3) {
                                  return 'Team name is required';
                                  // return value;
                                }
                                _teamEditName!.text = value;
                                return null;
                              },
                              controller: _teamEditName,
                              decoration: const InputDecoration(
                                  fillColor: Colors.white, filled: true),
                            ),
                          ),
                          //team save icon
                          IconButton(
                              onPressed: () async {
                                if (_formKeyGeneral.currentState!.validate()) {
                                  try {
                                    await saveTeam(
                                        name: _teamEditName!.text,
                                        id: _teamEditId?.text);
                                    init();
                                  } catch (e) {
                                    print(e);
                                  }
                                }
                              },
                              icon: Icon(
                                _teamEditId!.text.isNotEmpty
                                    ? Icons.save_rounded
                                    : Icons.add_circle_rounded,
                                size: 28,
                                color: AppConstants.kcSecondary,
                              ))
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ...teams.map(
                  (team) => Card(
                    elevation: 1.0,
                    child: ListTile(
                      tileColor: Colors.white,
                      title: Text(team.name),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Members ${team.total.toString()}",
                            style: AppConstants.ksTextStyleLightSecondary,
                          ),
                          IconButton(
                              onPressed: () async {
                                try {
                                  await AccountProvider()
                                      .deleteTeam(teamId: team.$id)
                                      .then((value) => _getTeams());
                                } on AppwriteException catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('error deleting team')));
                                }
                              },
                              icon: const Icon(Icons.delete))
                        ],
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TeamDetailsPage(
                                  teamId: team.$id,
                                  teamName: team.name,
                                )),
                      ),
                      onLongPress: () {
                        setState(() {
                          editBoxLabel = "Editing:  ${team.name}";
                          _teamEditName?.text = team.name;
                          _teamEditId?.text = team.$id;
                        });
                      },
                    ).addNeumorphism(),
                  ),
                ),
              ]
              //statuses

              //users

              //teams
              ,
            ),
          ),
        ),
      ),
    );
  }
}
