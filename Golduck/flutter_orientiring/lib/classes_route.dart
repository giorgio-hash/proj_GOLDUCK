import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './globals.dart';
import 'about_us.dart';
import 'classifiche_route.dart';
import 'start_route.dart';

Future<List<String>> fetchClasses(String raceid) async {
  final response = await http.get(Uri.parse('$apiUrl/list_classes?id=$raceid'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return List<String>.from(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load classes');
  }
}

class ClassesRoute extends StatefulWidget {
  final String raceid;
  final String option;
  const ClassesRoute(this.raceid, this.option, {Key? key}) : super(key: key);

  @override
  _ClassesRouteState createState() => _ClassesRouteState();
}

class _ClassesRouteState extends State<ClassesRoute> {
  late Future<List<String>> futureClasses;

  @override
  void initState() {
    super.initState();
    futureClasses = fetchClasses(widget.raceid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classes'),
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () {
                _refreshData();
              }),
        ],
      ),
      drawer: const NavigationDrawer(),
      body: Center(
        child: FutureBuilder<List<String>>(
          future: futureClasses,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<String> classes = snapshot.data!;
              return RefreshIndicator(
                onRefresh: _refreshData,
                child: ListView.builder(
                  itemCount: classes.length,
                  itemBuilder: ((context, index) => ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                if (widget.option == "Results") {
                                  return ClassificheRoute(
                                      widget.raceid, classes[index]);
                                } else if (widget.option == "StartList") {
                                  return StartRoute(
                                      widget.raceid, classes[index]);
                                } else {
                                  throw Exception('Impossible Exception');
                                }
                              },
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(classes[index]),
                        ),
                      )),
                ),
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }

            // By default, show a loading spinner.
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    setState(() {
      futureClasses = fetchClasses(widget.raceid);
    });
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
        CircleAvatar(radius: 52,),
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
            Navigator.pop(context); // return to menu
            Navigator.pop(context); // return to home page
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
