import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:json_diff/json_diff.dart';

import './globals.dart';
import 'atleta.dart';
import 'components.dart';

Map<dynamic, dynamic> json1 = {};
Map<dynamic, dynamic> json2 = {};
List<String> differenze = [];
bool online = false;

Future<Map<String, List<atletaStart>>> fetchStart(String raceid) async {
  final response =
      await http.get(Uri.parse('$apiUrl/list_start?id=$raceid&class=*'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    //fetch _JsonMap

    var fetched = (jsonDecode(const Utf8Decoder().convert(response.bodyBytes))
        as List<dynamic>);
    if (!online) {
      online = true;



      differenze.clear();
      json2.clear();
      for (var j in fetched) {
        json1[j["name"]+j["surname"]] = j;

      }
    } else {

      for (var j in fetched) {
        json2[j["name"]+j["surname"]] = j;
      }

      differenze.clear();

      for (Object key in json2.keys) {
        if (json1.keys.contains(key)) {
          DiffNode diff = (JsonDiffer.fromJson(json2[key], json1[key])).diff();
          if (diff.changed.keys.isNotEmpty) differenze.add(key.toString());
        } else {
          differenze.add(key.toString());
        }
      }

      json1 = Map<dynamic, dynamic>.from(json2);
    }

    List<atletaStart> atleti = List<atletaStart>.from(
        (jsonDecode(const Utf8Decoder().convert(response.bodyBytes))
                as List<dynamic>)
            .map((e) => atletaStart(
                e["name"], e["surname"], e["org"], e["time"], e["class"])));
    atleti.sort((a, b) => a.surname.compareTo(b.surname) == 0
        ? a.name.compareTo(b.name)
        : a.surname.compareTo(b.surname));

    List<String> classi = atleti.map((e) => e.clazz).toSet().toList();
    classi.sort((a, b) => a.compareTo(b));

    Map<String, List<atletaStart>> atleti_per_classe = {};

    for (String classe in classi) {
      atleti_per_classe[classe] = [];
      for (atletaStart a in atleti) {
        if (a.clazz == classe) atleti_per_classe[classe]!.add(a);
      }
    }

    return atleti_per_classe;
  } else {
    // then throw an exception.
    throw Exception('Start list not found');
  }
}

class StartRoute extends StatefulWidget {
  final String raceid;

  const StartRoute(this.raceid, {Key? key}) : super(key: key);

  @override
  _StartRouteState createState() => _StartRouteState();
}

class _StartRouteState extends State<StartRoute> {
  late Future<Map<String, List<atletaStart>>> futureStarts;
  late DateTime lastRefresh;

  Future<void> _refresh() {
    setState(() {
      futureStarts = fetchStart(widget.raceid);
    });

    return futureStarts;
  }

  @override
  void initState() {
    super.initState();
    futureStarts = fetchStart(widget.raceid);
    lastRefresh = DateTime.now().toLocal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Start'), actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () {
                _refresh();
              })
        ]),
        body: RefreshIndicator(
          color: Colors.blueAccent,
          onRefresh: _refresh,
          child: FutureBuilder<Map<String, List<atletaStart>>>(
            future: futureStarts,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Map<String, List<atletaStart>> atleti = snapshot.data!;
                lastRefresh = DateTime.now().toLocal();

                List<Widget> objs = [
                  Container(
                      margin: const EdgeInsets.fromLTRB(16, 10, 16, 25),
                      child: Text(
                          "ultimo aggiornamento:\n ${lastRefresh.toString()}",
                          style: const TextStyle(fontSize: 15.0))),
                  ...atleti.keys.map((classid) => ExpansionTile(
                        title: Text(classid,
                            style: const TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic)),
                        children: <Widget>[
                          Column(
                            children: _buildExpandableContent(atleti[classid]),
                          ),
                        ],
                      ))
                ];

                return ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: objs.length,
                    itemBuilder: ((context, index) => objs[index]));
              } else if (snapshot.hasError) {
                online = false;

                return ListView.builder(
                    itemCount: 1,
                    itemBuilder: (context, index) =>
                        ConnFailTile("StartList non presente"));
              }

              // By default, show a loading spinner.
              return const Center(child: CircularProgressIndicator());
            },
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

  _buildExpandableContent(List<atletaStart>? lista) {
    List<Widget> columnContent = [];

    for (atletaStart a in lista!) {
      columnContent.add(
          differenze.contains(a.name+a.surname)? Container(color: Colors.red.shade100,child: StartTile(a)) : StartTile(a)
      );
    }

    return columnContent;
  }
}
