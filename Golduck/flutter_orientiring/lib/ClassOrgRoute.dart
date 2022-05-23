
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'atleta.dart';
import 'components.dart';
import 'globals.dart';

Future<Map<String, List<atleta>>> fetchClasses(String raceid, String org) async {

  final response = await http.get(Uri.parse('$apiUrl/results_filter?id=$raceid&organisation=$org'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.


    List<atleta> atleti = List<atleta>.from((jsonDecode(Utf8Decoder().convert(response.bodyBytes)) as List<dynamic>).map((e) => atleta(e["name"],e["surname"],e["org"],e["position"],e["time"],e["class"])));
    atleti.sort((a,b) => a.surname.compareTo(b.surname) == 0? a.name.compareTo(b.name) : a.surname.compareTo(b.surname) );

    List<String> classi = atleti.map((e) => e.classid).toSet().toList();
    classi.sort((a,b) => a.compareTo(b));

    Map<String, List<atleta>> atleti_per_classe = {};

    for( String classe in classi ){
      atleti_per_classe[classe] = [];
      for(atleta a in atleti){
        if(a.classid == classe)
          atleti_per_classe[classe]!.add(a);
      }
    }

    return atleti_per_classe;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load organizations');
  }

}


class ClassOrgRoute extends StatefulWidget {
  final String raceid;
  final String org;

  const ClassOrgRoute(this.raceid, this.org, {Key? key}) : super(key: key);

  @override
  _ClassOrgRouteState createState() => _ClassOrgRouteState();
}

class _ClassOrgRouteState extends State<ClassOrgRoute> {
  late Future<Map<String, List<atleta>>> futureRes;
  late DateTime lastRefresh;


  Future<void> _refresh() {

          setState((){

              futureRes = fetchClasses(widget.raceid, widget.org);
          });

          return futureRes;
  }

  @override
  void initState() {
    super.initState();
    futureRes = fetchClasses(widget.raceid, widget.org);
    lastRefresh = DateTime.now().toLocal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Risultati: Filtra per Categoria "),
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(16, 10, 16, 25),
        child: RefreshIndicator(
          color: Colors.blueAccent,
          onRefresh: _refresh,
          child: FutureBuilder<Map<String, List<atleta>>>(
            future: futureRes,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Map<String, List<atleta>> classi_di_atleti = snapshot.data!;
                lastRefresh = DateTime.now().toLocal();


                List<Widget> objs = [
                Text("ultimo aggiornamento:\n ${lastRefresh.toString()}", style: TextStyle(fontSize: 15.0)),
                  ...classi_di_atleti.keys.map((classid) => ExpansionTile(
                    title: Text(classid, style:  TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),),
                    children: <Widget>[
                      Column(
                        children: _buildExpandableContent(classi_di_atleti[classid]),
                      ),
                    ],
                  ))
                ];


                return ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: objs.length,
                              itemBuilder: ((context, index) => objs[index] )
                );

              } else if (snapshot.hasError) {
                return ListView.builder(
                    itemCount: 1,
                    itemBuilder: (context,index) => ConnFailTile("${snapshot.error}")
                );
              }

              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
        ),
      ));
  }
}


_buildExpandableContent(List<atleta>? lista) {
  List<Widget> columnContent = [];

  for (atleta a in lista!) {
    columnContent.add(
        AthleteTile(a)
    );
  }

  return columnContent;
}