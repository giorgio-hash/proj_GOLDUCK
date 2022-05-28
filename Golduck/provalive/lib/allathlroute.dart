
import'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:azlistview/azlistview.dart';
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


Future<List<atleta>> fetchResults(String raceid, String org) async {
  final response = await http.get(Uri.parse('$apiUrl/results_filter?id=$raceid&organisation=$org'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.

    var fetched = (jsonDecode(Utf8Decoder().convert(response.bodyBytes)) as List<dynamic>);
    if(!online){

      online = true;

      differenze.clear();
      json2.clear();
      for(var j in fetched){
        json1[j["numero"]] =  j;
      }

      print("risultati: " + json1.toString());

    }else{

      for(var j in fetched){
        json2[j["numero"]] = j;
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



    List<atleta> atleti = List<atleta>.from((jsonDecode(Utf8Decoder().convert(response.bodyBytes)) as List<dynamic>).map((e) => atleta(e["name"],e["surname"],e["org"],e["position"],e["time"],e["class"])));
    atleti.sort((a,b) => a.surname.compareTo(b.surname) == 0? a.name.compareTo(b.name) : a.surname.compareTo(b.surname) );

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
  late Timer timer;

  Future<void> _refresh(){

    setState((){

        futureRes = fetchResults(widget.raceid, widget.org);

      });

    return futureRes;
  }

  @override
  void initState() {
    super.initState();
    futureRes = fetchResults(widget.raceid, widget.org);

    if(mounted) {
      timer = Timer.periodic(Duration(seconds: 30), (timer) {
        print("\n\nazione!\n\n");
        if(online)
          _refresh();
      });
    }


  }

  List<AZItem> initList(List<atleta>  atl){
    return atl.map((a) => AZItem(a.surname+a.name,a.surname.characters.first.toUpperCase())).toList();
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
        title: Text("risultati: tutti gli atleti")
      ),
      body:  Center(
      child:RefreshIndicator(
        color: Colors.blueAccent,
        onRefresh: _refresh,
         child: FutureBuilder<List<atleta>>(
           future: futureRes,
           builder: (context, snapshot) {
             if (snapshot.hasData) {
               List<atleta> atl = snapshot.data!;
               List<AZItem> items = initList(atl);
               //aggiungi header
               items.insert(0, AZItem("header","_"));

               DateTime lastRefresh = DateTime.now().toLocal();

               return AzListView(
                   data: items,
                   itemCount: items.length,
                   itemBuilder: (context, index){
                     return index==0?
                     Container(
                         margin: EdgeInsets.fromLTRB(16, 10, 16, 25),
                         child: Text("ultimo aggiornamento: \n ${lastRefresh.toString()}", style: TextStyle(fontSize: 15.0)))
                         : AthleteTile(atl[index-1],"classe: "+ atl[index-1].classid);
                   }
               );
             } else if (snapshot.hasError) {
               return ListView.builder(
                   itemCount: 1,
                   itemBuilder: (context,index) => ConnFailTile("${snapshot.error}")
               );
             }

             // By default, show a loading spinner.
             return CircularProgressIndicator();
           },
         ),
        )
    )));
  }
}


/*List<Widget> objs = [
                 Container(
                     margin: EdgeInsets.fromLTRB(16, 10, 16, 25),
                     child: Text("ultimo aggiornamento:\n ${lastRefresh.toString()}", style: TextStyle(fontSize: 15.0))),
                 ...atl.map((a) => AthleteTile(a,"classe: "+ a.classid))
               ];*/