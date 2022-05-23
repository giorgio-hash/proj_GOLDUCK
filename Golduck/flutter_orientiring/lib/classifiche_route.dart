import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_orientiring/org_route.dart';
import 'package:http/http.dart' as http;

import './globals.dart';

Future<List<Map<String, dynamic>>> fetchClassificaClassi(
    String raceid, String classe) async {
  final response =
      await http.get(Uri.parse('$apiUrl/results?id=$raceid&class=$classe'));

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

class ClassificheRoute extends StatefulWidget {
  final String raceid;
  final String _class;

  const ClassificheRoute(this.raceid, this._class, {Key? key})
      : super(key: key);

  @override
  _ClassificheRouteState createState() => _ClassificheRouteState();
}

class _ClassificheRouteState extends State<ClassificheRoute> {
  late Future<List<Map<String, dynamic>>> futureClassificheClassi;
  Duration d = const Duration(seconds: 0);
  @override
  void initState() {
    super.initState();
    futureClassificheClassi =
        fetchClassificaClassi(widget.raceid, widget._class);
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
      body: Center(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: futureClassificheClassi,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var classes = snapshot.data!;

              return RefreshIndicator(
                onRefresh: _refreshData,
                child: ListView.builder(
                  itemCount: classes.length,
                  itemBuilder: ((context, index) {
                    final d = format(
                        Duration(seconds: int.parse(classes[index]["time"])));
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(children: <Widget>[
                        Text(
                            '${classes[index]["position"]} - ${classes[index]["surname"]} ${classes[index]["name"]}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        if (classes[index]["status"] == 'OK')
                          Text('$d')
                        else
                          Text(classes[index]["status"]),
                        RichText(
                          text: TextSpan(
                              text: '${classes[index]["org"]}',
                              style: const TextStyle(
                                color: Colors.blue,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrgRoute(
                                          widget.raceid, classes[index]["org"]),
                                    ),
                                  );
                                }),
                        ),
                      ]),
                    );
                  }),
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
      futureClassificheClassi =
          fetchClassificaClassi(widget.raceid, widget._class);
    });
  }

  format(Duration d) => d.toString().split('.').first.padLeft(8, "0");
}
