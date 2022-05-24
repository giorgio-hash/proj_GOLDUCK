import 'package:flutter/material.dart';

import 'Punto3/components.dart';
import 'Punto3/organizations.dart';
import 'classes_route.dart';
import 'classifiche_route.dart';

class MenuRoute extends StatelessWidget {
  final String raceid;

  const MenuRoute(this.raceid, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    List<Widget> objs = [
      Container(
          margin: EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Text("Griglia di partenza:\n", style: TextStyle(fontSize: 15.0))),
      nextPageButton(ClassesRoute(raceid, "StartList"),"StartList"),
      Container(
          margin: EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Text("classi in gara:\n", style: TextStyle(fontSize: 15.0))),
      nextPageButton(ClassificheRoute(raceid),"Results"),
      Container(
          margin: EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Text("organizzazioni in gara:\n", style: TextStyle(fontSize: 15.0))),
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
