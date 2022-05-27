import 'package:flutter/material.dart';
import 'package:flutter_orientiring/start_route.dart';

import 'about_us.dart';
import 'components.dart';
import 'organizations.dart';
import 'classifiche_route.dart';

class MenuRoute extends StatelessWidget {
  final String raceid;
  final String racename;

  const MenuRoute(this.raceid, this.racename, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> objs = [
      Container(
          margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Text("risultati gara: $racename\n",
              style: const TextStyle(fontSize: 15.0))),
      nextPageButton(StartRoute(raceid), "Griglia di partenza"),
      nextPageButton(ClassificheRoute(raceid), "filtra per classe"),
      nextPageButton(OrganisationsRoute(raceid), "Organizzationi")
    ];

    return Scaffold(
        appBar: AppBar(
          title: const Text('Available races'),
        ),
        drawer: const NavigationDrawer(),
        body: ListView.builder(
            itemCount: objs.length, itemBuilder: (c, i) => objs[i]),
        floatingActionButton: FloatingActionButton(
          hoverColor: const Color.fromARGB(121, 133, 133, 133),
          hoverElevation: 50,
          tooltip: 'Return to Home',
          elevation: 12,
          onPressed: () {
            Navigator.pop(context); //return to home
          },
          child: const Icon(Icons.home),
        ),
      );
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
        CircleAvatar(radius: 52,
        /* foregroundImage: NetworkImage('https://www.rete8.it/wp-content/uploads/2018/09/orienteering1-777x437.jpg') */),
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
