import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './globals.dart';
import './classes_route.dart';

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
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<List<Map<String, dynamic>>> futureRaces = fetchRaces();

  Future<Null> _refresh() async {
    futureRaces = fetchRaces();
    //Redraw widgets
    setState(() => {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Available races'),
        ),
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: Center(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: futureRaces,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var classes = snapshot.data!;
                  return ListView.builder(
                    itemCount: classes.length,
                    itemBuilder: ((context, index) => ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return ClassesRoute(classes[index]["race_id"]);
                                }
                              ),
                            );
                          },
                          child: Text(classes[index]["race_name"]),
                        )),
                  );
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }

                // By default, show a loading spinner.
                return const CircularProgressIndicator();
              },
            ),
          ),
        ));
  }
}
