import 'package:flutter/material.dart';

class LibraryWidget extends StatefulWidget {
  const LibraryWidget({super.key});

  @override
  State<LibraryWidget> createState() => _LibraryWidgetState();
}

class _LibraryWidgetState extends State<LibraryWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Library page'));
  }
}