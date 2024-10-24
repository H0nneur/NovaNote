import 'package:flutter/material.dart';
import 'package:novanote/models/note.dart';
import 'package:novanote/screens/category_screen.dart';
import 'package:novanote/screens/edit_screen.dart';
import 'package:novanote/screens/note_list_screen.dart';
import 'package:novanote/screens/setting_screen.dart';

class NavigationService {
  static Future<bool> navigateToNoteEditor(
    BuildContext context, {
    Note? note,
    int? categoryId,
  }) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(
          note: note,
          categoryId: categoryId,
        ),
      ),
    );
    return result ?? false;
  }

  static Future<void> navigateToCategory(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CategoryScreen(),
      ),
    );
  }

  static Future<void> navigateToSettings(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(),
      ),
    );
  }

  static Future<void> navigateToArchivedNotes(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NoteListScreen(showArchived: true),
      ),
    );
  }
}
