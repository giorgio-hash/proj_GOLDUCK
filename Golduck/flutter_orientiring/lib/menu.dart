import 'package:flutter/material.dart';

import 'classes_route.dart';


class MenuRoute extends StatelessWidget {
  final String raceid;

  const MenuRoute(this.raceid, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Choose an option'),
        ),
        body: Container(
          padding: const EdgeInsets.fromLTRB(5, 15, 5, 15),
          child: Stack(
            children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Are you looking For StartList or Live Results?',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),),
                  ]
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 50, 0, 50),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
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
                          child: const Text("Results"))
                    ]),
              )
            ],
          ),
        )

    );
  }
}
