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
            itemBuilder: ((context, index) => buttons[index])));
  }
}
