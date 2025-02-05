import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:gold_card_editer/feature/gift-card-creator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

/// Root widget of the app.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gift Card Creator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      // Set HomeView as the starting screen.
      home: const HomeView(),
    );
  }
}

/// Home view with a carousel slider to select card sizes.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  // List of available card sizes.
  final List<Map<String, dynamic>> cardSizes = const [
    {'label': 'Small', 'width': 300.0, 'height': 150.0},
    {'label': 'Medium', 'width': 350.0, 'height': 200.0},
    {'label': 'Large', 'width': 400.0, 'height': 250.0},
    {'label': 'Extra Large', 'width': 500.0, 'height': 300.0},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Card Size'),
      ),
      body: Center(
        child: CarouselSlider(
          options: CarouselOptions(
            height: 250,
            enlargeCenterPage: true,
            enableInfiniteScroll: false,
          ),
          items: cardSizes.map((size) {
            return Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () {
                    // Navigate to the GiftCardCreator view with selected card size.
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GiftCardCreator(
                          cardWidth: size['width'],
                          cardHeight: size['height'],
                          cardLabel: size['label'],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: size['width'] + 50, // Extra width for visibility
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            size['label'],
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                              '${size['width'].toInt()} x ${size['height'].toInt()}'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
