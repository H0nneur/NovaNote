import 'package:flutter/material.dart';
import 'package:novanote/models/note.dart';
import 'package:novanote/util/database_helper.dart';

class NoteListScreen extends StatefulWidget {
  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Note> _notes = [];
  String _searchQuery = '';
  String _sortBy = 'modified_at';
  bool _ascending = false;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await _dbHelper.getNotes(
      search: _searchQuery.isEmpty ? null : _searchQuery,
      sortBy: _sortBy,
      ascending: _ascending,
    );
    setState(() {
      _notes = notes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NovaNote'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _loadNotes();
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return ListTile(
                  leading: Icon(
                    note.isLocked ? Icons.lock : Icons.note,
                    color: note.isImportant ? Colors.red : null,
                  ),
                  title: Text(note.title),
                  subtitle: Text(
                    note.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: note.isFavorite
                      ? const Icon(Icons.star, color: Colors.yellow)
                      : null,
                  onTap: () => _openNote(note),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _createNewNote(),
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort by'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Creation date'),
              onTap: () {
                setState(() {
                  _sortBy = 'created_at';
                  _loadNotes();
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Last modified'),
              onTap: () {
                setState(() {
                  _sortBy = 'modified_at';
                  _loadNotes();
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createNewNote() async {
    // Navigate to note editor screen
  }

  Future<void> _openNote(Note note) async {
    if (note.isLocked) {
      // Show password dialog
      bool authenticated = await _authenticateNote(note);
      if (!authenticated) return;
    }
    // Navigate to note editor screen with note data
  }

  Future<bool> _authenticateNote(Note note) async {
    String? password;
    bool authenticated = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Password'),
        content: TextField(
          obscureText: true,
          onChanged: (value) => password = value,
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text('Unlock'),
            onPressed: () => Navigator.pop(context, password == note.password),
          ),
        ],
      ),
    );
    return authenticated ?? false;
  }
}
