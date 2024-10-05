import 'package:flutter/material.dart';
import 'package:novanote/constant_widgets.dart';
import 'package:novanote/edit_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<String> notes = [
    "This is a test",
    "This is also a test",
    "This is a test as well"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: novaNoteAppBar,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (contect) => const EditScreen()));
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: notes.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                title: Text(
                  notes[index],
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  print('Tapped on note: ${notes[index]}');
                },
              ),
            );
          }),
    );
  }
}
