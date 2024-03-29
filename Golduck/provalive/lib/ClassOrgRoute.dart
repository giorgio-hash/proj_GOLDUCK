
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:json_diff/json_diff.dart';

import 'atleta.dart';
import 'components.dart';
import 'globals.dart';


Map<dynamic, dynamic> json1 = {};
Map<dynamic, dynamic> json2 = {};
List<String> differenze = [];
bool online = false;


Future<Map<String, List<atleta>>> fetchClasses(String raceid, String org) async {

  final response = await http.get(Uri.parse('$apiUrl/test?id=$raceid&organisation=$org'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.

    var fetched = (jsonDecode(Utf8Decoder().convert(response.bodyBytes)) as List<dynamic>);
    if(!online){

      online = true;

      differenze.clear();
      json2.clear();
      for(var j in fetched){
        json1[j["name"]+j["surname"]] =  j;
      }

      print("risultati: " + json1.toString());

    }else{

      for(var j in fetched){
        json2[j["name"]+j["surname"]] = j;
      }

      differenze.clear();

      for(Object key in json2.keys){

        if(json1.keys.contains(key) ){
          DiffNode diff = (JsonDiffer.fromJson(json2[key], json1[key])).diff();
          if(diff.changed.keys.length > 0)
            differenze.add(key.toString());
        }
        else
          differenze.add(key.toString());

      }

      json1 = Map<dynamic, dynamic>.from(json2);

      print("\n\ndifferenze: " + differenze.toString());

    }


    List<atleta> atleti = List<atleta>.from((fetched).map((e) => atleta(e["name"],e["surname"],e["org"],e["position"],e["time"],e["class"])));
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
  late Timer timer;


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

    if(mounted) {
      timer = Timer.periodic(Duration(seconds: 10), (timer) {
        print("\n\nazione!\n\n");
        if(online)
          _refresh();
      });
    }

  }

  @override
  void dispose(){
    super.dispose();
    timer.cancel();
  }

  @override
  void deactivate(){
    super.deactivate();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {

      return WillPopScope(
      onWillPop: ()async{differenze.clear();timer.cancel();print("torna alla page precedente");return true;},
          child: Scaffold(
      appBar: AppBar(
        title: const Text("risultati: filtra per classe "),
      ),
      body: Center(
      child:RefreshIndicator(
        color: Colors.blueAccent,
        onRefresh: _refresh,
        child: FutureBuilder<Map<String, List<atleta>>>(
          future: futureRes,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Map<String, List<atleta>> classi_di_atleti = snapshot.data!;
              lastRefresh = DateTime.now().toLocal();


              List<Widget> objs = [
              Container(
                  margin: EdgeInsets.fromLTRB(16, 10, 16, 25),
                  child: Text("ultimo aggiornamento:\n ${lastRefresh.toString()}", style: TextStyle(fontSize: 15.0))),
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

              online = false;

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
    )
      )
      );
  }
}


_buildExpandableContent(List<atleta>? lista) {
  List<Widget> columnContent = [];

  for (atleta a in lista!)
    columnContent.add(
      differenze.contains(a.name + a.surname)? Container(color: Colors.red.shade100,child: AthleteTile(a)) : AthleteTile(a)
    );

  return columnContent;
}