import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import './globals.dart';

Future<List<dynamic>> fetchStart(String raceid, String clazz) async {
  final response = await http.get(Uri.parse('$apiUrl/list_start?id=$raceid&class=$clazz'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    //fetch _JsonMap
    return List<dynamic>.from(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Start list not found');
  }
}

class StartRoute extends StatefulWidget {
  final String raceid,clazz;
  const StartRoute(this.raceid, this.clazz, {Key? key}) : super(key: key);

  @override
  _StartRouteState createState() => _StartRouteState();
}

class _StartRouteState extends State<StartRoute> {
  late Future<List<dynamic>> futureStarts;

  @override
  void initState() {
    super.initState();
    futureStarts = fetchStart(widget.raceid, widget.clazz);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start'),
      ),
      body: Center(
        child: FutureBuilder<List<dynamic>>(
          future: futureStarts,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List starts = snapshot.data!;
              return ListView.builder(
                  itemCount: starts.length,
                  itemBuilder: (_, index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: const Color(0xff4f92da),
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.15),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ]
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${snapshot.data![index]["name"]} ${snapshot.data![index]["surname"]}",
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        Text(
                            "Organisation: ${snapshot.data![index]["org"]}",
                            style: const TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 5.0, 0, 5.0),
                          child: Builder(
                            builder: (context) {
                              //Transform ISO date to more readable
                              DateTime date = DateTime.parse(snapshot.data![index]["time"]);
                              DateFormat dateFormat = DateFormat("HH:mm:ss");
                              return Text(
                                "Time: ${dateFormat.format(date)}",
                                style: const TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline,

                                ),
                              );
                            }
                          ),
                        ),
                      ],
                    ),
                  ),
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }

            // By default, show a loading spinner.
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
