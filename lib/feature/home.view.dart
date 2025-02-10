import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:gold_card_editer/feature/gift-card-creator.dart';
import 'package:gold_card_editer/feature/model/gold-size.model.dart';
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
      home: HomeView(),
    );
  }
}

/// Home view with a carousel slider to select card sizes.
class HomeView extends StatelessWidget {
  HomeView({super.key});
  List<CardSize> cardSizes = [
    CardSize(
      label: 'horizantal',
      width: 350.0,
      height: 220.0,
      goldPlacement: 'left',
    ),
    CardSize(
      label: 'horizantal',
      width: 350.0,
      height: 220.0,
      goldPlacement: 'right',
    ),
    CardSize(
      label: 'vertical',
      width: 220.0,
      height: 350.0,
      goldPlacement: 'bottom',
    ),
    CardSize(
      label: 'vertical',
      width: 220.0,
      height: 350.0,
      goldPlacement: 'top',
    ),
  ];

  final goldPiece = CardSize(
    label: 'horizantal',
    width: 60,
    height: 40,
    goldPlacement: 'left',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Card Size'),
      ),
      body: Center(
        child: CarouselSlider(
          options: CarouselOptions(
            height: MediaQuery.of(context).size.height * 0.5,
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
                          cardWidth: size.width,
                          cardHeight: size.height,
                          cardLabel: size.label,
                        ),
                      ),
                    );
                  },
                  child: Center(
                    child: CardMockup(size: size),
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

class CardMockup extends StatelessWidget {
  final CardSize size;

  const CardMockup({
    Key? key,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double cardWidth = size.width;
    double cardHeight = size.height;
    String goldPlacement = size.goldPlacement;

    double aspectRatio = size.width / size.height;
    return CardFrame(
      child: ModifyCard(
          aspectRatio: aspectRatio,
          cardWidth: cardWidth,
          cardHeight: cardHeight,
          size: size,
          goldPlacement: goldPlacement),
    );
  }
}

class CardFrame extends StatelessWidget {
  const CardFrame({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const ui.Color.fromARGB(255, 221, 218, 218),
      ),
      child: child,
    );
  }
}

class ModifyCard extends StatelessWidget {
  const ModifyCard({
    super.key,
    required this.aspectRatio,
    required this.cardWidth,
    required this.cardHeight,
    required this.size,
    required this.goldPlacement,
  });

  final double aspectRatio;
  final double cardWidth;
  final double cardHeight;
  final CardSize size;
  final String goldPlacement;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The base card container
        AspectRatio(
          aspectRatio: aspectRatio,
          child: Container(
            width: cardWidth,
            height: cardHeight,
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    size.label,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('${cardWidth.toInt()} x ${cardHeight.toInt()}'),
                ],
              ),
            ),
          ),
        ),
        // The gold piece image placed according to the goldPlacement value.
        if (goldPlacement == 'left')
          Positioned(
            left: 15,
            top: (cardHeight / 2), // vertically centered (50/2 = 25)
            child: GoldPiece(),
          )
        else if (goldPlacement == 'right')
          Positioned(
            right: 15,
            top: (cardHeight / 2),
            child: GoldPiece(),
          )
        else if (goldPlacement == 'top')
          Positioned(
            top: 15,
            left: (cardWidth / 2),
            child: GoldPiece(),
          )
        else if (goldPlacement == 'bottom')
          Positioned(
            bottom: 15,
            left: (cardWidth / 2),
            child: GoldPiece(),
          ),
      ],
    );
  }
}

class GoldPiece extends StatelessWidget {
  const GoldPiece({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white,
          width: 1,
        ),
      ),
      width: 60,
      height: 40,
    );
  }
}
