import 'package:flutter/material.dart';

import 'Punto3/components.dart';
import 'Punto3/organizations.dart';
import 'classes_route.dart';
import 'classifiche_route.dart';

class MenuRoute extends StatelessWidget {
  final String raceid;
  final String racename;

  const MenuRoute(this.raceid,this.racename, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    List<Widget> objs = [
      Container(
          margin: EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Text("risultati gara: ${racename}\n", style: TextStyle(fontSize: 15.0))),
      nextPageButton(ClassesRoute(raceid, "StartList"),"Griglia di partenza"),
      nextPageButton(ClassificheRoute(raceid),"filtra per classe"),
      nextPageButton(OrganisationsRoute(raceid),"Organizzationi")
    ];


    return Scaffold(
        appBar: AppBar(
          title: const Text('Available races'),
        ),
        body: ListView.builder(
            itemCount: objs.length,
            itemBuilder: (c,i) => objs[i]
        ));
  }
}
