import 'package:flutter/material.dart';
import 'package:novanote/screens/edit_screen.dart';

class NoteDetailScreen extends StatelessWidget {
  const NoteDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Note"),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 22),
        backgroundColor: Colors.blue.shade900,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (contect) => const EditScreen()));
              },
              icon: const Icon(Icons.edit, color: Colors.white)),
          IconButton(
              onPressed: () {
                //TODO: delete the note
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.white,
              ))
        ],
      ),
    );
  }
}
