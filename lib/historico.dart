import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:flutter/widgets.dart';

import "resultado.dart";

class Historico extends StatefulWidget {
  @override
  _HistoricoState createState() => _HistoricoState();
}

class _HistoricoState extends State<Historico> {
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Histórico")),
      body: StreamBuilder(
          stream: Firestore.instance
              .collection("resultados")
              .orderBy("timestamp", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (!snapshot.hasData || snapshot.data.documents.length == 0) {
              return Center(
                child: Text(
                  "Nenhum resultado.",
                  style: TextStyle(fontSize: 18.0),
                ),
              );
            }
            return ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                itemCount: snapshot.data.documents.length,
                itemBuilder: (_, int index) {
                  return _buildItem(snapshot.data.documents[index]);
                });
          }),
    );
  }

  Widget _buildItem(DocumentSnapshot document) {
    String documentId = document.reference.documentID;
    Resultado r = Resultado.fromFirebase(document.data);
    DateTime dt = r.createdAt;
    return Padding(
      padding: EdgeInsets.only(top: 10.0, right: 10.0, left: 10.0),
      child: Dismissible(
        direction: DismissDirection.startToEnd,
        resizeDuration: Duration(milliseconds: 200),
        key: ObjectKey(r),
        onDismissed: (DismissDirection _) =>
            _deleteResultado(context, documentId, r),
        background: Card(
          color: Colors.red,
          child: Container(
            padding: EdgeInsets.only(left: 28.0),
            alignment: AlignmentDirectional.centerStart,
            child: Icon(Icons.delete_forever, color: Colors.white),
          ),
        ),
        child: Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(r.icon, size: 40.0),
                title: Text(r.categoriaDescription),
                subtitle: Text(
                    "${dt.day.toString().padLeft(2, "0")}/${dt.month.toString().padLeft(2, "0")}/${dt.year}"
                    " ${dt.hour.toString().padLeft(2, "0")}:${dt.minute.toString().padLeft(2, "0")}"),
              ),
              ButtonBar(
                alignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ActionChip(
                    avatar: Text("IMC",
                        style: TextStyle(
                            fontSize: 12.0, fontWeight: FontWeight.bold)),
                    label: Text("${r.imc.toStringAsFixed(2)}"),
                    onPressed: () {},
                  ),
                  ActionChip(
                    avatar: Icon(Icons.crop_square_sharp, size: 20.0),
                    label: Text("${r.peso.toStringAsFixed(1)} Kg"),
                    onPressed: () {},
                  ),
                  ActionChip(
                    avatar: Icon(Icons.accessibility),
                    label: Text("${r.altura.toStringAsFixed(2)} m"),
                    onPressed: () {},
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _deleteResultado(BuildContext context, String documentId, Resultado r) {
    Firestore.instance
        .collection("resultados")
        .document(documentId)
        .delete()
        .then((_) => _showUndoSnackbar(r));
  }

  void _showUndoSnackbar(Resultado r) {
    var s = Scaffold.of(context);
    s.removeCurrentSnackBar();
    s.showSnackBar(SnackBar(
      content: Text("Resultado removido."),
      action: SnackBarAction(
        label: "DESFAZER",
        onPressed: () {
          Firestore.instance.collection("resultados").add(r.toFirebase());
        },
      ),
    ));
  }
}
