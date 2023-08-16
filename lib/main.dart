import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(NotaApp());
}

class NotaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Notas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NotaPage(),
    );
  }
}

class NotaPage extends StatefulWidget {
  @override
  _NotaPageState createState() => _NotaPageState();
}

class _NotaPageState extends State<NotaPage> {
  List<String> notas = [];
  File? imagen;

  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _agregarNota() async {
    final nota = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Agregar Nota'),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(hintText: 'Ingrese su nota'),
            onSubmitted: (String value) {
              Navigator.of(context).pop(value);
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Guardar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    if (nota != null) {
      setState(() {
        notas.add(nota);
      });
    }
  }

  Future<void> _agregarImagen() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imagen = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App de Notas'),
      ),
      body: notas.isEmpty
          ? Center(
              child: Text('No hay notas'),
            )
          : ListView(
              children: <Widget>[
                if (imagen != null)
                  Image.file(
                    imagen!,
                    height: 200,
                  ),
                ListTile(
                  title: Text('Imagen'),
                  onTap: _agregarImagen,
                ),
                Divider(),
                ...notas.map((nota) => ListTile(title: Text(nota))),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarNota,
        child: Icon(Icons.add),
      ),
    );
  }
}
