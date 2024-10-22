// lib/screens/note_editor_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:novanote/models/category.dart';
import 'package:novanote/models/note.dart';
import 'package:novanote/util/database_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;
  final int? categoryId;

  const NoteEditorScreen({super.key, this.note, this.categoryId});

  @override
  _NoteEditorScreenState createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  late Note _note;
  List<Category> _categories = [];
  int? _selectedCategoryId;
  bool _isLocked = false;
  String? _password;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _initializeNote();
  }

  Future<void> _loadCategories() async {
    final categories = await _dbHelper.getCategories();
    setState(() {
      _categories = categories;
    });
  }

  void _initializeNote() {
    if (widget.note != null) {
      _note = widget.note!;
      _titleController.text = _note.title;
      _contentController.text = _note.content;
      _selectedCategoryId = _note.categoryId;
      _isLocked = _note.isLocked;
      _password = _note.password;
    } else {
      _note = Note(
        title: '',
        content: '',
        categoryId: widget.categoryId ?? 0,
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
      );
      _selectedCategoryId = widget.categoryId;
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File newImage = File('${directory.path}/images/$fileName');

      await newImage.parent.create(recursive: true);
      await File(image.path).copy(newImage.path);

      setState(() {
        _note.attachments.add(newImage.path);
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null) {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = result.files.first.name;
      final File newFile = File('${directory.path}/files/$fileName');

      await newFile.parent.create(recursive: true);
      await File(result.files.first.path!).copy(newFile.path);

      setState(() {
        _note.attachments.add(newFile.path);
      });
    }
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    _note.title = _titleController.text;
    _note.content = _contentController.text;
    _note.categoryId = _selectedCategoryId ?? 0;
    _note.isLocked = _isLocked;
    _note.password = _password;
    _note.modifiedAt = DateTime.now();

    if (_note.id == null) {
      await _dbHelper.insertNote(_note);
    } else {
      await _dbHelper.updateNote(_note);
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: Icon(_note.isFavorite ? Icons.star : Icons.star_border),
            onPressed: () {
              setState(() {
                _note.isFavorite = !_note.isFavorite;
              });
            },
          ),
          IconButton(
            icon: Icon(_note.isImportant ? Icons.flag : Icons.flag_outlined),
            onPressed: () {
              setState(() {
                _note.isImportant = !_note.isImportant;
              });
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(_isLocked ? Icons.lock : Icons.lock_open),
                  title: Text(_isLocked ? 'Remove Password' : 'Set Password'),
                  onTap: () => _showPasswordDialog(),
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.archive),
                  title: Text(_note.isArchived ? 'Unarchive' : 'Archive'),
                  onTap: () {
                    setState(() {
                      _note.isArchived = !_note.isArchived;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: 0,
                    child: Text('Uncategorized'),
                  ),
                  ..._categories.map((category) {
                    return DropdownMenuItem(
                      value: category.id,
                      child: Text(category.name),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: null,
                  expands: true,
                ),
              ),
            ),
            if (_note.attachments.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _note.attachments.length,
                  itemBuilder: (context, index) {
                    final attachment = _note.attachments[index];
                    final isImage = attachment.toLowerCase().endsWith('.jpg') ||
                        attachment.toLowerCase().endsWith('.jpeg') ||
                        attachment.toLowerCase().endsWith('.png');

                    return Card(
                      child: Stack(
                        children: [
                          if (isImage)
                            Image.file(
                              File(attachment),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            )
                          else
                            Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[200],
                              child: const Icon(Icons.insert_drive_file),
                            ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _note.attachments.removeAt(index);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.image),
              onPressed: _pickImage,
            ),
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: _pickFile,
            ),
            IconButton(
              icon: const Icon(Icons.link),
              onPressed: () => _showAddLinkDialog(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveNote,
        child: const Icon(Icons.save),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  Future<void> _showPasswordDialog() async {
    String? newPassword;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isLocked ? 'Change Password' : 'Set Password'),
        content: TextField(
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
          ),
          onChanged: (value) => newPassword = value,
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(_isLocked ? 'Change' : 'Set'),
            onPressed: () {
              setState(() {
                if (newPassword != null && newPassword!.isNotEmpty) {
                  _isLocked = true;
                  _password = newPassword;
                } else {
                  _isLocked = false;
                  _password = null;
                }
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showAddLinkDialog() async {
    String? link;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Link'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'URL',
          ),
          onChanged: (value) => link = value,
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Add'),
            onPressed: () {
              if (link != null && link!.isNotEmpty) {
                final currentPosition = _contentController.selection.start;
                final text = _contentController.text;
                final newText =
                    '${text.substring(0, currentPosition)}[$link]($link)${text.substring(currentPosition)}';
                _contentController.text = newText;
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
