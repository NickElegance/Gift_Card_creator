import 'package:flutter/material.dart';

class DraggableEditableText extends StatefulWidget {
  final String text;
  final VoidCallback? onDelete;

  const DraggableEditableText({
    Key? key,
    required this.text,
    this.onDelete,
  }) : super(key: key);

  @override
  _DraggableEditableTextState createState() => _DraggableEditableTextState();
}

class _DraggableEditableTextState extends State<DraggableEditableText> {
  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Text(
        widget.text,
        style: const TextStyle(fontSize: 24, color: Colors.white),
      ),
    );
  }
}
