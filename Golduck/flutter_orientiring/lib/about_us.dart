import 'package:flutter/material.dart';

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
      body: Column(
        children: [
          Container(
            constraints: const BoxConstraints(
                minHeight: 100, minWidth: double.infinity, maxHeight: 400),
            child: Image.network(
              'https://portalebambini.it/wp-content/uploads/2015/10/orienteering1.jpg',
              fit: BoxFit.fitWidth,
            ),
          ),
          const Text('ORIENTEERING',
              style: TextStyle(height: 2, fontSize: 30),
              textAlign: TextAlign.center),
          const Text(
            'Stefano Gechele',
            textAlign: TextAlign.center,
          ),
          const Text('Giorgio Chirico', textAlign: TextAlign.center),
          const Text('Davide Revrena', textAlign: TextAlign.center),
          const Text('Fabio Assolari', textAlign: TextAlign.center),
        ],
      ),

      // floating botttom 'home'
      floatingActionButton: FloatingActionButton(
        hoverColor: const Color.fromARGB(121, 133, 133, 133),
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
