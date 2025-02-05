import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

/// The root widget of the app.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gold Card Creator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      home: const GiftCardCreator(),
    );
  }
}

/// Main screen holding the card canvas and controls.
class GiftCardCreator extends StatefulWidget {
  const GiftCardCreator({super.key});

  @override
  State<GiftCardCreator> createState() => _GiftCardCreatorState();
}

class _GiftCardCreatorState extends State<GiftCardCreator> {
  // Global key to capture the card widget as an image.
  final GlobalKey _globalKey = GlobalKey();

  // Background image file chosen by the user.
  File? _backgroundImage;

  // Transformation parameters for the background image.
  Offset _offset = Offset.zero;
  double _scale = 1.0;
  double _rotation = 0.0;
  bool _flipped = false;

  // Variables to track initial gesture values.
  Offset _initialFocalPoint = Offset.zero;
  Offset _initialOffset = Offset.zero;
  double _initialScale = 1.0;
  double _initialRotation = 0.0;

  // Define default card size (in logical pixels).
  final double cardWidth = 350;
  final double cardHeight = 200;

  /// Launches the image picker to select an image.
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _backgroundImage = File(pickedFile.path);
        // Reset transformation when a new image is selected.
        _offset = Offset.zero;
        _scale = 1.0;
        _rotation = 0.0;
        _flipped = false;
      });
    }
  }

  /// Exports the current card view as a PNG image and saves it to local storage.
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
        title: const Text("Gift Card Creator"),
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
        // RepaintBoundary allows us to capture this widget as an image.
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: RepaintBoundary(
                key: _globalKey,
                // Wrap the card container in a ClipRect to ensure that any
                // parts of the image that fall outside the card frame are clipped.
                child: ClipRect(
                  child: Container(
                    width: cardWidth,
                    height: cardHeight,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                    ),
                    child: Stack(
                      children: [
                        // Only display the background image if one has been selected.
                        if (_backgroundImage != null)
                          // GestureDetector allows for drag, zoom, and rotation.
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
                                  // Update translation.
                                  _offset = _initialOffset +
                                      (details.focalPoint - _initialFocalPoint);
                                  // Update scale.
                                  _scale = _initialScale * details.scale;
                                  // Update rotation.
                                  _rotation =
                                      _initialRotation + details.rotation;
                                });
                              },
                              child: Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  // Translate the image.
                                  ..translate(_offset.dx, _offset.dy)
                                  // Rotate the image.
                                  ..rotateZ(_rotation)
                                  // Scale the image (flip horizontally if needed).
                                  ..scale(
                                      _scale * (_flipped ? -1.0 : 1.0), _scale),
                                child: Image.file(
                                  _backgroundImage!,
                                  fit: BoxFit.cover,
                                  width: cardWidth,
                                  height: cardHeight,
                                ),
                              ),
                            ),
                          ),

                        // You may add additional elements (like text or logos) here.
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 40,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  width: 40,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.amber.withValues(alpha: .8),
                    border: Border.all(color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
