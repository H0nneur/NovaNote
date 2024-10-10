import 'package:flutter/material.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({super.key});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  // Controllers for the text fields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // List of priorities
  final List<String> _priorities = ['Low', 'Medium', 'High'];
  String? _selectedPriority = 'Medium'; // Default priority

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
          ]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text(
                  'Priority: ',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _selectedPriority,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPriority = newValue;
                    });
                  },
                  items:
                      _priorities.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Scrollbar(
                thumbVisibility: false,
                child: SingleChildScrollView(
                  child: TextField(
                    controller: _noteController,
                    minLines: 8,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      alignLabelWithHint: true,
                      labelText: 'Note',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
