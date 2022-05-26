import 'package:flutter/material.dart';
import 'package:flutter_orientiring/start_route.dart';

<<<<<<< Updated upstream
import 'classes_route.dart';

=======
import 'Punto3/components.dart';
import 'Punto3/organizations.dart';
import 'classifiche_route.dart';
>>>>>>> Stashed changes

class MenuRoute extends StatelessWidget {
  final String raceid;

  const MenuRoute(this.raceid, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
<<<<<<< Updated upstream
=======

    List<Widget> objs = [
      Container(
          margin: EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Text("Griglia di partenza:\n", style: TextStyle(fontSize: 15.0))),
      nextPageButton(StartRoute(raceid),"StartList"),
      Container(
          margin: EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Text("classi in gara:\n", style: TextStyle(fontSize: 15.0))),
      nextPageButton(ClassificheRoute(raceid),"Results"),
      Container(
          margin: EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Text("organizzazioni in gara:\n", style: TextStyle(fontSize: 15.0))),
      nextPageButton(OrganisationsRoute(raceid),"Organizzationi")
    ];


>>>>>>> Stashed changes
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
