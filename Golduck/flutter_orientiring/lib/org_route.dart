import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './globals.dart';

Future<List<Map<String, dynamic>>> fetchOrg(String raceid, String org) async {
  final response =
      await http.get(Uri.parse('$apiUrl/results?id=$raceid&organisation=$org'));

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

class OrgRoute extends StatefulWidget {
  final String raceid;
  final String _org;

  const OrgRoute(this.raceid, this._org, {Key? key}) : super(key: key);

  @override
  _OrgRouteState createState() => _OrgRouteState();
}

class _OrgRouteState extends State<OrgRoute> {
  late Future<List<Map<String, dynamic>>> futureClassificheClassi;
  Duration d = const Duration(seconds: 0);
  @override
  void initState() {
    super.initState();
    futureClassificheClassi = fetchOrg(widget.raceid, widget._org);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Org'),
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
              var orgs = snapshot.data!;

              return RefreshIndicator(
                onRefresh: _refreshData,
                child: ListView.builder(
                  itemCount: orgs.length,
                  itemBuilder: ((context, index) {
                    final d = format(
                        Duration(seconds: int.parse(orgs[index]["time"])));
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(children: <Widget>[
                        Text(
                            '${orgs[index]["position"]} - ${orgs[index]["surname"]} ${orgs[index]["name"]}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        if (orgs[index]["status"] == 'OK')
                          Text('$d')
                        else
                          Text(orgs[index]["status"]),
                        Text('${orgs[index]["class"]}')
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
      floatingActionButton: FloatingActionButton(
        hoverColor: Color.fromARGB(121, 133, 133, 133),
        hoverElevation: 50,
        tooltip: 'Return to Home',
        elevation: 12,
        onPressed: () {
          Navigator.pop(context); //return
          Navigator.pop(context); //return
          Navigator.pop(context); //return
        },
        child: const Icon(Icons.home),
      ),
    );
  }

  Future<void> _refreshData() async {
    setState(() {
      futureClassificheClassi = fetchOrg(widget.raceid, widget._org);
    });
  }

  format(Duration d) => d.toString().split('.').first.padLeft(8, "0");
}
