import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:gold_card_editer/feature/draggableText.widget.dart';
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

  //* text dragable
  // Transformation parameters.
  Offset _offsetText = Offset.zero;
  double _scaleText = 1.0;
  double _rotationText = 0.0;

  // Variables to store initial gesture parameters.
  Offset _initialFocalPointText = Offset.zero;
  Offset _initialOffsetText = Offset.zero;
  double _initialScaleText = 1.0;
  double _initialRotationText = 0.0;

  final List<Widget> _textWidgets = [];

  void _editText() {}

  void _addTextOverlay(String text) {
    setState(() {
      _textWidgets.add(
        DraggableEditableText(
          text: text,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gift Card Creator (${widget.cardLabel})"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _exportToPNG,
        child: Icon(Icons.download),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          spacing: 5,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: _buildCard(),
            ),
            SingleChildScrollView(
              child: Row(
                spacing: 5,
                children: [
                  ChoiceChip(
                      onSelected: (value) {
                        _pickImage();
                      },
                      showCheckmark: false,
                      label: const Icon(Icons.image),
                      selected: false),
                  ChoiceChip(
                      showCheckmark: false,
                      onSelected: (value) {
                        _flipImage();
                      },
                      label: const Icon(Icons.flip),
                      selected: false),
                  ChoiceChip(
                      onSelected: (value) {
                        _openButtomSheet();
                      },
                      showCheckmark: false,
                      label: const Icon(Icons.text_fields),
                      selected: false),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Align _buildCard() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        padding: const EdgeInsets.all(22.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color:
              const ui.Color.fromARGB(255, 221, 218, 218).withValues(alpha: .5),
        ),
        child: AspectRatio(
          aspectRatio: widget.cardWidth / widget.cardHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: RepaintBoundary(
              key: _globalKey,
              child: Container(
                width: widget.cardWidth,
                height: widget.cardHeight,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
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
                    ..._textWidgets.map(
                      (e) => Positioned.fill(
                        child: GestureDetector(
                          onTap: _editText,
                          onScaleStart: (details) {
                            _initialFocalPointText = details.focalPoint;
                            _initialOffsetText = _offsetText;
                            _initialRotationText = _rotationText;
                          },
                          onScaleUpdate: (details) {
                            setState(() {
                              _offsetText = _initialOffsetText +
                                  (details.focalPoint - _initialFocalPointText);

                              _rotationText =
                                  _initialRotationText + details.rotation;
                            });
                          },
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..translate(_offsetText.dx, _offsetText.dy)
                              ..rotateZ(_rotationText),
                            child: Center(
                                child: Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.all(8.0),
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    // Frame covering the text:
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Container(
                                      width: 300,
                                      decoration: BoxDecoration(
                                        // Frame covering the text:
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: e),
                                ),
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _textWidgets.remove(e);
                                      });
                                    },
                                    child: CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.white,
                                      child: Icon(
                                        Icons.delete,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: GestureDetector(
                                    child: CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.white,
                                      child: Icon(
                                        Icons.center_focus_weak,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            )),
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
      ),
    );
  }

  _openButtomSheet() {
    TextEditingController controller = TextEditingController();
    showModalBottomSheet(
        barrierColor: Colors.transparent,
        context: context,
        builder: (context) {
          return Container(
              padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 5,
                children: [
                  Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            if (controller.text.isEmpty) return;
                            _addTextOverlay(controller.text);
                          },
                          child: Text("เพิ่ม"))),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "กรอกข้อความที่ต้องการแสดง",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ));
        });
  }
}
