import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/database_helper.dart';

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
  Color randomColor() {
    final random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Notes'),
      ),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: ListTile(
              tileColor: randomColor(),
              title: Text(note['title']),
              subtitle: Text(note['content']),
              trailing: FittedBox(
                child: Column(
                  children: [
                    IconButton(
                      onPressed: () async {
                        _editNote(note);
                      },
                      icon: Icon(
                        Icons.edit,
                        color: Colors.green,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await dbHelper.delete(note['id']);
                        _fetchNotes();
                      },
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ),
                  ],
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