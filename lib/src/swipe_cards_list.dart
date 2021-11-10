import 'package:flutter/material.dart';

import 'package:flutter_tinder_cards_clone/src/dialog_animations/picture_action_anim_dialog.dart';

class SwipeCardsList extends StatefulWidget {
  final double cardWidth, cardHeight;
  final Widget Function(BuildContext, int) itemBuilder;
  final int childCount;
  const SwipeCardsList(
      {required this.itemBuilder,
      required this.childCount,
      required this.cardHeight,
      required this.cardWidth,
      Key? key})
      : super(key: key);

  @override
  _SwipeCardsListState createState() => _SwipeCardsListState();
}

class _SwipeCardsListState extends State<SwipeCardsList>
    with TickerProviderStateMixin {
  late int childCount;
  late double cardWidth;
  late double cardHeight;

  //pixels swiped by user
  double swipedOffset = 0.0;
  // card coordinates on screen
  Offset cardPosition = const Offset(0, 0);

  double bottomCardRevealMargin = 16.0;
  int quadrant = 0;

  //swiped pixels / card pixels width
  double swipedScale = 0.0;

  // left = -1, center = 0, right = 1
  int cardRelativePosition = 0;

  late AnimationController likedAnimationController;
  Animation<Offset>? likedAnimation;
  bool overrideLikeAnim = false;

  late AnimationController dislikedAnimationController;
  Animation? dislikedAnimation;
  bool overrideDislikeAnim = false;

  late AnimationController cardPositionResetAnimationController;
  Animation? cardPositionResetAnimation;
  Animation? cardAngleResetAnimation;

  final int animDurationMs = 300;
  final int resetAnimDurationMs = 300;

  int currentIndex = 0;

  @override
  void initState() {
    childCount = widget.childCount;
    cardHeight = widget.cardHeight;
    cardWidth = widget.cardWidth;

    likedAnimationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: animDurationMs));
    dislikedAnimationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: animDurationMs));
    cardPositionResetAnimationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: resetAnimDurationMs));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Center(
              child: Stack(
                children: [
                  Positioned(
                    top: getBottomPictureMargin(),
                    bottom: getBottomPictureMargin(),
                    left: getBottomPictureMargin(),
                    right: getBottomPictureMargin(),
                    child: SizedBox(
                        child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  offset: Offset(4, 4),
                                  color: Colors.grey,
                                  blurRadius: 8)
                            ]),
                        child: getNextCard(),
                      ),
                    )),
                  ),
                  GestureDetector(
                    onPanStart: (details) {
                      if (details.localPosition.dx < (cardWidth / 2)) {
                        //left
                        if (details.localPosition.dy < (cardHeight * 0.6)) {
                          quadrant = 2;
                        } else {
                          quadrant = 3;
                        }
                      } else {
                        //right
                        if (details.localPosition.dy < (cardHeight * 0.6)) {
                          quadrant = 1;
                        } else {
                          quadrant = 4;
                        }
                      }
                    },
                    onPanUpdate: (details) {
                      cardPosition = Offset(cardPosition.dx + details.delta.dx,
                          cardPosition.dy + details.delta.dy);

                      //Swiping in right direction.
                      // if (!swipingLeft && !swipingRight) {
                      if (details.delta.dx > 0) {
                        if (quadrant == 2 || quadrant == 1) {
                          swipedOffset = swipedOffset + (details.delta.dx);
                        } else if (quadrant == 3 || quadrant == 4) {
                          swipedOffset = swipedOffset + (-details.delta.dx);
                        }
                      } else

                      // Swiping in left direction.
                      if (details.delta.dx < 0) {
                        if (quadrant == 2 || quadrant == 1) {
                          swipedOffset = swipedOffset + (details.delta.dx);
                        } else if (quadrant == 3 || quadrant == 4) {
                          swipedOffset = swipedOffset + (-details.delta.dx);
                        }
                      }

                      updateDetails();

                      setState(() {});
                    },
                    onPanEnd: (details) {
                      if (isPictureLiked()) {
                        showLikedAnimDialog();
                        likedAnimation = Tween<Offset>(
                                begin: cardPosition,
                                end: Offset(
                                    cardPosition.dx + 300, cardPosition.dy))
                            .animate(CurvedAnimation(
                                parent: likedAnimationController,
                                curve: Curves.ease));

                        final listener = _likedAnimationListener;
                        likedAnimationController.addListener(listener);
                        likedAnimationController.forward();
                        Future.delayed(Duration(milliseconds: animDurationMs),
                            () {
                          likedAnimationController.removeListener(listener);
                          likedAnimationController.reset();
                          resetTiles();
                        });
                      } else if (isPictureDisliked()) {
                        showDisLikedAnimDialog();
                        dislikedAnimation = Tween<Offset>(
                                begin: cardPosition,
                                end: Offset(
                                    cardPosition.dx - 300, cardPosition.dy))
                            .animate(CurvedAnimation(
                                parent: dislikedAnimationController,
                                curve: Curves.ease));

                        final listener = _dislikedAnimationListener;
                        dislikedAnimationController.addListener(listener);
                        dislikedAnimationController.forward();
                        Future.delayed(Duration(milliseconds: animDurationMs),
                            () {
                          dislikedAnimationController.removeListener(listener);
                          dislikedAnimationController.reset();
                          resetTiles();
                        });
                      } else {
                        //reset image position and angle
                        cardPositionResetAnimation = Tween<Offset>(
                                begin: cardPosition,
                                end: const Offset(0.0, 0.0))
                            .animate(CurvedAnimation(
                                parent: cardPositionResetAnimationController,
                                curve: Curves.ease));
                        cardAngleResetAnimation = Tween<double>(
                                begin: swipedOffset, end: 0.0)
                            .animate(CurvedAnimation(
                                parent: cardPositionResetAnimationController,
                                curve: Curves.ease));

                        final positionListener =
                            _cardPositionResetAnimationListener;
                        cardPositionResetAnimationController
                            .addListener(positionListener);

                        cardPositionResetAnimationController.forward();

                        Future.delayed(
                            Duration(milliseconds: resetAnimDurationMs), () {
                          cardPositionResetAnimationController
                              .removeListener(positionListener);

                          cardPositionResetAnimationController.reset();
                        });
                      }
                    },
                    child: Transform.translate(
                      offset: cardPosition,
                      child: Transform.rotate(
                        angle: 0.436 * swipedScale,
                        alignment: getRotationAlignment(quadrant),
                        child: Stack(
                          children: [
                            SizedBox(
                                width: cardWidth,
                                height: cardHeight,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                              offset: Offset(4, 4),
                                              color: Colors.grey,
                                              blurRadius: 8)
                                        ]),
                                    child: getCurrentCard(),
                                  ),
                                )),
                            if (isPictureDisliked() || overrideDislikeAnim)
                              Positioned(
                                  top: 50,
                                  right: 50,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.red),
                                    ),
                                    child: const Text(
                                      'NOPE',
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )),
                            if (isPictureLiked() || overrideLikeAnim)
                              Positioned(
                                  top: 50,
                                  left: 50,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.green),
                                    ),
                                    child: const Text(
                                      'LIKE',
                                      style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                    iconSize: 48,
                    color: Colors.red,
                    onPressed: () async {
                      dislikedAnimation = Tween<Offset>(
                              begin: const Offset(0, 0),
                              end: Offset(-cardWidth - 100, 0))
                          .animate(CurvedAnimation(
                              parent: dislikedAnimationController,
                              curve: Curves.ease));
                      setState(() {
                        overrideDislikeAnim = true;
                      });
                      showDisLikedAnimDialog();
                      await Future.delayed(const Duration(milliseconds: 300));
                      final listener = _dislikedAnimationListener;
                      dislikedAnimationController.addListener(listener);
                      dislikedAnimationController.forward();
                      Future.delayed(Duration(milliseconds: animDurationMs),
                          () {
                        dislikedAnimationController.removeListener(listener);
                        dislikedAnimationController.reset();
                        overrideDislikeAnim = false;
                        resetTiles();
                      });
                    },
                    icon: cardRelativePosition == -1
                        ? const Icon(Icons.cancel)
                        : const Icon(Icons.clear)),
                IconButton(
                    iconSize: 48,
                    color: Colors.green,
                    onPressed: () async {
                      likedAnimation = Tween<Offset>(
                              begin: const Offset(0, 0),
                              end: Offset(cardWidth + 100, 0))
                          .animate(CurvedAnimation(
                              parent: likedAnimationController,
                              curve: Curves.ease));
                      setState(() {
                        overrideLikeAnim = true;
                      });
                      showLikedAnimDialog();
                      await Future.delayed(const Duration(milliseconds: 300));
                      final listener = _likedAnimationListener;
                      likedAnimationController.addListener(listener);
                      likedAnimationController.forward();
                      Future.delayed(Duration(milliseconds: animDurationMs),
                          () {
                        likedAnimationController.removeListener(listener);
                        likedAnimationController.reset();
                        overrideLikeAnim = false;
                        resetTiles();
                      });
                    },
                    icon: cardRelativePosition == 1
                        ? const Icon(Icons.favorite)
                        : const Icon(Icons.favorite_outline)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getCurrentCard() {
    return widget.itemBuilder(context, currentIndex);
  }

  Widget getNextCard() {
    if (currentIndex + 1 < childCount) {
      return widget.itemBuilder(context, currentIndex + 1);
    } else {
      return widget.itemBuilder(context, 0);
    }
  }

  showLikedAnimDialog() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return PictureActionAnimDialog(
              iconWidget: Container(
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green,
            ),
            child: const Icon(
              Icons.favorite,
              size: 128,
              color: Colors.white,
            ),
          ));
        });
    await Future.delayed(const Duration(milliseconds: 750));
    Navigator.of(context).pop();
  }

  showDisLikedAnimDialog() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return PictureActionAnimDialog(
              iconWidget: Container(
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red,
            ),
            child: const Icon(
              Icons.clear,
              size: 128,
              color: Colors.white,
            ),
          ));
        });
    await Future.delayed(const Duration(milliseconds: 750));
    Navigator.of(context).pop();
  }

  void resetTiles() {
    if (currentIndex == childCount - 1) {
      currentIndex = 0;
    } else {
      currentIndex = currentIndex + 1;
    }
    cardPosition = const Offset(0, 0);
    swipedOffset = 0.0;
    quadrant = 0;

    updateDetails();
    setState(() {});
  }

  bool isPictureLiked() {
    return cardRelativePosition == 1 && (swipedScale.abs() * 100) >= 30;
  }

  bool isPictureDisliked() {
    return cardRelativePosition == -1 && (swipedScale.abs() * 100) >= 30;
  }

  AlignmentGeometry? getRotationAlignment(int quadrant) {
    switch (quadrant) {
      case 1:
        return Alignment.bottomCenter;
      case 2:
        return Alignment.bottomCenter;
      case 3:
        return Alignment.topCenter;
      case 4:
        return Alignment.topCenter;
      default:
        return null;
    }
  }

  double getBottomPictureMargin() {
    if (overrideLikeAnim || overrideDislikeAnim) {
      return 0.0;
    } else if (swipedScale == 0.0) {
      return bottomCardRevealMargin;
    } else {
      double newValue = bottomCardRevealMargin * ((swipedScale.abs() * 3.34));
      if (bottomCardRevealMargin - newValue < 0) return 0.0;

      return bottomCardRevealMargin - newValue;
    }
  }

  updateDetails() {
    swipedScale = swipedOffset / cardWidth;

    if (cardPosition.dx < -15) {
      cardRelativePosition = -1;
    } else if (cardPosition.dx > 15) {
      cardRelativePosition = 1;
    } else {
      cardRelativePosition = 0;
    }
  }

  void _likedAnimationListener() {
    setState(() {
      cardPosition =
          likedAnimation != null ? likedAnimation!.value : const Offset(0, 0);
    });
  }

  void _dislikedAnimationListener() {
    setState(() {
      cardPosition = dislikedAnimation != null
          ? dislikedAnimation!.value
          : const Offset(0, 0);
    });
  }

  void _cardPositionResetAnimationListener() {
    cardPosition = cardPositionResetAnimation != null
        ? cardPositionResetAnimation!.value
        : const Offset(0, 0);
    swipedOffset =
        cardAngleResetAnimation != null ? cardAngleResetAnimation!.value : 0.0;

    updateDetails();
    setState(() {});
  }
}
