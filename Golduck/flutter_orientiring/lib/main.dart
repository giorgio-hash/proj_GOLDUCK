
import 'dart:convert';

import 'package:flutter/material.dart';

import 'about_us.dart';
import 'components.dart';
import 'globals.dart';
import 'menu.dart';
import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>> fetchRaces() async {
  final response = await http.get(Uri.parse('$apiUrl/list_races'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return List<Map<String, dynamic>>.from(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load classes');
  }
}

void main() {
  runApp(const MaterialApp(
      title: 'Ori Live Results',
      home: MyApp(),
      debugShowCheckedModeBanner: false));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<Map<String, dynamic>>> futureRaces;
  Map<String, Icon> icone = {
    "ordina per nome": const Icon(Icons.sort_by_alpha_outlined),
    "ordina per data": const Icon(Icons.watch_later_outlined)
  };
  List<String> scelte = ["ordina per data", "ordina per nome"];
  String? _scelta;

  @override
  void initState() {
    super.initState();
    futureRaces = fetchRaces();
    _scelta = scelte[0];
  }

  Future<void> _refresh() {
    setState(() {
      futureRaces = fetchRaces();
    });

    return futureRaces;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Available races'), actions: <Widget>[

          IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () {
                _refresh();
              }),
        ]),
        drawer: const NavigationDrawer(),
        body: Center(
            child: RefreshIndicator(
          color: Colors.blueAccent,
          onRefresh: _refresh,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: futureRaces,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var classes = snapshot
                    .data!; // il ! è imperativo: specifico a Dart che questa variabile non può essere null

                var items = [
                  Container(
                      height: 60.0,
                      child: ButtonTheme(
                        alignedDropdown: true,
                        child: DropdownButton(
                            value: _scelta,
                            onChanged: (e) {
                              setState(() {
                                _scelta = e.toString();
                                _scelta == scelte[0]
                                    ? classes.sort((a, b) {
                                        var data1 = b["race_date"].split(".");
                                        var data2 = a["race_date"].split(".");

                                        return DateTime(
                                                int.parse(data1[2]),
                                                int.parse(data1[1]),
                                                int.parse(data1[0]))
                                            .compareTo(DateTime(
                                                int.parse(data2[2]),
                                                int.parse(data2[1]),
                                                int.parse(data2[0])));
                                      })
                                    : classes.sort((a, b) => a["race_name"]
                                        .compareTo(b["race_name"]));
                              });
                            },
                            isExpanded: true,
                            items: (scelte.map((e) => DropdownMenuItem(
                                value: e,
                                child: Container(
                                    decoration: const BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                width: 3,
                                                color: Colors.black26))),
                                    child: ListTile(
                                        leading: icone[e],
                                        title: Text(e)))))).toList()),
                      )),
                  ...classes.map((e) => nextPageButton(
                      MenuRoute(e["race_id"], e["race_name"]),
                      e["race_date"] + "\n" + e["race_name"]))
                ];

                return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: ((context, index) => items[index] as Widget));
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
        )));
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
