import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:deelz/core/presentation/notifiers/auth_state.dart';

class TeamDetailsPage extends StatefulWidget {
  TeamDetailsPage({Key? key, this.teamId, this.teamName}) : super(key: key);

  String? teamId;
  String? teamName;
  @override
  _TeamDetailsPageState createState() => _TeamDetailsPageState();
}

class _TeamDetailsPageState extends State<TeamDetailsPage> {
  List<Membership> memberships = [];
  //team list used in Invite pop-up
  List<Team> teams = [];
  //email controller
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _getTeamMembers();
    _getTeams();
    _emailController = TextEditingController();
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

  _getTeamMembers() async {
    try {
      final res =
          await AccountProvider().membershipList(teamId: widget.teamId!);
      memberships = res.memberships
          .map((member) => Membership?.fromMap(member.toMap()))
          .toList();

      setState(() {});
    } on AppwriteException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> openInvitePrompt(BuildContext context) async {
    return await showDialog(
        // barrierDismissible: false,
        context: context,
        builder: (context) {
          // builder: (context) {
          return AlertDialog(
            title: const Text('Invite team member'),
            scrollable: true,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(hintText: 'Email'),
                ),
                ...teams.map((e) => ListTile(
                      title: Text(e.name),
                    )),
                /* Container(
                  color: Colors.grey,
                  height: 300,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: 15,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Card(
                            child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text('List Item $index'),
                        )),
                      );
                    },
                  ),
                ), */
              ],
            ),
            actions: [
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      //pop
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  const Spacer(),
                  TextButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.teal)),
                    onPressed: () {
                      //pop
                      Navigator.of(context).pop();
                    },
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Team Details :: ${widget.teamName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const TextField(
              decoration: InputDecoration(hintText: 'Email'),
            ),
            ElevatedButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Container(
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Invite to Team',
                                style: TextStyle(color: Colors.blueAccent),
                              ),
                            ),
                            // color: Colors.blueAccent,
                          ),
                          content: setupAlertDialoadContainer(context),
                        );
                      });
                },
                child: const Text('Invite')),
            buildTeamList('teamId'),
          ],
        ),
      ),
    );
  }

  Widget setupAlertDialoadContainer(context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(hintText: 'Email'),
        ),
        Container(
          color: Colors.grey,
          height: 300,
          width: 300,
          child: ListView(
            shrinkWrap: true,
            children: [
              ...teams.map((team) => ListTile(
                    onTap: () async {
                      try {
                        await AccountProvider().membershipAdd(
                          'New user',
                          teamId: team.$id,
                          email: _emailController.text.trim(),
                          roles: ['sales'],
                        );
                        _getTeamMembers();
                        Navigator.of(context).pop();
                      } on AppwriteException catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(e.message ?? 'Error inviting user')));
                      }
                    },
                    title: Text(team.name),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildTeamList(String teamId) {
    return Expanded(
      child: ListView(
        shrinkWrap: true,
        children: [
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Team Members',
              style: TextStyle(fontSize: 21),
            ),
          ),
          ...memberships.map(
            (memberhip) => ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(memberhip.userName),
                  (memberhip.confirm)
                      ? Icon(Icons.check)
                      : Icon(Icons.circle_outlined)
                ],
              ),
              subtitle: Row(children: []),
              onTap:
                  () {} /* Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TeamDetailsPage(
                    teamId: memberhip.$id,
                  ),
                ),
              ) */
              ,
            ),
          ),
        ],
      ),
    );
  }
}
