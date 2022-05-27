import 'dart:async';
import 'dart:convert';

import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../globals.dart';
import 'about_us.dart';
import 'components.dart';
import 'results.dart';

Future<List<String>> fetchOrgs(String raceid) async {
  final response =
      await http.get(Uri.parse('$apiUrl/list_organizations?id=$raceid'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    List<String> orgs = List<String>.from(
        jsonDecode(const Utf8Decoder().convert(response.bodyBytes)));
    orgs.sort();
    return orgs;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load classes');
  }
}

class OrganisationsRoute extends StatefulWidget {
  final String raceid;
  const OrganisationsRoute(this.raceid, {Key? key}) : super(key: key);

  @override
  _OrganisationsRouteState createState() => _OrganisationsRouteState();
}

class _OrganisationsRouteState extends State<OrganisationsRoute> {
  late Future<List<String>> futureOrgs;

  @override
  void initState() {
    super.initState();

    futureOrgs = fetchOrgs(widget.raceid);
  }

  Future<void> _refresh() {
    setState(() {
      futureOrgs = fetchOrgs(widget.raceid);
    });

    return futureOrgs;
  }

  List<AZItem> initList(List<String> orgs) {
    return orgs
        .map((o) => AZItem(o, o.characters.first.toUpperCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Organizations'), actions: <Widget>[
        IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              _refresh();
            })
      ]),
      drawer: const NavigationDrawer(),
      body: Center(
        child: RefreshIndicator(
          color: Colors.blueAccent,
          onRefresh: _refresh,
          child: FutureBuilder<List<String>>(
            future: futureOrgs,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<String> orgs = snapshot.data!;
                List<AZItem> items = initList(orgs);
                //aggiunta header
                items.insert(0, AZItem("header", "_"));

                DateTime lastRefresh = DateTime.now().toLocal();

                return AzListView(
                    data: items,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return index == 0
                          ? Container(
                              margin: const EdgeInsets.fromLTRB(16, 10, 16, 25),
                              child: Text(
                                  "ultimo aggiornamento: \n ${lastRefresh.toString()}",
                                  style: const TextStyle(fontSize: 15.0)))
                          : nextPageButton(
                              ResultsRoute(widget.raceid, orgs[index - 1]),
                              orgs[index - 1]);
                    });
              } else if (snapshot.hasError) {
                return ListView.builder(
                    itemCount: 1,
                    itemBuilder: (context, index) =>
                        ConnFailTile("${snapshot.error}"));
              }

              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        hoverColor: Color.fromARGB(121, 133, 133, 133),
        hoverElevation: 50,
        tooltip: 'Return to Home',
        elevation: 12,
        onPressed: () {
          Navigator.pop(context); //return to menu
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
            CircleAvatar(
              radius:
                  52, /* foregroundImage: NetworkImage('https://www.rete8.it/wp-content/uploads/2018/09/orienteering1-777x437.jpg') */
            ),
            Text(
              'Orienteering APP',
              style: TextStyle(fontSize: 28, color: Colors.white),
            ),
            Text(
              'Races Results',
              style: TextStyle(fontSize: 15, color: Colors.white),
            )
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
                Navigator.pop(context); // close the start
                Navigator.pop(context); // close the menu
              },
            ),
            const Divider(
              color: Colors.black54,
            ),
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
