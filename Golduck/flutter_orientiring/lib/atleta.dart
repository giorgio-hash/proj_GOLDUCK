import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class atleta {
  final String name;
  final String surname;
  final String org;
  final String position;
  final String time;
  final String classid;
  final String status;

  atleta(this.name, this.surname, this.org, this.position, this.time,
      this.classid, this.status);

  @override
  String toString() {
    return "nome: $name\ncognome: $surname\nposizione: $position\ntempo: ${time == "N/A" ? time : (Duration(seconds: int.parse(time)))}\nclasse: $classid";
  }

  String get risultati {
    return "posizione: $position\ntempo: ${time == "N/A" ? time : (Duration(seconds: int.parse(time)))}\nstatus: $status";
  }
}

class atletaStart {
  final String name;
  final String surname;
  final String org;
  final String time;
  final String clazz;

  atletaStart(this.name, this.surname, this.org, this.time, this.clazz);

  String get risultati {
    DateTime date = DateTime.parse(time);
    DateFormat format = DateFormat("HH:mm:ss");
    return "\ntempo: ${time == "N/A" ? time : format.format(date)}";
  }
}

class AthleteTile extends StatelessWidget {
  final atleta _a;
  final String _infoExtra;

  AthleteTile(this._a, [this._infoExtra = ""]);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.fromLTRB(30, 10, 30, 10),
        decoration: const BoxDecoration(
            border:
                Border(bottom: BorderSide(width: 3, color: Colors.black26))),
        child: ListTile(
          title: Text("${_a.surname} ${_a.name}",
              style: const TextStyle(fontSize: 20.0)),
          subtitle: Text("${_a.risultati}\n$_infoExtra",
              style: const TextStyle(fontSize: 15.0)),
          leading: const Icon(Icons.run_circle_outlined),
        ));
  }
}

class StartTile extends StatelessWidget {
  final atletaStart _a;
  final String _infoExtra;

  StartTile(this._a, [this._infoExtra = ""]);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.fromLTRB(30, 10, 30, 10),
        decoration: const BoxDecoration(
            border:
                Border(bottom: BorderSide(width: 3, color: Colors.black26))),
        child: ListTile(
          title: Text("${_a.surname} ${_a.name}",
              style: const TextStyle(fontSize: 20.0)),
          subtitle: Text("${_a.risultati}\n$_infoExtra",
              style: const TextStyle(fontSize: 15.0)),
          leading: const Icon(Icons.run_circle_outlined),
        ));
  }
}
