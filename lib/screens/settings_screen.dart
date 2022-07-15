import 'package:flutter/material.dart';
import 'package:deelz/extensions.dart';

class SettingsPage extends StatelessWidget {
  final Map<String, String> settingpages = {
    'Statuses': '/settingsStatus',
    'Users': '/settingsusers',
    'Teams': '/teamlistpage',
  };
  SettingsPage({Key? key, Map<String, dynamic>? settingpages})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: ListView(
        // controller: controller,
        children: settingpages.entries
            .map(
              (entry) => Card(
                elevation: 1.0,
                shadowColor: Color(0xff909090),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  onTap: () => Navigator.pushNamed(context, entry.value),
                  tileColor: Colors.white,
                  title: Text(
                    entry.key,
                    style: TextStyle(fontSize: 19.0),
                  ),
                ),
              ),
            )
            .toList()
        //statuses

        //users

        //teams
        ,
      ),
    );
  }
}
