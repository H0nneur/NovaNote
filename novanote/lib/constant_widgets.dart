import 'package:flutter/material.dart';

AppBar novaNoteAppBar(String title) {
  return AppBar(
    title: Text(title),
    titleTextStyle: const TextStyle(color: Colors.white, fontSize: 22),
    backgroundColor: Colors.blue.shade900,
  );
}
