import 'package:flutter/material.dart';
import 'package:flutter_tinder_cards_clone/src/card_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: TinderSwipeCardsList(
            childCount: 10,
            cardWidth: MediaQuery.of(context).size.width - 32,
            cardHeight: 500,
          ),
        ),
      ),
    );
  }
}
