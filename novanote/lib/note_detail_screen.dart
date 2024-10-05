import 'package:flutter/material.dart';
import 'package:novanote/constant_widgets.dart';

class NoteDetailScreen extends StatelessWidget {
  const NoteDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: novaNoteAppBar("Note"),
    );
  }
}
