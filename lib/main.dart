import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

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
  List<Nota> notas = [];

  void _abrirDetalleNota(Nota nota) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalleNotaScreen(nota: nota),
      ),
    );

    if (resultado != null && resultado is Map<String, dynamic>) {
      if (resultado.containsKey('accion') &&
          resultado['accion'] == 'eliminar') {
        setState(() {
          notas.remove(nota);
        });
      } else if (resultado.containsKey('accion') &&
          resultado['accion'] == 'editar') {
        final nuevaNota = resultado['nuevaNota'];
        final index = notas.indexOf(nota);
        if (index != -1) {
          setState(() {
            notas[index] = nuevaNota;
          });
        }
      }
    }
  }

  Future<void> _agregarNota() async {
    final nota = await Navigator.push<Nota>(
      context,
      MaterialPageRoute(
        builder: (context) => AgregarNotaScreen(),
      ),
    );

    if (nota != null) {
      setState(() {
        notas.add(nota);
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
          : ListView.builder(
              itemCount: notas.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(notas[index].titulo),
                  onTap: () => _abrirDetalleNota(notas[index]),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarNota,
        child: Icon(Icons.add),
      ),
    );
  }
}

class Nota {
  String titulo;
  String contenido;
  List<File> imagenes;

  Nota({required this.titulo, required this.contenido, required this.imagenes});
}

class AgregarNotaScreen extends StatefulWidget {
  final Nota? nota;

  AgregarNotaScreen({this.nota});

  @override
  _AgregarNotaScreenState createState() => _AgregarNotaScreenState();
}

class _AgregarNotaScreenState extends State<AgregarNotaScreen> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _contenidoController = TextEditingController();

  List<File> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.nota != null) {
      _tituloController.text = widget.nota!.titulo;
      _contenidoController.text = widget.nota!.contenido;
      _selectedImages = widget.nota!.imagenes;
    }
  }

  void _guardarNota() {
    final titulo = _tituloController.text;
    final contenido = _contenidoController.text;
    final nuevaNota =
        Nota(titulo: titulo, contenido: contenido, imagenes: _selectedImages);

    Navigator.of(context).pop(nuevaNota);
  }

  void _cancelar() {
    Navigator.of(context).pop();
  }

  void _agregarImagen() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
        _contenidoController.text += '\n![Imagen](${pickedFile.path})';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Nota'),
        actions: <Widget>[
          TextButton(
            onPressed: _guardarNota,
            child: Text(
              'Guardar',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          TextButton(
            onPressed: _cancelar,
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _tituloController,
              decoration: InputDecoration(
                hintText: 'Título de la nota',
              ),
            ),
            TextField(
              controller: _contenidoController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Escribe tu nota...',
              ),
            ),
            IconButton(
              icon: Icon(Icons.image),
              onPressed: _agregarImagen,
            ),
            if (_selectedImages.isNotEmpty)
              Column(
                children: _selectedImages
                    .map((image) => Image.file(image, height: 200))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class DetalleNotaScreen extends StatelessWidget {
  final Nota nota;

  const DetalleNotaScreen({required this.nota});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de Nota'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              final nuevaNota = await Navigator.push<Nota>(
                context,
                MaterialPageRoute(
                  builder: (context) => AgregarNotaScreen(nota: nota),
                ),
              );

              if (nuevaNota != null) {
                Navigator.pop(
                    context, {'accion': 'editar', 'nuevaNota': nuevaNota});
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              Navigator.pop(context, {'accion': 'eliminar'});
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(nota.titulo,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Column(
              children: _parseMarkdownWithImages(nota.contenido),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _parseMarkdownWithImages(String markdownContent) {
    final List<Widget> widgets = [];
    final List<String> lines = markdownContent.split('\n');
    for (String line in lines) {
      if (line.contains('![Imagen]')) {
        final imageUrl = line.substring(
            line.indexOf('(') + 1, line.indexOf(')', line.indexOf('(')));
        widgets.add(
          Image.file(
            File(imageUrl),
            height: 200, // Ajusta aquí el tamaño deseado
          ),
        );
      } else {
        widgets.add(MarkdownBody(data: line));
      }
    }
    return widgets;
  }
}
