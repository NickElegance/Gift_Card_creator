import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Gift Card Creator view that accepts a card size.
class GiftCardCreator extends StatefulWidget {
  final double cardWidth;
  final double cardHeight;
  final String cardLabel;

  const GiftCardCreator({
    super.key,
    required this.cardWidth,
    required this.cardHeight,
    required this.cardLabel,
  });

  @override
  State<GiftCardCreator> createState() => _GiftCardCreatorState();
}

class _GiftCardCreatorState extends State<GiftCardCreator> {
  // Global key to capture the card widget as an image.
  final GlobalKey _globalKey = GlobalKey();

  // Background image file chosen by the user.
  File? _backgroundImage;

  // Transformation parameters.
  Offset _offset = Offset.zero;
  double _scale = 1.0;
  double _rotation = 0.0;
  bool _flipped = false;

  // Variables to store initial gesture parameters.
  Offset _initialFocalPoint = Offset.zero;
  Offset _initialOffset = Offset.zero;
  double _initialScale = 1.0;
  double _initialRotation = 0.0;

  /// Uses image_picker to select an image.
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _backgroundImage = File(pickedFile.path);
        // Reset transformations when a new image is chosen.
        _offset = Offset.zero;
        _scale = 1.0;
        _rotation = 0.0;
        _flipped = false;
      });
    }
  }

  /// Exports the card view as a PNG image and saves it to local storage.
  Future<void> _exportToPNG() async {
    try {
      // Retrieve the render object from the global key.
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      // Increase pixelRatio for better quality.
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final fileName =
          '${directory.path}/gift_card_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(fileName);
      await file.writeAsBytes(pngBytes);

      final params = SaveFileDialogParams(sourceFilePath: file.path);
      final result = await FlutterFileDialog.saveFile(params: params);
      if (result == null) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Card saved ")),
      );
    } catch (e) {
      print("Error exporting PNG: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to export image.")),
      );
    }
  }

  /// Toggles a horizontal flip of the background image.
  void _flipImage() {
    setState(() {
      _flipped = !_flipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gift Card Creator (${widget.cardLabel})"),
        actions: [
          IconButton(
            icon: const Icon(Icons.image),
            tooltip: "Pick Background Image",
            onPressed: _pickImage,
          ),
          IconButton(
            icon: const Icon(Icons.flip),
            tooltip: "Flip Image",
            onPressed: _flipImage,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: "Export as PNG",
            onPressed: _exportToPNG,
          ),
        ],
      ),
      body: Center(
        child: RepaintBoundary(
          key: _globalKey,
          // ClipRect ensures that the image stays within the card frame.
          child: ClipRect(
            child: Container(
              width: widget.cardWidth,
              height: widget.cardHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black),
              ),
              child: Stack(
                children: [
                  if (_backgroundImage != null)
                    // GestureDetector supports dragging, zooming, and rotation.
                    Positioned.fill(
                      child: GestureDetector(
                        onScaleStart: (details) {
                          _initialFocalPoint = details.focalPoint;
                          _initialOffset = _offset;
                          _initialScale = _scale;
                          _initialRotation = _rotation;
                        },
                        onScaleUpdate: (details) {
                          setState(() {
                            _offset = _initialOffset +
                                (details.focalPoint - _initialFocalPoint);
                            _scale = _initialScale * details.scale;
                            _rotation = _initialRotation + details.rotation;
                          });
                        },
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..translate(_offset.dx, _offset.dy)
                            ..rotateZ(_rotation)
                            ..scale(_scale * (_flipped ? -1.0 : 1.0), _scale),
                          child: Image.file(
                            _backgroundImage!,
                            fit: BoxFit.cover,
                            width: widget.cardWidth,
                            height: widget.cardHeight,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
