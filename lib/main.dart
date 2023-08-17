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
  List<Etiqueta> etiquetas = [];

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
        builder: (context) => AgregarNotaScreen(etiquetas: etiquetas),
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
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: Text('Etiquetas'),
              onTap: () => _abrirEtiquetas(),
            ),
          ],
        ),
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

  void _abrirEtiquetas() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EtiquetasScreen(etiquetas: etiquetas),
      ),
    );

    if (resultado != null && resultado is List<Etiqueta>) {
      setState(() {
        etiquetas = resultado;
      });
    }
  }
}

class Nota {
  String titulo;
  String contenido;
  List<File> imagenes;
  List<Etiqueta> etiquetas;

  Nota({
    required this.titulo,
    required this.contenido,
    required this.imagenes,
    required this.etiquetas,
  });
}

class Etiqueta {
  String nombre;

  Etiqueta({required this.nombre});
}

//Desde aquí

class AgregarNotaScreen extends StatefulWidget {
  final List<Etiqueta> etiquetas;
  final Nota? nota;

  AgregarNotaScreen({required this.etiquetas, this.nota});

  @override
  _AgregarNotaScreenState createState() => _AgregarNotaScreenState();
}

//Dede aquí
class _AgregarNotaScreenState extends State<AgregarNotaScreen> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _contenidoController = TextEditingController();
  List<File> _selectedImages = [];
  List<Etiqueta> _selectedEtiquetas = [];

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.nota != null) {
      _tituloController.text = widget.nota!.titulo;
      _contenidoController.text = widget.nota!.contenido;
      _selectedImages = widget.nota!.imagenes;
      _selectedEtiquetas = widget.nota!.etiquetas;
    }
  }

  void _guardarNota() {
    final titulo = _tituloController.text;
    final contenido = _contenidoController.text;
    final nuevaNota = Nota(
      titulo: titulo,
      contenido: contenido,
      imagenes: _selectedImages,
      etiquetas: _selectedEtiquetas,
    );

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

  void _eliminarImagen(int index) {
    setState(() {
      final imageToRemove = _selectedImages[index];
      _selectedImages.removeAt(index);
      _contenidoController.text = _contenidoController.text.replaceAll(
        '\n![Imagen](${imageToRemove.path})',
        '',
      );
    });
  }
//desde aquí

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
            Wrap(
              spacing: 8,
              children: widget.etiquetas.map((etiqueta) {
                return ChoiceChip(
                  label: Text(etiqueta.nombre),
                  selected: _selectedEtiquetas.contains(etiqueta),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedEtiquetas.add(etiqueta);
                      } else {
                        _selectedEtiquetas.remove(etiqueta);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            IconButton(
              icon: Icon(Icons.image),
              onPressed: _agregarImagen,
            ),
            if (_selectedImages.isNotEmpty)
              Column(
                children: List.generate(_selectedImages.length, (index) {
                  return Row(
                    children: [
                      Expanded(
                        child: Image.file(_selectedImages[index], height: 100),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _eliminarImagen(index),
                      ),
                    ],
                  );
                }),
              ),
          ],
        ),
      ),
    );
  }
}

//hasta aquí

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
                  builder: (context) =>
                      AgregarNotaScreen(etiquetas: nota.etiquetas, nota: nota),
                ),
              );

              if (nuevaNota != null) {
                Navigator.pop(
                  context,
                  {'accion': 'editar', 'nuevaNota': nuevaNota},
                );
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
            Text(
              nota.titulo,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: nota.etiquetas.map((etiqueta) {
                return Chip(label: Text(etiqueta.nombre));
              }).toList(),
            ),
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
          line.indexOf('(') + 1,
          line.indexOf(')', line.indexOf('(')),
        );
        widgets.add(
          Image.file(
            File(imageUrl),
            height: 200,
          ),
        );
      } else {
        widgets.add(MarkdownBody(data: line));
      }
    }
    return widgets;
  }
}

class EtiquetasScreen extends StatefulWidget {
  final List<Etiqueta> etiquetas;

  EtiquetasScreen({required this.etiquetas});

  @override
  _EtiquetasScreenState createState() => _EtiquetasScreenState();
}

class _EtiquetasScreenState extends State<EtiquetasScreen> {
  TextEditingController _etiquetaController = TextEditingController();
  List<Etiqueta> _etiquetas = [];

  @override
  void initState() {
    super.initState();
    _etiquetas = widget.etiquetas;
  }

  void _agregarEtiqueta() {
    final nuevaEtiqueta = _etiquetaController.text;
    if (nuevaEtiqueta.isNotEmpty) {
      setState(() {
        _etiquetas.add(Etiqueta(nombre: nuevaEtiqueta));
        _etiquetaController.clear();
      });
    }
  }

  void _editarEtiqueta(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Etiqueta'),
          content: TextField(
            controller: _etiquetaController,
            decoration: InputDecoration(hintText: 'Nombre de la etiqueta'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final nuevoNombre = _etiquetaController.text;
                setState(() {
                  _etiquetas[index] = Etiqueta(nombre: nuevoNombre);
                });
                Navigator.pop(context);
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _eliminarEtiqueta(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar Etiqueta'),
          content: Text('¿Estás seguro de que deseas eliminar esta etiqueta?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _etiquetas.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Etiquetas'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _etiquetaController,
                    decoration: InputDecoration(
                      hintText: 'Nueva etiqueta',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _agregarEtiqueta,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _etiquetas.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_etiquetas[index].nombre),
                  onTap: () => _editarEtiqueta(index),
                  onLongPress: () => _eliminarEtiqueta(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
