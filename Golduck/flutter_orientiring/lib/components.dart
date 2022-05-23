

import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';

class nextPageButton extends StatelessWidget{

  final String title;
  final Widget nextPage;

  const nextPageButton(this.nextPage,this.title);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        margin: EdgeInsets.fromLTRB(30, 2, 30, 2 ),
        child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            nextPage,
                      ),
                    );
                  },
                  child: Text(title),
                )
    );
  }
}


class AZItem extends ISuspensionBean{
  final String title;
  final String tag;

  AZItem(this.title,this.tag);

  @override
  String getSuspensionTag()=>tag;
}


class ConnFailTile extends StatelessWidget {

  String _msg;

ConnFailTile(this._msg);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
        decoration: BoxDecoration(border: Border.all(color: Colors.black26),
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: ListTile(
          title: Text("Errore di connessione", style: TextStyle(fontSize: 20.0)),
          subtitle: Text(
              "Scorri verso il basso per ricaricare la pagina.\n\n ${_msg}",
              style: TextStyle(fontSize: 15.0)),
          leading: Icon(Icons.cloud_off_sharp),
        ));
  }
}
