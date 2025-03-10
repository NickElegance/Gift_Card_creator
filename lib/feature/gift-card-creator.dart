import 'dart:io';
import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:gold_card_editer/feature/draggableText.widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

import 'package:saver_gallery/saver_gallery.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

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
  bool _isExporting = false;

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

  Future<void> _exportPrintReadyGiftCard() async {
    try {
      setState(() {
        _isExporting = true;
      });
      await Future.delayed(Duration(milliseconds: 500));
      // Get the current size of your widget
      RenderBox renderBox =
          _globalKey.currentContext!.findRenderObject() as RenderBox;
      Size currentSize = renderBox.size;
// double longestSize = currentSize.longestSide;
      // Calculate required pixel ratio for 300 DPI at gift card size
      // Assuming your widget is designed at the correct aspect ratio

      double requiredWidth = 3.375 * 450; // Card width in inches × DPI

      // double requiredWidth = 1012; // 3.375 inches × 300 DPI
      double pixelRatio = requiredWidth / currentSize.longestSide;

      // Capture the widget as an image with print-quality resolution
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image rawImage = await boundary.toImage(pixelRatio: pixelRatio);

      // Get PNG data directly
      ByteData? byteData =
          await rawImage.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      Uint8List compressedBytes = await FlutterImageCompress.compressWithList(
        pngBytes,
        minHeight: rawImage.height,
        minWidth: rawImage.width,
        quality: 85,
        format: CompressFormat.png,
      ); // 85% quality is usually good

      // Save with a print-ready filename
      // final downloadPath = await getImageSavePath();
      // final filePath =
      //     '$downloadPath/printable_gift_card_${DateTime.now().millisecondsSinceEpoch}.png';

      final result = await SaverGallery.saveImage(
        compressedBytes,
        quality: 100,
        androidRelativePath: "Pictures/appName/images",
        skipIfExists: false,
        fileName: 'gift_card_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gift card saved to gallery!")),
        );
      }

      // final file = File(filePath);
      // await file.writeAsBytes(pngBytes);
      // await _scanFile(filePath);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text("Print-ready gift card saved!")),
      // );
    } catch (e) {
      print("Error exporting print-ready PNG: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to export print-ready image.")),
      );
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  // /// Exports the card view as a PNG image and saves it to local storage.
  // Future<void> _exportToFixedSizePNG() async {
  //   try {
  //     setState(() {
  //       _isExporting = true;
  //     });

  //     await Future.delayed(
  //         Duration(seconds: 1)); // Capture the widget as an image
  //     RenderRepaintBoundary boundary = _globalKey.currentContext!
  //         .findRenderObject() as RenderRepaintBoundary;

  //     // Use a high pixel ratio to capture details
  //     ui.Image rawImage = await boundary.toImage(pixelRatio: 5.0);

  //     // Convert to ByteData with PNG format directly
  //     ByteData? byteData =
  //         await rawImage.toByteData(format: ui.ImageByteFormat.png);

  //     if (byteData == null) {
  //       throw Exception('Failed to get image data');
  //     }

  //     Uint8List pngBytes = byteData.buffer.asUint8List();

  //     // Save file to storage
  //     // final result = await ImageGallerySaver.saveImage(pngBytes,
  //     //     name: 'gift_card_${DateTime.now().millisecondsSinceEpoch}');

  //     final result = await SaverGallery.saveImage(
  //       pngBytes,
  //       quality: 100,
  //       androidRelativePath: "Pictures/appName/images",
  //       skipIfExists: false,
  //       fileName: 'gift_card_${DateTime.now().millisecondsSinceEpoch}',
  //     );

  //     if (result.isSuccess) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Gift card saved to gallery!")),
  //       );
  //     }
  //   } catch (e) {
  //     print("Error exporting PNG: $e");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Failed to export image: ${e.toString()}")),
  //     );
  //   } finally {
  //     setState(() {
  //       _isExporting = false;
  //     });
  //   }
  // }

// In your export function

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

  double _width = 200;
  double _height = 200;
  double _left = 100; // Initial left position (keeps the top-left corner fixed)
  double _top = 100; // Initial top position (prevents movement upwards)

  void _resize(DragUpdateDetails details) {
    setState(() {
      double newWidth =
          _width + details.delta.dx; // Increase width to the right
      double newHeight = _height + details.delta.dy; // Increase height downward

      // Clamp the values to prevent shrinking too much
      newWidth = newWidth.clamp(10, 400);
      newHeight = newHeight.clamp(10, 400);

      // Adjust the left position to keep the bottom-left corner fixed
      _left -= (newWidth - _width);

      _width = newWidth;
      _height = newHeight;
    });
  }

  void _rotate(DragUpdateDetails details) {
    setState(() {
      // Update the rotation based on the horizontal drag delta.
      // You can adjust the divisor to control the rotation sensitivity.
      _rotationText += details.delta.dx / 100;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gift Card Creator (${widget.cardLabel})"),
      ),
      floatingActionButton: Column(
        spacing: 5,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // FloatingActionButton(
          //   heroTag: "download1",
          //   backgroundColor: Colors.green,
          //   onPressed: _exportToFixedSizePNG,
          //   child: Icon(Icons.download),
          // ),
          FloatingActionButton(
            heroTag: "download2",
            backgroundColor: Colors.yellow,
            onPressed: _exportPrintReadyGiftCard,
            child: Icon(Icons.download),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
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
          if (_isExporting) _buildLoading()
        ],
      ),
    );
  }

  Widget _buildLoading() => Container(
      color: Colors.black.withValues(alpha: .4),
      child: const Center(child: CircularProgressIndicator()));

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
                              // _rotation = _initialRotation + details.rotation;
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
                                    border: _isExporting
                                        ? null
                                        : Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Container(
                                      width: _width,
                                      height: _height,
                                      decoration: BoxDecoration(
                                        // Frame covering the text:

                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: e),
                                ),
                                _isExporting
                                    ? SizedBox()
                                    : Positioned(
                                        left: 0,
                                        top: 0,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _textWidgets.remove(e);
                                            });
                                          },
                                          child: CircleAvatar(
                                            radius: 18,
                                            backgroundColor: Colors.white,
                                            child: Icon(
                                              Icons.delete,
                                              size: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                // Positioned(
                                //   top: 0,
                                //   right: 0,
                                //   child: GestureDetector(
                                //     onPanUpdate: _rotate,
                                //     child: CircleAvatar(
                                //       radius: 18,
                                //       backgroundColor: Colors.white,
                                //       child: Icon(
                                //         Icons.rotate_right,
                                //         size: 15,
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                _isExporting
                                    ? SizedBox()
                                    : Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: GestureDetector(
                                          onPanUpdate: _resize,
                                          child: CircleAvatar(
                                            radius: 18,
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
