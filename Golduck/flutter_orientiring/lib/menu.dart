import 'package:flutter/material.dart';

import 'classes_route.dart';

class MenuRoute extends StatelessWidget {
  final String raceid;

  const MenuRoute(this.raceid, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Available races'),
        ),
        body: Column(children: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClassesRoute(raceid, "StartList"),
                ),
              );
            },
            child: const Text("StartList"),
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClassesRoute(raceid, "Results"),
                  ),
                );
              },
              child: Text("Results"))
        ]));
  }
}
