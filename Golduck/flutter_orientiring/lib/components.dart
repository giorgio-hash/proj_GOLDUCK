import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';

class nextPageButton extends StatelessWidget {
  final String title;
  final Widget nextPage;

  const nextPageButton(this.nextPage, this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.fromLTRB(30, 5, 30, 5),
        child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => nextPage,
                ),
              );
            },
            child: Container(
                padding: const EdgeInsets.all(8.0),
                child: Text(title, textAlign: TextAlign.center))));
  }
}

class AZItem extends ISuspensionBean {
  final String title;
  final String tag;

  AZItem(this.title, this.tag);

  @override
  String getSuspensionTag() => tag;
}

class ConnFailTile extends StatelessWidget {
  String _msg;

  ConnFailTile(this._msg);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.fromLTRB(30, 10, 30, 10),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black26),
            borderRadius: const BorderRadius.all(Radius.circular(20))),
        child: ListTile(
          title: const Text("Errore di conessione",
              style: TextStyle(fontSize: 20.0)),
          subtitle: Text(
              "scorri verso il basso per ricaricare la pagina\n\n $_msg",
              style: const TextStyle(fontSize: 15.0)),
          leading: const Icon(Icons.cloud_off_sharp),
        ));
  }
}
