import 'package:flutter/material.dart';
import 'package:novanote/constant_widgets.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({super.key});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: novaNoteAppBar("Edit note"));
  }
}
