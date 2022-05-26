import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './globals.dart';
<<<<<<< Updated upstream
import 'components.dart';

Future<List<dynamic>> fetchStart(String raceid, String clazz) async {
  final response = await http.get(Uri.parse('$apiUrl/list_start?id=$raceid&class=$clazz'));
=======
import 'Punto3/atleta.dart';
import 'Punto3/components.dart';

Future<Map<String, List<atletaStart>>> fetchStart(String raceid) async {
  final response =
      await http.get(Uri.parse('$apiUrl/list_start?id=$raceid&class=*'));

>>>>>>> Stashed changes
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    //fetch _JsonMap
    List<atletaStart> atleti = List<atletaStart>.from((jsonDecode(Utf8Decoder().convert(response.bodyBytes)) as List<dynamic>).map((e) => atletaStart(e["name"],e["surname"],e["org"],e["time"],e["class"])));
    atleti.sort((a,b) => a.surname.compareTo(b.surname) == 0? a.name.compareTo(b.name) : a.surname.compareTo(b.surname) );

    List<String> classi = atleti.map((e) => e.clazz).toSet().toList();
    classi.sort((a,b) => a.compareTo(b));


    Map<String, List<atletaStart>> atleti_per_classe = {};

    for(String classe in classi ){
      atleti_per_classe[classe] = [];
      for(atletaStart a in atleti){
        if(a.clazz == classe)
          atleti_per_classe[classe]!.add(a);
      }
    }

    return atleti_per_classe;


  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception(
        'Non è stato possibile reperire la griglia di partenza per questa gara!');
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

    setState((){

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
        appBar: AppBar(
          title: const Text('Start'),
        ),
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
                      margin: EdgeInsets.fromLTRB(16, 10, 16, 25),
                      child: Text(
                          "ultimo aggiornamento:\n ${lastRefresh.toString()}",
                          style: TextStyle(fontSize: 15.0))),
                  ...atleti.keys.map((classid) => ExpansionTile(
                    title: Text(classid, style:  TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
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
                return ListView.builder(
                    itemCount: 1,
                    itemBuilder: (context, index) =>
                        ConnFailTile("${snapshot.error}"));
              }

              // By default, show a loading spinner.
              return const Center(child: CircularProgressIndicator());
            },
          ),
        )
        /*
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Center(
          child: FutureBuilder<List<dynamic>>(
            future: futureStarts,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List starts = snapshot.data!;
                return ListView.builder(
                  itemCount: starts.length,
                  itemBuilder: (_, index) => Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                        color: const Color(0xff4f92da),
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.15),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ]),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${snapshot.data![index]["name"]} ${snapshot.data![index]["surname"]}",
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Organisation: ${snapshot.data![index]["org"]}",
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 5.0, 0, 5.0),
                          child: Builder(builder: (context) {
                            //Transform ISO date to more readable
                            DateTime date =
                                DateTime.parse(snapshot.data![index]["time"]);
                            DateFormat dateFormat = DateFormat("HH:mm:ss");
                            return Text(
                              "Time: ${dateFormat.format(date)}",
                              style: const TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                return ListView.builder(
                    itemCount: 1,
                    itemBuilder: (context, index) =>
                        ConnFailTile("Non è stato possibile reperire la griglia di partenza per questa gara!"));
              }

              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
       */
        );
  }

  _buildExpandableContent(List<atletaStart>? lista) {
    List<Widget> columnContent = [];

    for (atletaStart a in lista!) {
      columnContent.add(StartTile(a));
    }

    return columnContent;
  }
}
