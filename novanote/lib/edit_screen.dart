import 'package:flutter/material.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({super.key});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("Edit note"),
            titleTextStyle: const TextStyle(color: Colors.white, fontSize: 22),
            backgroundColor: Colors.blue.shade900,
            actions: [
          IconButton(
              onPressed: () {
                //TODO: Save the note
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.save_rounded,
                color: Colors.white,
              ))
        ]));
  }
}
