import 'package:flutter/material.dart';

import 'ClassOrgRoute.dart';
import 'allathlroute.dart';
import 'components.dart';

class ResultsRoute extends StatefulWidget {
  final String raceid;
  final String org;
  const ResultsRoute(this.raceid, this.org);

  @override
  _ResultsRouteState createState() => _ResultsRouteState();
}

class _ResultsRouteState extends State<ResultsRoute> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> buttons = [
      Container(
          margin: const EdgeInsets.fromLTRB(16, 10, 16, 25),
          child: Text(
              "organizzazione: ${widget.org}",
              style: const TextStyle(fontSize: 15.0))),
      nextPageButton(
          allAthlRoute(widget.raceid, widget.org), "tutti gli atleti"),
      nextPageButton(
          ClassOrgRoute(widget.raceid, widget.org), "filtra per classe")
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("risultati "),
      ),
      body: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: buttons.length,
          itemBuilder: ((context, index) => buttons[index])),
      floatingActionButton: FloatingActionButton(
        hoverColor: Color.fromARGB(121, 133, 133, 133),
        hoverElevation: 50,
        tooltip: 'Return to Home',
        elevation: 12,
        onPressed: () {
          Navigator.pop(context); //return
          Navigator.pop(context); //return
          Navigator.pop(context); //return
        },
        child: const Icon(Icons.home),
      ),
    );
  }
}
