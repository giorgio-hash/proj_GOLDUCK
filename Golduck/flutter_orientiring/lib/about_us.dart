import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './globals.dart';

class about_us extends StatefulWidget {
  const about_us({Key? key}) : super(key: key);

  @override
  about_us_state createState() => about_us_state();
}

class about_us_state extends State<about_us> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
      ),
      body:
      Column(
        children: [
          Text('Stefano Gechele'),
          Text('Giorgio Chirico'), 
          Text('Davide Revrena'), 
          Text('Fabio Assolari'), 
        ],
      ),
      
      // floating botttom 'home'
      floatingActionButton: FloatingActionButton(
        hoverColor: Color.fromARGB(121, 133, 133, 133),
        hoverElevation: 50,
        tooltip: 'Return to Home',
        elevation: 12,
        onPressed: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
        child: const Icon(Icons.home),
      ),
    );
  }
}
