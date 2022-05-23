import 'package:flutter/material.dart';

import 'about_us.dart';
import 'classes_route.dart';

class MenuRoute extends StatelessWidget {
  final String raceid;

  const MenuRoute(this.raceid, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Available races'),
        ),
        drawer: const NavigationDrawer(),
        body: Column(children: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClassesRoute(raceid, "StartList"),
                ),
              );
            },
            child: const Text("StartList"),
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClassesRoute(raceid, "Results"),
                  ),
                );
              },
              child: Text("Results"))
        ]));
  }
}

// Drawer Class
class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Drawer(
        child: SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            buildHeader(context),
            buildMenuItems(context),
          ],
        )),
      );

  Widget buildHeader(BuildContext context) => Container(
    color: Colors.blue.shade700,
    padding: EdgeInsets.only(
      top: 24 + MediaQuery.of(context).padding.top,
      bottom: 24,
    ),
    child: Column(
      children: const [
        CircleAvatar(radius: 52, foregroundImage: NetworkImage('https://www.rete8.it/wp-content/uploads/2018/09/orienteering1-777x437.jpg')),
        Text('Orienteering APP', style: TextStyle(fontSize: 28, color: Colors.white),),
        Text('Races Results', style: TextStyle(fontSize: 15, color: Colors.white),)
      ],
    ),
  );
  
  Widget buildMenuItems(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    child: Wrap(
      runSpacing: 16,
      children: [
        /* ListTile(
          leading: const Icon(Icons.home_outlined),
          title: const Text('Home'),
          onTap: () {},
        ), */
        ListTile(
          leading: const Icon(Icons.run_circle_outlined),
          title: const Text('List Races'),
          onTap: () {
            Navigator.pop(context); // close the Draw
            Navigator.pop(context); // close the menu
          },
        ),
        const Divider(color: Colors.black54,),
        ListTile(
          leading: const Icon(Icons.people_alt_sharp),
          title: const Text('About us'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const about_us(),
              ),
            );
          },
        ),
      ],
    ),
  );
}
