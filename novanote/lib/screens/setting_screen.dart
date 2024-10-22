import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:novanote/models/note.dart';
import 'package:novanote/util/database_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _prefs = SharedPreferences.getInstance();
  bool _darkMode = false;
  String _defaultSortBy = 'modified_at';
  bool _showThumbnails = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await _prefs;
    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? false;
      _defaultSortBy = prefs.getString('defaultSortBy') ?? 'modified_at';
      _showThumbnails = prefs.getBool('showThumbnails') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await _prefs;
    await prefs.setBool('darkMode', _darkMode);
    await prefs.setString('defaultSortBy', _defaultSortBy);
    await prefs.setBool('showThumbnails', _showThumbnails);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Enable dark theme'),
            value: _darkMode,
            onChanged: (value) {
              setState(() {
                _darkMode = value;
                _saveSettings();
              });
            },
          ),
          ListTile(
            title: const Text('Default Sort Order'),
            subtitle: Text(_defaultSortBy.replaceAll('_', ' ')),
            onTap: () => _showSortOrderDialog(),
          ),
          SwitchListTile(
            title: const Text('Show Thumbnails'),
            subtitle: const Text('Display image thumbnails in note list'),
            value: _showThumbnails,
            onChanged: (value) {
              setState(() {
                _showThumbnails = value;
                _saveSettings();
              });
            },
          ),
          ListTile(
            title: const Text('Export Notes'),
            subtitle: const Text('Export all notes as JSON'),
            onTap: () => _exportNotes(),
          ),
          ListTile(
            title: const Text('Import Notes'),
            subtitle: const Text('Import notes from JSON file'),
            onTap: () => _importNotes(),
          ),
        ],
      ),
    );
  }

  Future<void> _showSortOrderDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Default Sort Order'),
        children: [
          SimpleDialogOption(
            child: const Text('Creation Date'),
            onPressed: () => Navigator.pop(context, 'created_at'),
          ),
          SimpleDialogOption(
            child: const Text('Last Modified'),
            onPressed: () => Navigator.pop(context, 'modified_at'),
          ),
          SimpleDialogOption(
            child: const Text('Title'),
            onPressed: () => Navigator.pop(context, 'title'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _defaultSortBy = result;
        _saveSettings();
      });
    }
  }

  Future<void> _exportNotes() async {
    try {
      final dbHelper = DatabaseHelper();
      final notes = await dbHelper.getNotes();
      final jsonData = notes.map((note) => note.toMap()).toList();

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/notes_backup.json');
      await file.writeAsString(jsonEncode(jsonData));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notes exported successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export notes: $e')),
      );
    }
  }

  Future<void> _importNotes() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final jsonData = await file.readAsString();
        final List<dynamic> notesData = jsonDecode(jsonData);

        final dbHelper = DatabaseHelper();
        for (final noteData in notesData) {
          final note = Note.fromMap(noteData);
          note.id = null; // Reset ID to avoid conflicts
          await dbHelper.insertNote(note);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notes imported successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to import notes: $e')),
      );
    }
  }
}
