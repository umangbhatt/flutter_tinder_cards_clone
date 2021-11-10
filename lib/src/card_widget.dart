import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:math' as math;

class TinderSwipeCardsList extends StatefulWidget {
  final int childCount;
  final double cardWidth, cardHeight;
  const TinderSwipeCardsList(
      {required this.childCount,
      required this.cardHeight,
      required this.cardWidth,
      Key? key})
      : super(key: key);

  @override
  _TinderSwipeCardsListState createState() => _TinderSwipeCardsListState();
}

class _TinderSwipeCardsListState extends State<TinderSwipeCardsList>
    with TickerProviderStateMixin {
  late int childCount;
  double swipedOffset = 0.0;
  Offset cardPosition = const Offset(0, 0);
  late double cardWidth;
  late double cardHeight;
  double bottomCardRevealMargin = 8.0;
  int quadrant = 0;
  double swipedScale = 0.0;

  int cardRelativePosition = 0;

  bool swiping = false;
  bool reset = true;

  late AnimationController likedAnimationController;
  Animation<Offset>? likedAnimation;
  bool overrideLikeAnim = false;

  late AnimationController dislikedAnimationController;
  Animation? dislikedAnimation;
  bool overrideDislikeAnim = false;

  late AnimationController resetPictureAnimationController;
  Animation? resetPictureAnimation;

  late AnimationController resetPictureAngleAnimationController;
  Animation? resetPictureAngleAnimation;

  final int animDurationMs = 200;

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
    resetPictureAnimationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: animDurationMs + 100));
    resetPictureAngleAnimationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: animDurationMs + 100));
    likedAnimationController.addListener(() {
      setState(() {});
    });
    dislikedAnimationController.addListener(() {
      setState(() {});
    });
    resetPictureAnimationController.addListener(() {
      setState(() {});
    });
    resetPictureAngleAnimationController.addListener(() {
      setState(() {});
    });
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
                  (currentIndex + 1 < childCount)
                      ? Positioned(
                          top: getBottomPictureMargin(),
                          bottom: getBottomPictureMargin(),
                          left: getBottomPictureMargin(),
                          right: getBottomPictureMargin(),
                          child: SizedBox(
                              child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white,
                                boxShadow: const [
                                  BoxShadow(
                                      offset: Offset(4, 4),
                                      color: Colors.grey,
                                      blurRadius: 8)
                                ]),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                'https://picsum.photos/id/${229 + currentIndex + 1}/${cardWidth.toInt().toString()}/${cardHeight.toInt().toString()}',
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.blue,
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  );
                                },
                              ),
                            ),
                          )),
                        )
                      : Positioned(
                          top: getBottomPictureMargin(),
                          bottom: getBottomPictureMargin(),
                          left: getBottomPictureMargin(),
                          right: getBottomPictureMargin(),
                          child: SizedBox(
                              child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white,
                                boxShadow: const [
                                  BoxShadow(
                                      offset: Offset(4, 4),
                                      color: Colors.grey,
                                      blurRadius: 8)
                                ]),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                'https://picsum.photos/id/${229}/${cardWidth.toInt().toString()}/${cardHeight.toInt().toString()}',
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.blue,
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  );
                                },
                              ),
                            ),
                          )),
                        ),
                  GestureDetector(
                    onPanStart: (details) {
                      if (details.localPosition.dx < (cardWidth / 2)) {
                        //left
                        if (details.localPosition.dy < (cardHeight / 2)) {
                          log('quadrant 2');
                          quadrant = 2;
                        } else {
                          log('quadrant 3');
                          quadrant = 3;
                        }
                      } else {
                        //right
                        if (details.localPosition.dy < (cardHeight / 2)) {
                          log('quadrant 1');
                          quadrant = 1;
                        } else {
                          log('quadrant 4');
                          quadrant = 4;
                        }
                      }
                      setState(() {
                        swiping = true;
                        reset = false;
                      });
                      resetPictureAnimationController.reset();
                      resetPictureAngleAnimationController.reset();

                      likedAnimationController.reset();
                      dislikedAnimationController.reset();

                      //log('pan start ${details.localPosition}');
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
                        swiping = true;
                      } else

                      // Swiping in left direction.
                      if (details.delta.dx < 0) {
                        if (quadrant == 2 || quadrant == 1) {
                          swipedOffset = swipedOffset + (details.delta.dx);
                        } else if (quadrant == 3 || quadrant == 4) {
                          swipedOffset = swipedOffset + (-details.delta.dx);
                        }
                        swiping = true;
                      }

                      updateDetails();

                      setState(() {});
                    },
                    onPanEnd: (details) {
                      if (isPictureLiked()) {
                        likedAnimation = Tween<Offset>(
                                begin: cardPosition,
                                end: Offset(
                                    cardPosition.dx + 300, cardPosition.dy))
                            .animate(CurvedAnimation(
                                parent: likedAnimationController,
                                curve: Curves.ease));
                        setState(() {
                          swiping = false;
                        });
                        likedAnimationController.forward();
                        Future.delayed(Duration(milliseconds: animDurationMs),
                            () {
                          resetTiles();
                        });
                      } else if (isPictureDisliked()) {
                        dislikedAnimation = Tween<Offset>(
                                begin: cardPosition,
                                end: Offset(
                                    cardPosition.dx - 300, cardPosition.dy))
                            .animate(CurvedAnimation(
                                parent: dislikedAnimationController,
                                curve: Curves.ease));
                        setState(() {
                          swiping = false;
                        });
                        dislikedAnimationController.forward();
                        Future.delayed(Duration(milliseconds: animDurationMs),
                            () {
                          resetTiles();
                        });
                      } else {
                        resetPictureAnimation = Tween<Offset>(
                                begin: cardPosition,
                                end: const Offset(0.0, 0.0))
                            .animate(CurvedAnimation(
                                parent: resetPictureAnimationController,
                                curve: Curves.ease));
                        resetPictureAngleAnimation = Tween<double>(
                                begin: 0.436 * swipedScale, end: 0.0)
                            .animate(CurvedAnimation(
                                parent: resetPictureAngleAnimationController,
                                curve: Curves.ease));
                        setState(() {
                          swiping = false;
                        });
                        resetPictureAnimationController.forward();
                        resetPictureAngleAnimationController.forward();
                        Future.delayed(
                            Duration(milliseconds: animDurationMs + 100), () {
                          setState(() {
                            reset = true;
                          });
                        });
                        cardPosition = Offset(0, 0);
                        swipedOffset = 0.0;
                      }

                      updateDetails();
                      setState(() {});
                    },
                    child: Transform.translate(
                      offset: getPictureOffset(),
                      child: Transform.rotate(
                        angle: getPictureAngle(),
                        alignment: getRotationAlignment(quadrant),
                        child: Stack(
                          children: [
                            SizedBox(
                                width: cardWidth,
                                height: cardHeight,
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.white,
                                      boxShadow: const [
                                        BoxShadow(
                                            offset: Offset(4, 4),
                                            color: Colors.grey,
                                            blurRadius: 8)
                                      ]),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      'https://picsum.photos/id/${229 + currentIndex}/${cardWidth.toInt().toString()}/${cardHeight.toInt().toString()}',
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.blue,
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                    ),
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
                            Positioned(
                                bottom: 50,
                                left: 50,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    currentIndex.toString(),
                                    style: const TextStyle(
                                        color: Colors.white,
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
                    onPressed: () async {
                      if (dislikedAnimation != null) {
                        dislikedAnimationController.reset();
                      }
                      dislikedAnimation = Tween<Offset>(
                              begin: Offset(0, 0), end: Offset(-500, 0))
                          .animate(CurvedAnimation(
                              parent: dislikedAnimationController,
                              curve: Curves.ease));
                      setState(() {
                        overrideDislikeAnim = true;
                      });
                      await Future.delayed(Duration(milliseconds: 300));
                      dislikedAnimationController.forward();
                      Future.delayed(Duration(milliseconds: animDurationMs),
                          () {
                        overrideDislikeAnim = false;
                        resetTiles();
                      });
                    },
                    icon: cardRelativePosition == -1
                        ? Icon(Icons.cancel)
                        : Icon(Icons.clear)),
                IconButton(
                    iconSize: 48,
                    onPressed: () async {
                      if (likedAnimation != null) {
                        likedAnimationController.reset();
                      }
                      likedAnimation = Tween<Offset>(
                              begin: Offset(0, 0), end: Offset(500, 0))
                          .animate(CurvedAnimation(
                              parent: likedAnimationController,
                              curve: Curves.ease));
                      setState(() {
                        overrideLikeAnim = true;
                      });
                      await Future.delayed(Duration(milliseconds: 300));
                      likedAnimationController.forward();
                      Future.delayed(Duration(milliseconds: animDurationMs),
                          () {
                        overrideLikeAnim = false;
                        resetTiles();
                      });
                    },
                    icon: cardRelativePosition == 1
                        ? Icon(Icons.favorite)
                        : Icon(Icons.favorite_outline)),
              ],
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.blue,
                boxShadow: const [
                  BoxShadow(
                      offset: Offset(4, 4), color: Colors.grey, blurRadius: 8)
                ]),
          ),
        ],
      ),
    );
  }

  void resetTiles() {
    if (currentIndex == childCount - 1) {
      currentIndex = 0;
    } else {
      currentIndex = currentIndex + 1;
    }
    cardPosition = Offset(0, 0);
    swipedOffset = 0.0;
    reset = true;
    updateDetails();
    setState(() {});
  }

  bool isPictureLiked() {
    return cardRelativePosition == 1 && (swipedScale.abs() * 100) >= 30;
  }

  bool isPictureDisliked() {
    return cardRelativePosition == -1 && (swipedScale.abs() * 100) >= 30;
  }

  Offset getPictureOffset() {
    if (overrideLikeAnim) {
      return likedAnimation != null
          ? likedAnimation!.value
          : const Offset(0, 0);
    } else if (overrideDislikeAnim) {
      return dislikedAnimation != null
          ? dislikedAnimation!.value
          : const Offset(0, 0);
    }

    if (swiping || reset) {
      return cardPosition;
    } else if (isPictureLiked()) {
      return likedAnimation != null
          ? likedAnimation!.value
          : const Offset(0, 0);
    } else if (isPictureDisliked()) {
      return dislikedAnimation != null
          ? dislikedAnimation!.value
          : const Offset(0, 0);
    } else {
      return resetPictureAnimation != null
          ? resetPictureAnimation!.value
          : const Offset(0, 0);
    }
  }

  double getPictureAngle() {
    if (swiping || reset) {
      return 0.436 * swipedScale;
    } else if (!isPictureLiked() && !isPictureDisliked()) {
      return resetPictureAngleAnimation != null
          ? resetPictureAngleAnimation!.value
          : 0.0;
    } else {
      return 0.436 * swipedScale;
    }
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
    }
    if (swipedScale == 0.0) {
      return bottomCardRevealMargin;
    } else {
      double newValue = bottomCardRevealMargin * ((swipedScale.abs() * 3));
      if (bottomCardRevealMargin - newValue < 0) return 0.0;

      return bottomCardRevealMargin - newValue;
    }
  }

  updateDetails() {
    swipedScale = swipedOffset / cardWidth;

    if (cardPosition.dx < -15) {
      //log('card position left');
      cardRelativePosition = -1;
    } else if (cardPosition.dx > 15) {
      //log('card position right');
      cardRelativePosition = 1;
    } else {
      cardRelativePosition = 0;
      //log('card position center');
    }
  }
}
