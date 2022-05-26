import 'dart:async';
import 'dart:convert';

import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_orientiring/Punto3/results.dart';
import 'package:http/http.dart' as http;

import '../globals.dart';
import 'components.dart';


Future<List<String>> fetchOrgs(String raceid) async {
  final response = await http.get(Uri.parse('$apiUrl/list_organizations?id=$raceid'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    List<String> orgs = List<String>.from(jsonDecode(Utf8Decoder().convert(response.bodyBytes)));
    orgs.sort();
    return orgs;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load classes');
  }
}

class OrganisationsRoute extends StatefulWidget {
  final String raceid;
  const OrganisationsRoute(this.raceid, {Key? key}) : super(key: key);

  @override
  _OrganisationsRouteState createState() => _OrganisationsRouteState();
}

class _OrganisationsRouteState extends State<OrganisationsRoute> {
  late Future<List<String>> futureOrgs;

  @override
  void initState() {
    super.initState();

    futureOrgs = fetchOrgs(widget.raceid);
  }

  Future<void> _refresh(){
    setState((){

      futureOrgs = fetchOrgs(widget.raceid);

    });

    return futureOrgs;
  }


  List<AZItem> initList(List<String>  orgs){
    return orgs.map((o) => AZItem(o,o.characters.first.toUpperCase())).toList();
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizations'),
      ),
      body: Center(
        child: RefreshIndicator(
        color: Colors.blueAccent,
        onRefresh: _refresh,
        child: FutureBuilder<List<String>>(
          future: futureOrgs,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<String> orgs = snapshot.data!;
              List<AZItem> items = initList(orgs);
              //aggiunta header
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
                      : nextPageButton(ResultsRoute(widget.raceid,orgs[index-1]),orgs[index-1]);
                }
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
    )
    );
  }
}