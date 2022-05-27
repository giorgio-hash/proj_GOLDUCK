import 'dart:async';
import 'dart:convert';

import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:json_diff/json_diff.dart';

import '../globals.dart';
import 'atleta.dart';
import 'components.dart';

Map<dynamic, dynamic> json1 = {};
Map<dynamic, dynamic> json2 = {};
List<String> differenze = [];
bool online = false;

Future<List<atleta>> fetchResults(String raceid, String org) async {
  final response = await http
      .get(Uri.parse('$apiUrl/results_filter?id=$raceid&organisation=$org'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.

    var fetched = (jsonDecode(const Utf8Decoder().convert(response.bodyBytes))
        as List<dynamic>);
    if (!online) {
      online = true;

      differenze.clear();
      json2.clear();
      for (var j in fetched) {
        json1[j["name"] + j["surname"]] = j;
      }
    } else {
      for (var j in fetched) {
        json2[j["name"] + j["surname"]] = j;
      }

      differenze.clear();

      for (Object key in json2.keys) {
        if (json1.keys.contains(key)) {
          DiffNode diff = (JsonDiffer.fromJson(json2[key], json1[key])).diff();
          // ignore: prefer_is_empty
          if (diff.changed.keys.length > 0) differenze.add(key.toString());
        } else {
          differenze.add(key.toString());
        }
      }

      json1 = Map<dynamic, dynamic>.from(json2);
    }

    List<atleta> atleti = List<atleta>.from(
        (jsonDecode(const Utf8Decoder().convert(response.bodyBytes))
                as List<dynamic>)
            .map((e) => atleta(e["name"], e["surname"], e["org"], e["position"],
                e["time"], e["class"], e["status"])));
    atleti.sort((a, b) => a.surname.compareTo(b.surname) == 0
        ? a.name.compareTo(b.name)
        : a.surname.compareTo(b.surname));

    return atleti;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load organizations');
  }
}

class allAthlRoute extends StatefulWidget {
  final String raceid;
  final String org;
  const allAthlRoute(this.raceid, this.org, {Key? key}) : super(key: key);

  @override
  _allAthlRouteState createState() => _allAthlRouteState();
}

class _allAthlRouteState extends State<allAthlRoute> {
  late Future<List<atleta>> futureRes;

  Future<void> _refresh() {
    setState(() {
      futureRes = fetchResults(widget.raceid, widget.org);
    });

    return futureRes;
  }

  @override
  void initState() {
    super.initState();
    futureRes = fetchResults(widget.raceid, widget.org);
  }

  List<AZItem> initList(List<atleta> atl) {
    return atl
        .map((a) => AZItem(
            a.surname + a.name, a.surname.characters.first.toUpperCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("risultati: tutti gli atleti"),
          actions: <Widget>[
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
        child: FutureBuilder<List<atleta>>(
          future: futureRes,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<atleta> atl = snapshot.data!;
              List<AZItem> items = initList(atl);
              //aggiungi header
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
                        : (differenze.contains(
                                atl[index - 1].name + atl[index - 1].surname)
                            ? Container(
                                color: Colors.red.shade100,
                                child: AthleteTile(atl[index - 1],
                                    "classe: ${atl[index - 1].classid}"))
                            : AthleteTile(atl[index - 1],
                                "classe: ${atl[index - 1].classid}"));
                  });
            } else if (snapshot.hasError) {
              online = false;

              return ListView.builder(
                  itemCount: 1,
                  itemBuilder: (context, index) =>
                      ConnFailTile("${snapshot.error}"));
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
          Navigator.pop(context); //return
          Navigator.pop(context); //return
          Navigator.pop(context); //return
          Navigator.pop(context); //return
        },
        child: const Icon(Icons.home),
      ),
    );
  }
}
