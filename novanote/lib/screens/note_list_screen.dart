import 'package:flutter/material.dart';
import 'package:novanote/models/note.dart';
import 'package:novanote/screens/category_screen.dart';
import 'package:novanote/screens/edit_screen.dart';
import 'package:novanote/screens/setting_screen.dart';
import 'package:novanote/util/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoteListScreen extends StatefulWidget {
  final bool showArchived;

  const NoteListScreen({
    super.key,
    this.showArchived = false,
  });

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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'NovaNote',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Organize your thoughts',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.note),
              title: const Text('All Notes'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                setState(() {
                  // Reset filters
                  _searchQuery = '';
                  _loadNotes();
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Favorites'),
              onTap: () async {
                Navigator.pop(context);
                final notes = await _dbHelper.getNotes(isFavorite: true);
                setState(() {
                  _notes = notes;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('Archive'),
              onTap: () async {
                Navigator.pop(context);
                final notes = await _dbHelper.getNotes(isArchived: true);
                setState(() {
                  _notes = notes;
                });
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Categories'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CategoryScreen(),
                  ),
                );
                // Reload notes in case categories were modified
                _loadNotes();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(),
                  ),
                );
                // Reload settings
                _loadSettings();
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ... (previous search bar implementation)
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (note.isFavorite)
                        const Icon(Icons.star, color: Colors.yellow),
                      if (note.attachments.isNotEmpty)
                        const Icon(Icons.attach_file),
                    ],
                  ),
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
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const NoteEditorScreen(),
      ),
    );

    if (result == true) {
      _loadNotes();
    }
  }

  Future<void> _openNote(Note note) async {
    if (note.isLocked) {
      bool authenticated = await _authenticateNote(note);
      if (!authenticated) return;
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(note: note),
      ),
    );

    if (result == true) {
      _loadNotes();
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _sortBy = prefs.getString('defaultSortBy') ?? 'modified_at';
      _ascending = prefs.getBool('sortAscending') ?? false;
    });
    _loadNotes();
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
