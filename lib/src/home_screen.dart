import 'package:flutter/material.dart';
import 'package:flutter_tinder_cards_clone/src/swipe_cards_list.dart';

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
          child: SwipeCardsList(
            childCount: 6,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Image.asset(
                      'assets/images/image_${index + 1}.jpeg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                      bottom: 50,
                      left: 50,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          'Picture ' + (index + 1).toString(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold),
                        ),
                      )),
                ],
              );
            },
            cardWidth: MediaQuery.of(context).size.width - 32,
            cardHeight: 500,
          ),
        ),
      ),
    );
  }
}
