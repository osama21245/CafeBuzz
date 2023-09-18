import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class ModToolsScreen extends StatelessWidget {
  final String name;
  const ModToolsScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    void navigateEditModerator(BuildContext context) {
      Routemaster.of(context).push('/edit-community/$name');
    }

    void navigateAddModerator(BuildContext context) {
      Routemaster.of(context).push('/add-mods/$name');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Mod Tools"),
      ),
      body: Column(
        children: [
          ListTile(
            onTap: () {
              navigateAddModerator(context);
            },
            leading: Icon(Icons.add_moderator),
            title: Text("Add Admins"),
          ),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text("Edit Community"),
            onTap: () {
              navigateEditModerator(context);
            },
          )
        ],
      ),
    );
  }
}
