import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app/data/database_helper.dart';
import 'package:device_preview/device_preview.dart';

void main() => runApp(
      DevicePreview(
        enabled: !kReleaseMode,
        builder: (context) => MyApp(), // Wrap your app
      ),
    );

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final dbHelper = DatabaseHelper();
  TextEditingController title = TextEditingController();
  TextEditingController desc = TextEditingController();
  List<Map<String, dynamic>> notes = [];
  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  void _fetchNotes() async {
    List<Map<String, dynamic>> fetchedNotes = await dbHelper.queryAllRows();
    setState(() {
      notes = fetchedNotes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return InkWell(
            onLongPress: () async {
              _editNote(note);
            },
            child: ListTile(
              title: Text(note['title']),
              subtitle: Text(note['content']),
              trailing: IconButton(
                onPressed: () async {
                  await dbHelper.delete(note['id']);
                  _fetchNotes();
                },
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _showAddNoteBottomSheet(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _editNote(Map<String, dynamic> note) async {
    TextEditingController titleController =
        TextEditingController(text: note['title']);
    TextEditingController contentController =
        TextEditingController(text: note['content']);

    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Edit Note',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
              SizedBox(height: 10.0),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'Title',
                ),
              ),
              SizedBox(height: 10.0),
              TextField(
                controller: contentController,
                decoration: InputDecoration(
                  hintText: 'Content',
                ),
                maxLines: null,
              ),
              SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();

                  Map<String, dynamic> updatedNote = {
                    'id': note['id'],
                    'title': titleController.text,
                    'content': contentController.text,
                  };
                  await dbHelper.update(updatedNote);
                  _fetchNotes();
                },
                child: Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddNoteBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Add Note',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                SizedBox(height: 10.0),
                TextField(
                  controller: title,
                  decoration: InputDecoration(
                    hintText: 'Title',
                  ),
                ),
                SizedBox(height: 10.0),
                TextField(
                  controller: desc,
                  decoration: InputDecoration(
                    hintText: 'Content',
                  ),
                  maxLines: null,
                ),
                SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await dbHelper
                        .insert({'title': title.text, 'content': desc.text});
                    title.clear();
                    desc.clear();
                    _fetchNotes();
                  },
                  child: Text('Save Note'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}