import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_orientiring/start_route.dart';

import 'ClassOrgRoute.dart';
import 'allathlroute.dart';
import 'atleta.dart';
import 'components.dart';



class ResultsRoute extends StatefulWidget {
  final String raceid;
  final String org;
  const ResultsRoute(this.raceid,this.org);

  @override
  _ResultsRouteState createState() => _ResultsRouteState();
}

class _ResultsRouteState extends State<ResultsRoute> {


  @override
  void initState() {
    super.initState();
    print("caricamento ${widget.org}");
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> buttons = [
      nextPageButton(StartRoute(widget.raceid, widget.org),"Griglia di Partenza"),
      nextPageButton(allAthlRoute(widget.raceid, widget.org),"Classifica Generale"),
      nextPageButton(ClassOrgRoute(widget.raceid, widget.org),"Filtra per Categoria")
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Risultati "),
      ),
      body: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: buttons.length,
                  itemBuilder: ((context, index) => buttons[index] )
              )
    );
  }
}




